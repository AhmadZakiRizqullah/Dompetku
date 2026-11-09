import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/transactions_table.dart';
import '../tables/wallets_table.dart';
import '../tables/categories_table.dart';
import '../../../core/constants/app_constants.dart';

part 'transaction_dao.g.dart';

class TransactionWithDetails {
  final Transaction transaction;
  final Wallet wallet;
  final Wallet? toWallet;
  final Category? category;

  TransactionWithDetails({
    required this.transaction,
    required this.wallet,
    this.toWallet,
    this.category,
  });
}

@DriftAccessor(tables: [Transactions, Wallets, Categories])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // ============================================================
  // INTERNAL: Build join query
  // ============================================================

  JoinedSelectStatement<HasResultSet, dynamic> _joinQuery({
    required $WalletsTable srcWallet,
    required $WalletsTable dstWallet,
    DateTime? start,
    DateTime? end,
    int? walletId,
    int? categoryId,
  }) {
    final query = select(transactions).join([
      innerJoin(srcWallet, srcWallet.id.equalsExp(transactions.walletId)),
      leftOuterJoin(
          dstWallet, dstWallet.id.equalsExp(transactions.toWalletId)),
      leftOuterJoin(
          categories, categories.id.equalsExp(transactions.categoryId)),
    ]);

    query.orderBy([
      OrderingTerm.desc(transactions.transactionDate),
      OrderingTerm.desc(transactions.createdAt),
    ]);

    if (start != null && end != null) {
      query.where(transactions.transactionDate.isBetweenValues(start, end));
    }
    if (walletId != null) {
      query.where(transactions.walletId.equals(walletId) |
          transactions.toWalletId.equals(walletId));
    }
    if (categoryId != null) {
      query.where(transactions.categoryId.equals(categoryId));
    }

    return query;
  }

  List<TransactionWithDetails> _mapRows(
    List<TypedResult> rows,
    $WalletsTable srcWallet,
    $WalletsTable dstWallet,
  ) {
    return rows.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        wallet: row.readTable(srcWallet),
        toWallet: row.readTableOrNull(dstWallet),
        category: row.readTableOrNull(categories),
      );
    }).toList();
  }

  // ============================================================
  // READ OPERATIONS
  // ============================================================

  /// Stream of all transactions ordered by date desc (with join)
  Stream<List<TransactionWithDetails>> watchAllTransactions() {
    final srcWallet = alias(wallets, 'src_wallet');
    final dstWallet = alias(wallets, 'dst_wallet');
    return _joinQuery(srcWallet: srcWallet, dstWallet: dstWallet)
        .watch()
        .map((rows) => _mapRows(rows, srcWallet, dstWallet));
  }

  /// Get single transaction by ID
  Future<Transaction?> getTransactionById(int id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all raw transactions on a specific day (used for import deduplication)
  Future<List<Transaction>> getTransactionsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return (select(transactions)
          ..where((t) => t.transactionDate.isBetweenValues(startOfDay, endOfDay)))
        .get();
  }

  /// Get transactions by date range
  Stream<List<TransactionWithDetails>> watchTransactionsByDateRange(
      DateTime start, DateTime end) {
    final srcWallet = alias(wallets, 'src_wallet');
    final dstWallet = alias(wallets, 'dst_wallet');
    return _joinQuery(
            srcWallet: srcWallet, dstWallet: dstWallet, start: start, end: end)
        .watch()
        .map((rows) => _mapRows(rows, srcWallet, dstWallet));
  }

  /// Stream filtered by wallet
  Stream<List<TransactionWithDetails>> watchTransactionsByWallet(int walletId) {
    final srcWallet = alias(wallets, 'src_wallet');
    final dstWallet = alias(wallets, 'dst_wallet');
    return _joinQuery(
            srcWallet: srcWallet, dstWallet: dstWallet, walletId: walletId)
        .watch()
        .map((rows) => _mapRows(rows, srcWallet, dstWallet));
  }

  /// Stream filtered by category
  Stream<List<TransactionWithDetails>> watchTransactionsByCategory(
      int categoryId) {
    final srcWallet = alias(wallets, 'src_wallet');
    final dstWallet = alias(wallets, 'dst_wallet');
    return _joinQuery(
            srcWallet: srcWallet, dstWallet: dstWallet, categoryId: categoryId)
        .watch()
        .map((rows) => _mapRows(rows, srcWallet, dstWallet));
  }

  /// Get monthly summary: total income and expense
  Stream<Map<String, double>> watchMonthlySummary(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return (select(transactions)
          ..where((t) =>
              t.transactionDate.isBetweenValues(startOfMonth, endOfMonth) &
              t.type.isNotValue(TransactionType.transfer)))
        .watch()
        .map((txList) {
      double totalIncome = 0;
      double totalExpense = 0;
      for (final tx in txList) {
        if (tx.type == TransactionType.income) {
          totalIncome += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          totalExpense += tx.amount;
        }
      }
      return {'income': totalIncome, 'expense': totalExpense};
    });
  }

  /// Get expense breakdown by category for a given month (for pie chart)
  Stream<List<Map<String, dynamic>>> watchExpenseByCategory(
      int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final amountSum = transactions.amount.sum();
    final query = selectOnly(transactions).join([
      leftOuterJoin(
          categories, categories.id.equalsExp(transactions.categoryId)),
    ]);

    query
      ..addColumns([categories.id, categories.name, amountSum])
      ..where(transactions.transactionDate
              .isBetweenValues(startOfMonth, endOfMonth) &
          transactions.type.equals(TransactionType.expense))
      ..groupBy([categories.id]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return {
          'categoryId': row.read(categories.id),
          'categoryName': row.read(categories.name) ?? 'Tanpa Kategori',
          'total': row.read(amountSum) ?? 0.0,
        };
      }).toList();
    });
  }

  /// Get all transactions for export (no stream, just future)
  Future<List<TransactionWithDetails>> getTransactionsForExport({
    DateTime? start,
    DateTime? end,
  }) {
    final srcWallet = alias(wallets, 'src_wallet');
    final dstWallet = alias(wallets, 'dst_wallet');
    return _joinQuery(
            srcWallet: srcWallet, dstWallet: dstWallet, start: start, end: end)
        .get()
        .then((rows) => _mapRows(rows, srcWallet, dstWallet));
  }

  // ============================================================
  // WRITE OPERATIONS (ATOMIC)
  // ============================================================

  /// Universal insert routing based on transaction type
  Future<int> insertTransaction(TransactionsCompanion tx) async {
    switch (tx.type.value) {
      case TransactionType.income:
        return addIncomeTransaction(tx);
      case TransactionType.expense:
        return addExpenseTransaction(tx);
      case TransactionType.transfer:
        return addTransferTransaction(tx);
      default:
        return into(transactions).insert(tx);
    }
  }

  /// Add a new INCOME transaction atomically
  Future<int> addIncomeTransaction(TransactionsCompanion tx) async {
    return db.transaction(() async {
      final id = await into(transactions).insert(tx);
      await db.walletDao.adjustBalance(tx.walletId.value, tx.amount.value);
      return id;
    });
  }

  /// Add a new EXPENSE transaction atomically
  Future<int> addExpenseTransaction(TransactionsCompanion tx) async {
    return db.transaction(() async {
      final id = await into(transactions).insert(tx);
      await db.walletDao.adjustBalance(tx.walletId.value, -tx.amount.value);
      return id;
    });
  }

  /// Add a new TRANSFER transaction atomically
  Future<int> addTransferTransaction(TransactionsCompanion tx) async {
    return db.transaction(() async {
      final id = await into(transactions).insert(tx);
      final adminFee = tx.adminFee.present ? tx.adminFee.value : 0.0;
      final total = tx.amount.value + adminFee;
      await db.walletDao.adjustBalance(tx.walletId.value, -total);
      if (tx.toWalletId.value != null) {
        await db.walletDao.adjustBalance(tx.toWalletId.value!, tx.amount.value);
      }
      return id;
    });
  }

  /// Edit an existing transaction atomically
  Future<void> editTransaction(
    Transaction oldTx,
    TransactionsCompanion newTx,
  ) async {
    await db.transaction(() async {
      await _reverseTransactionEffect(oldTx);
      await (update(transactions)..where((t) => t.id.equals(oldTx.id)))
          .write(newTx);
      await _applyTransactionEffect(newTx);
    });
  }

  /// Delete a transaction atomically
  Future<void> deleteTransaction(Transaction tx) async {
    await db.transaction(() async {
      await _reverseTransactionEffect(tx);
      await (delete(transactions)..where((t) => t.id.equals(tx.id))).go();
    });
  }

  /// Delete transaction by ID
  Future<void> deleteTransactionById(int id) async {
    final tx = await getTransactionById(id);
    if (tx != null) {
      await deleteTransaction(tx);
    }
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  Future<void> _reverseTransactionEffect(Transaction tx) async {
    switch (tx.type) {
      case TransactionType.income:
        await db.walletDao.adjustBalance(tx.walletId, -tx.amount);
        break;
      case TransactionType.expense:
        await db.walletDao.adjustBalance(tx.walletId, tx.amount);
        break;
      case TransactionType.transfer:
        final total = tx.amount + tx.adminFee;
        await db.walletDao.adjustBalance(tx.walletId, total);
        if (tx.toWalletId != null) {
          await db.walletDao.adjustBalance(tx.toWalletId!, -tx.amount);
        }
        break;
    }
  }

  Future<void> _applyTransactionEffect(TransactionsCompanion tx) async {
    switch (tx.type.value) {
      case TransactionType.income:
        await db.walletDao.adjustBalance(tx.walletId.value, tx.amount.value);
        break;
      case TransactionType.expense:
        await db.walletDao.adjustBalance(tx.walletId.value, -tx.amount.value);
        break;
      case TransactionType.transfer:
        final adminFee = tx.adminFee.present ? tx.adminFee.value : 0.0;
        final total = tx.amount.value + adminFee;
        await db.walletDao.adjustBalance(tx.walletId.value, -total);
        if (tx.toWalletId.value != null) {
          await db.walletDao
              .adjustBalance(tx.toWalletId.value!, tx.amount.value);
        }
        break;
    }
  }
}
