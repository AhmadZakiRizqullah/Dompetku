import 'dart:io';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../local/database.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';

class ExcelService {
  final AppDatabase db;

  ExcelService(this.db);

  // ─── EXPORT ─────────────────────────────────────────────────────────────

  /// Export transactions in a date range to Excel and share the file
  Future<void> exportToExcel({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await db.transactionDao.getTransactionsForExport(
      start: startDate,
      end: endDate,
    );

    final excel = Excel.createExcel();
    final sheet = excel['Transaksi'];

    // Header row
    final headers = [
      'Tanggal',
      'Tipe',
      'Wallet Sumber',
      'Wallet Tujuan',
      'Kategori',
      'Nominal',
      'Biaya Admin',
      'Catatan',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#015551'),
        fontColorHex: ExcelColor.fromHexString('#FDFBEE'),
      );
    }

    // Data rows
    for (var r = 0; r < transactions.length; r++) {
      final data = transactions[r];
      final tx = data.transaction;
      final row = r + 1;

      _writeCell(sheet, row, 0,
          TextCellValue(DateFormatter.formatISO(tx.transactionDate)));
      _writeCell(sheet, row, 1, TextCellValue(tx.type));
      _writeCell(sheet, row, 2, TextCellValue(data.wallet.name));
      _writeCell(sheet, row, 3, TextCellValue(data.toWallet?.name ?? ''));
      _writeCell(sheet, row, 4, TextCellValue(data.category?.name ?? ''));
      _writeCell(sheet, row, 5, DoubleCellValue(tx.amount));
      _writeCell(sheet, row, 6, DoubleCellValue(tx.adminFee));
      _writeCell(sheet, row, 7, TextCellValue(tx.note ?? ''));
    }

    // Set column widths
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 12);
    sheet.setColumnWidth(2, 20);
    sheet.setColumnWidth(3, 20);
    sheet.setColumnWidth(4, 20);
    sheet.setColumnWidth(5, 15);
    sheet.setColumnWidth(6, 15);
    sheet.setColumnWidth(7, 30);

    // Save to temp directory
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${AppConstants.excelExportFileName}';
    final fileBytes = excel.save();
    if (fileBytes == null) throw Exception('Gagal generate file Excel');

    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    // Share/save
    await Share.shareXFiles(
      [
        XFile(filePath,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      ],
      text: 'Laporan transaksi Dompetku',
    );
  }

  // ─── EXPORT TEMPLATE ─────────────────────────────────────────────────────

  /// Generate and share a blank Excel import template
  Future<void> exportTemplate() async {
    final excel = Excel.createExcel();
    final sheet = excel['Template Import'];

    // Header
    final headers = [
      'Tanggal (YYYY-MM-DD)',
      'Tipe (INCOME/EXPENSE/TRANSFER)',
      'Wallet Sumber',
      'Wallet Tujuan (Opsional)',
      'Kategori',
      'Nominal',
      'Biaya Admin',
      'Catatan',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#57B4BA'),
        fontColorHex: ExcelColor.fromHexString('#013230'),
      );
    }

    // Example rows
    final examples = [
      ['2026-10-01', 'INCOME', 'BCA', '', 'Gaji', '5000000', '0', 'Gaji Bulan Oktober'],
      ['2026-10-02', 'TRANSFER', 'BCA', 'GoPay', '', '500000', '1000', 'Topup GoPay'],
      [
        '2026-10-03',
        'EXPENSE',
        'GoPay',
        '',
        'Makanan & Minuman',
        '45000',
        '0',
        'Beli kopi'
      ],
    ];

    for (var r = 0; r < examples.length; r++) {
      for (var c = 0; c < examples[r].length; c++) {
        _writeCell(sheet, r + 1, c, TextCellValue(examples[r][c]));
      }
    }

