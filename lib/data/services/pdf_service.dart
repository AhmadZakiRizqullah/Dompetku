import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../local/database.dart';
import '../local/daos/transaction_dao.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

class PdfService {
  final AppDatabase db;

  PdfService(this.db);

  /// Generate PDF report for a date range and share it
  Future<void> exportToPdf({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await db.transactionDao.getTransactionsForExport(
      start: startDate,
      end: endDate,
    );

    final wallets = await db.walletDao.getAllWallets();
    final totalBalance =
        wallets.fold(0.0, (sum, w) => sum + w.currentBalance);

    double totalIncome = 0;
    double totalExpense = 0;
    for (final tx in transactions) {
      if (tx.transaction.type == TransactionType.income) {
        totalIncome += tx.transaction.amount;
      } else if (tx.transaction.type == TransactionType.expense) {
        totalExpense += tx.transaction.amount;
      }
    }

    final pdf = pw.Document();
    final poppins = await PdfGoogleFonts.poppinsRegular();
    final poppinsBold = await PdfGoogleFonts.poppinsBold();
    final poppinsMedium = await PdfGoogleFonts.poppinsMedium();

    // Page theme
    final primaryColor = PdfColor.fromHex('#015551');
    final accentColor = PdfColor.fromHex('#FE4F2D');
    final incomeColor = PdfColor.fromHex('#015551');
    final bgColor = PdfColor.fromHex('#FDFBEE');
    final textColor = PdfColor.fromHex('#013230');
    final secondaryTextColor = PdfColor.fromHex('#6B8E8C');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(
          poppinsBold: poppinsBold,
          poppins: poppins,
          primaryColor: primaryColor,
          bgColor: bgColor,
          startDate: startDate,
          endDate: endDate,
        ),
        footer: (context) => _buildFooter(poppins, secondaryTextColor, context),
        build: (context) => [
          // Summary section
          _buildSummarySection(
            poppinsBold: poppinsBold,
            poppins: poppins,
            poppinsMedium: poppinsMedium,
            primaryColor: primaryColor,
            accentColor: accentColor,
            incomeColor: incomeColor,
            textColor: textColor,
            totalBalance: totalBalance,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            wallets: wallets,
          ),
          pw.SizedBox(height: 24),
          // Transaction table
          _buildTransactionTable(
            poppinsBold: poppinsBold,
            poppins: poppins,
            primaryColor: primaryColor,
            accentColor: accentColor,
            incomeColor: incomeColor,
            textColor: textColor,
            transactions: transactions,
          ),
        ],
      ),
    );

