import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';
import '../data/local/daos/transaction_dao.dart';
import '../core/constants/app_constants.dart';
import 'database_provider.dart';

// ─── Filter State ──────────────────────────────────────────────────────────

class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? walletId;
  final int? categoryId;

  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.walletId,
    this.categoryId,
  });

  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? walletId,
    int? categoryId,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearWallet = false,
    bool clearCategory = false,
  }) {
    return TransactionFilter(
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      walletId: clearWallet ? null : walletId ?? this.walletId,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
    );
  }

  bool get hasFilter =>
      startDate != null || walletId != null || categoryId != null;
}

final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) => const TransactionFilter());

// ─── Streams ───────────────────────────────────────────────────────────────

/// Stream of all transactions (no filter)
final allTransactionsProvider =
    StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.transactionDao.watchAllTransactions().map(
        (list) => list.map((e) => e.transaction).toList(),
      );
});

/// Stream of filtered transactions
final filteredTransactionsProvider =
    StreamProvider<List<TransactionWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  final filter = ref.watch(transactionFilterProvider);

  if (filter.startDate != null && filter.endDate != null) {
    return db.transactionDao
        .watchTransactionsByDateRange(filter.startDate!, filter.endDate!);
  }
  if (filter.walletId != null) {
    return db.transactionDao
        .watchTransactionsByWallet(filter.walletId!);
  }
  if (filter.categoryId != null) {
    return db.transactionDao
        .watchTransactionsByCategory(filter.categoryId!);
  }
  return db.transactionDao.watchAllTransactions();
});

/// Stream of recent transactions for dashboard
final recentTransactionsProvider =
    StreamProvider<List<TransactionWithDetails>>((ref) {
  return ref.watch(databaseProvider).transactionDao.watchAllTransactions().map(
        (list) => list.take(AppConstants.recentTransactionsLimit).toList(),
      );
});

/// Monthly summary (income/expense)
final selectedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

final monthlySummaryProvider = StreamProvider<Map<String, double>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.transactionDao.watchMonthlySummary(month.year, month.month);
});

/// Expense by category for pie chart
final expenseByCategoryProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.transactionDao.watchExpenseByCategory(month.year, month.month);
});

// ─── Notifier ──────────────────────────────────────────────────────────────

class TransactionNotifier extends AsyncNotifier<void> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  Future<void> build() async {}

  Future<void> addTransaction({
    required double amount,
    required String type,
    required int walletId,
    required DateTime transactionDate,
    double adminFee = 0,
    int? toWalletId,
    int? categoryId,
    String? note,
  }) async {
    final companion = TransactionsCompanion.insert(
      amount: amount,
      type: type,
      walletId: walletId,
      transactionDate: transactionDate,
      adminFee: Value(adminFee),
      toWalletId: Value(toWalletId),
      categoryId: Value(categoryId),
      note: Value(note),
    );

    switch (type) {
      case TransactionType.income:
        await _db.transactionDao.addIncomeTransaction(companion);
        break;
      case TransactionType.expense:
        await _db.transactionDao.addExpenseTransaction(companion);
        break;
      case TransactionType.transfer:
        await _db.transactionDao.addTransferTransaction(companion);
        break;
    }
  }

  Future<void> editTransaction(
    Transaction oldTx, {
    required double amount,
    required String type,
    required int walletId,
    required DateTime transactionDate,
    double adminFee = 0,
    int? toWalletId,
    int? categoryId,
    String? note,
  }) async {
    final companion = TransactionsCompanion(
      id: Value(oldTx.id),
      amount: Value(amount),
      type: Value(type),
      walletId: Value(walletId),
      transactionDate: Value(transactionDate),
      adminFee: Value(adminFee),
      toWalletId: Value(toWalletId),
      categoryId: Value(categoryId),
      note: Value(note),
    );
    await _db.transactionDao.editTransaction(oldTx, companion);
  }

  Future<void> deleteTransaction(Transaction tx) async {
    await _db.transactionDao.deleteTransaction(tx);
  }
}

final transactionNotifierProvider =
    AsyncNotifierProvider<TransactionNotifier, void>(TransactionNotifier.new);