    for (var i = 0; i < 8; i++) {
      sheet.setColumnWidth(i, 25);
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${AppConstants.excelTemplateFileName}';
    final fileBytes = excel.save();
    if (fileBytes == null) throw Exception('Gagal generate template');

    await File(filePath).writeAsBytes(fileBytes);
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Template import Dompetku',
    );
  }

  // ─── IMPORT ─────────────────────────────────────────────────────────────

  /// Pick an Excel file and import transactions
  Future<ImportResult> importFromExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.single.path == null) {
      return const ImportResult(
          success: false, message: 'Tidak ada file dipilih');
    }

    final filePath = result.files.single.path!;
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      return const ImportResult(
          success: false, message: 'Sheet tidak ditemukan');
    }

    int successCount = 0;
    int skippedCount = 0;
    int errorCount = 0;
    final errors = <String>[];
    final matchedTxIds = <int>{};

    // Skip header row (index 0)
    for (var r = 1; r < sheet.maxRows; r++) {
      final row = sheet.rows[r];
      if (row.isEmpty || row[0]?.value == null) continue;

      try {
        final dateStr = row[0]?.value?.toString() ?? '';
        final type = row[1]?.value?.toString().toUpperCase() ?? '';
        final walletName = row[2]?.value?.toString() ?? '';
        final toWalletName = row[3]?.value?.toString() ?? '';
        final categoryName = row[4]?.value?.toString() ?? '';
        final amountStr = row[5]?.value?.toString() ?? '0';
        final adminFeeStr = row[6]?.value?.toString() ?? '0';
        final note = row[7]?.value?.toString();

        final date = DateFormatter.parseISO(dateStr);
        if (date == null) throw Exception('Tanggal tidak valid: $dateStr');

        final amount = double.tryParse(amountStr) ?? 0;
        final adminFee = double.tryParse(adminFeeStr) ?? 0;

        if (!['INCOME', 'EXPENSE', 'TRANSFER'].contains(type)) {
          throw Exception('Tipe tidak valid: $type');
        }
        if (walletName.isEmpty) throw Exception('Wallet sumber kosong');

        // Get or create wallet
        final walletId = await _getOrCreateWallet(walletName);

        int? toWalletId;
        if (type == 'TRANSFER' && toWalletName.isNotEmpty) {
          toWalletId = await _getOrCreateWallet(toWalletName);
        }

        int? categoryId;
        if (categoryName.isNotEmpty && type != 'TRANSFER') {
          final catType = type == 'INCOME'
              ? CategoryType.income
              : CategoryType.expense;
          categoryId =
              await db.categoryDao.getOrCreateCategory(categoryName, catType);
        }

        // Cek duplikasi: jika transaksi sudah terdaftar di database, lewati
        final existingOnDay =
            await db.transactionDao.getTransactionsForDay(date);
        final cleanNote = (note ?? '').trim().toLowerCase();

        Transaction? duplicateCandidate;
        for (final existing in existingOnDay) {
          if (matchedTxIds.contains(existing.id)) continue;
          if (existing.type != type) continue;
          if (existing.walletId != walletId) continue;
          if ((existing.amount - amount).abs() > 0.01) continue;
          if ((existing.adminFee - adminFee).abs() > 0.01) continue;
          if (existing.toWalletId != toWalletId) continue;
          if (existing.categoryId != categoryId) continue;

          final existingNote = (existing.note ?? '').trim().toLowerCase();
          if (existingNote != cleanNote) continue;

          duplicateCandidate = existing;
          break;
        }

        if (duplicateCandidate != null) {
          matchedTxIds.add(duplicateCandidate.id);
          skippedCount++;
          continue;
        }

        // Insert transaction atomically
        final companion = TransactionsCompanion.insert(
          amount: amount,
          type: type,
          walletId: walletId,
          transactionDate: date,
          adminFee: Value(adminFee),
          toWalletId: Value(toWalletId),
          categoryId: Value(categoryId),
          note: Value(note?.isEmpty == true ? null : note),
        );

        switch (type) {
          case TransactionType.income:
            await db.transactionDao.addIncomeTransaction(companion);
            break;
          case TransactionType.expense:
            await db.transactionDao.addExpenseTransaction(companion);
            break;
          case TransactionType.transfer:
            await db.transactionDao.addTransferTransaction(companion);
            break;
        }

        successCount++;
      } catch (e) {
        errorCount++;
        errors.add('Baris ${r + 1}: $e');
      }
    }

    String resultMessage;
    if (successCount > 0 && skippedCount > 0) {
      resultMessage =
          '$successCount transaksi berhasil diimpor, $skippedCount transaksi sudah ada (dilewati)${errorCount > 0 ? ', $errorCount gagal' : ''}.';
    } else if (successCount > 0) {
      resultMessage =
          '$successCount transaksi berhasil diimpor${errorCount > 0 ? ', $errorCount gagal' : ''}.';
    } else if (skippedCount > 0) {
      resultMessage =
          '$skippedCount transaksi sudah terdaftar sebelumnya (tidak ada data duplikat yang diimpor)${errorCount > 0 ? ', $errorCount gagal' : ''}.';
    } else {
      resultMessage =
          'Tidak ada transaksi yang diimpor${errorCount > 0 ? ' ($errorCount gagal)' : ''}.';
    }

    return ImportResult(
      success: errorCount == 0,
      message: resultMessage,
      errors: errors,
      successCount: successCount,
      skippedCount: skippedCount,
      errorCount: errorCount,
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  Future<int> _getOrCreateWallet(String name) async {
    final wallets = await db.walletDao.getAllWallets();
    final existing = wallets
        .where((w) => w.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    if (existing != null) return existing.id;

    return db.walletDao.insertWallet(
      WalletsCompanion.insert(
        name: name,
        type: WalletType.cash,
      ),
    );
  }

  void _writeCell(Sheet sheet, int row, int col, CellValue value) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
        .value = value;
  }
}

class ImportResult {
  final bool success;
  final String message;
  final List<String> errors;
  final int successCount;
  final int skippedCount;
  final int errorCount;

  const ImportResult({
    required this.success,
    required this.message,
    this.errors = const [],
    this.successCount = 0,
    this.skippedCount = 0,
    this.errorCount = 0,
  });
}