    // Save and share
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${AppConstants.pdfExportFileName}';
    final pdfBytes = await pdf.save();
    await File(filePath).writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/pdf')],
      text: 'Laporan keuangan Dompetku',
    );
  }

  /// Preview PDF in-app using Printing package
  Future<void> previewPdf(BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await db.transactionDao.getTransactionsForExport(
      start: startDate,
      end: endDate,
    );

    await Printing.layoutPdf(
      onLayout: (_) async {
        final pdf = pw.Document();
        // Build simplified PDF for preview
        final poppins = await PdfGoogleFonts.poppinsRegular();
        final poppinsBold = await PdfGoogleFonts.poppinsBold();
        pdf.addPage(
          pw.MultiPage(
            build: (context) => [
              pw.Text('Laporan Keuangan Dompetku',
                  style: pw.TextStyle(
                      font: poppinsBold,
                      fontSize: 20,
                      color: PdfColor.fromHex('#015551'))),
              pw.SizedBox(height: 16),
              pw.Text('Total ${transactions.length} transaksi',
                  style: pw.TextStyle(font: poppins)),
            ],
          ),
        );
        return pdf.save();
      },
    );
  }

  // ─── PRIVATE BUILDERS ────────────────────────────────────────────────────

  pw.Widget _buildHeader({
    required pw.Font poppinsBold,
    required pw.Font poppins,
    required PdfColor primaryColor,
    required PdfColor bgColor,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    String periodText = 'Semua Periode';
    if (startDate != null && endDate != null) {
      periodText =
          '${DateFormatter.formatShort(startDate)} - ${DateFormatter.formatShort(endDate)}';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: primaryColor, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DOMPETKU',
                style: pw.TextStyle(
                    font: poppinsBold,
                    fontSize: 22,
                    color: primaryColor),
              ),
              pw.Text(
                'Laporan Keuangan',
                style: pw.TextStyle(font: poppins, fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                periodText,
                style: pw.TextStyle(
                    font: poppinsBold,
                    fontSize: 11,
                    color: primaryColor),
              ),
              pw.Text(
                'Dibuat: ${DateFormatter.formatShort(DateTime.now())}',
                style: pw.TextStyle(font: poppins, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(
      pw.Font poppins, PdfColor secondaryColor, pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
            top: pw.BorderSide(color: secondaryColor, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Dompetku — Pencatatan Keuangan Pribadi',
              style:
                  pw.TextStyle(font: poppins, fontSize: 9, color: secondaryColor)),
          pw.Text('Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style:
                  pw.TextStyle(font: poppins, fontSize: 9, color: secondaryColor)),
        ],
      ),
    );
  }

  pw.Widget _buildSummarySection({
    required pw.Font poppinsBold,
    required pw.Font poppins,
    required pw.Font poppinsMedium,
    required PdfColor primaryColor,
    required PdfColor accentColor,
    required PdfColor incomeColor,
    required PdfColor textColor,
    required double totalBalance,
    required double totalIncome,
    required double totalExpense,
    required List<Wallet> wallets,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Summary cards row
        pw.Row(
          children: [
            _SummaryCard(
              label: 'Total Kekayaan',
              amount: CurrencyFormatter.format(totalBalance),
              bgColor: primaryColor,
              textColor: PdfColor.fromHex('#FDFBEE'),
              poppins: poppins,
              poppinsBold: poppinsBold,
            ),
            pw.SizedBox(width: 12),
            _SummaryCard(
              label: 'Pemasukan',
              amount: CurrencyFormatter.format(totalIncome),
              bgColor: incomeColor.shade(0.8),
              textColor: incomeColor,
              poppins: poppins,
              poppinsBold: poppinsBold,
            ),
            pw.SizedBox(width: 12),
            _SummaryCard(
              label: 'Pengeluaran',
              amount: CurrencyFormatter.format(totalExpense),
              bgColor: accentColor.shade(0.9),
              textColor: accentColor,
              poppins: poppins,
              poppinsBold: poppinsBold,
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        // Wallet breakdown
        pw.Text('Saldo per Wallet',
            style: pw.TextStyle(
                font: poppinsBold, fontSize: 13, color: primaryColor)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(
              color: PdfColor.fromHex('#EAE6DF'), width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration:
                  pw.BoxDecoration(color: primaryColor),
              children: [
                _TableHeaderCell('Wallet', poppinsBold),
                _TableHeaderCell('Tipe', poppinsBold),
                _TableHeaderCell('Saldo', poppinsBold),
              ],
            ),
            ...wallets.map((w) => pw.TableRow(
                  children: [
                    _TableCell(w.name, poppins),
                    _TableCell(WalletType.label(w.type), poppins),
                    _TableCell(
                        CurrencyFormatter.format(w.currentBalance), poppins,
                        align: pw.TextAlign.right),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTransactionTable({
    required pw.Font poppinsBold,
    required pw.Font poppins,
    required PdfColor primaryColor,
    required PdfColor accentColor,
    required PdfColor incomeColor,
    required PdfColor textColor,
    required List<TransactionWithDetails> transactions,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Riwayat Transaksi',
            style: pw.TextStyle(
                font: poppinsBold, fontSize: 13, color: primaryColor)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(
              color: PdfColor.fromHex('#EAE6DF'), width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: primaryColor),
              children: [
                _TableHeaderCell('Tanggal', poppinsBold),
                _TableHeaderCell('Tipe', poppinsBold),
                _TableHeaderCell('Kategori/Wallet', poppinsBold),
                _TableHeaderCell('Nominal', poppinsBold),
                _TableHeaderCell('Catatan', poppinsBold),
              ],
            ),
            ...transactions.asMap().entries.map((entry) {
              final i = entry.key;
              final data = entry.value;
              final tx = data.transaction;
              final bgColor = i.isEven
                  ? PdfColors.white
                  : PdfColor.fromHex('#F9F7ED');

              final amountColor = tx.type == TransactionType.expense
                  ? accentColor
                  : incomeColor;
              final amountText = tx.type == TransactionType.expense
                  ? '- ${CurrencyFormatter.format(tx.amount)}'
                  : tx.type == TransactionType.income
                      ? '+ ${CurrencyFormatter.format(tx.amount)}'
                      : CurrencyFormatter.format(tx.amount);

              final subtitle = tx.type == TransactionType.transfer
                  ? '${data.wallet.name} → ${data.toWallet?.name ?? "?"}'
                  : data.category?.name ?? data.wallet.name;

              return pw.TableRow(
                decoration: pw.BoxDecoration(color: bgColor),
                children: [
                  _TableCell(
                      DateFormatter.formatShort(tx.transactionDate), poppins),
                  _TableCell(TransactionType.label(tx.type), poppins),
                  _TableCell(subtitle, poppins),
                  _TableCell(amountText, poppinsBold,
                      color: amountColor,
                      align: pw.TextAlign.right),
                  _TableCell(tx.note ?? '', poppins),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _TableHeaderCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColor.fromHex('#FDFBEE')),
      ),
    );
  }

  pw.Widget _TableCell(String text, pw.Font font,
      {PdfColor? color, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
            font: font,
            fontSize: 9,
            color: color ?? PdfColor.fromHex('#013230')),
      ),
    );
  }
}

pw.Widget _SummaryCard({
  required String label,
  required String amount,
  required PdfColor bgColor,
  required PdfColor textColor,
  required pw.Font poppins,
  required pw.Font poppinsBold,
}) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(font: poppins, fontSize: 9, color: textColor)),
          pw.SizedBox(height: 4),
          pw.Text(amount,
              style: pw.TextStyle(
                  font: poppinsBold, fontSize: 11, color: textColor)),
        ],
      ),
    ),
  );
}
