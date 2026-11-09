import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku_tracker/core/constants/app_constants.dart';
import 'package:dompetku_tracker/data/local/database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() async {
    // In-memory sqlite database for fast, isolated tests
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Database and DAO Tests', () {
    test('Initial seeding creates default categories and cash wallet', () async {
      final categories = await db.categoryDao.getAllCategories();
      expect(categories.isNotEmpty, true);

      final wallets = await db.walletDao.getAllWallets();
      expect(wallets.length, 1);
      expect(wallets.first.name, 'Uang Tunai');
    });

    test('WalletDao: create wallet and calculate total balance', () async {
      final bcaId = await db.walletDao.insertWallet(
        WalletsCompanion.insert(
          name: 'BCA',
          type: WalletType.bank,
          initialBalance: const Value(500000.0),
          currentBalance: const Value(500000.0),
        ),
      );
      expect(bcaId, greaterThan(0));

      final gopayId = await db.walletDao.insertWallet(
        WalletsCompanion.insert(
          name: 'GoPay',
          type: WalletType.eWallet,
          initialBalance: const Value(150000.0),
          currentBalance: const Value(150000.0),
        ),
      );
      expect(gopayId, greaterThan(0));

      final totalBalance = await db.walletDao.watchTotalBalance().first;
      // Default cash (0) + BCA (500,000) + GoPay (150,000) = 650,000
      expect(totalBalance, 650000.0);
    });

    test('TransactionDao: Income increases wallet balance atomically', () async {
      final walletId = await db.walletDao.insertWallet(
        WalletsCompanion.insert(
          name: 'Mandiri',
          type: WalletType.bank,
          initialBalance: const Value(1000000.0),
          currentBalance: const Value(1000000.0),
        ),
      );

      final incomeCat = (await db.categoryDao.getCategoriesByType(CategoryType.income)).first;

      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          walletId: walletId,
          type: TransactionType.income,
          amount: 500000.0,
          categoryId: Value(incomeCat.id),
          transactionDate: DateTime.now(),
          note: const Value('Gaji Tambahan'),
        ),
      );

      final updatedWallet = await db.walletDao.getWalletById(walletId);
      expect(updatedWallet?.currentBalance, 1500000.0);
    });

    test('TransactionDao: Expense decreases wallet balance atomically', () async {
      final walletId = await db.walletDao.insertWallet(
        WalletsCompanion.insert(
          name: 'Dompet Kulit',
          type: WalletType.cash,
          initialBalance: const Value(200000.0),
          currentBalance: const Value(200000.0),
        ),
      );

      final expenseCat = (await db.categoryDao.getCategoriesByType(CategoryType.expense)).first;

      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          walletId: walletId,
          type: TransactionType.expense,
          amount: 45000.0,
          categoryId: Value(expenseCat.id),
          transactionDate: DateTime.now(),
          note: const Value('Makan Siang'),
        ),
      );

      final updatedWallet = await db.walletDao.getWalletById(walletId);
      expect(updatedWallet?.currentBalance, 155000.0);
    });

    test('TransactionDao: Transfer debits source (+ admin fee) and credits target', () async {
      final sourceId = await db.walletDao.insertWallet(
        WalletsCompanion.insert(
          name: 'BCA Rekening',
          type: WalletType.bank,
          initialBalance: const Value(1000000.0),
          currentBalance: const Value(1000000.0),
        ),
      );

      final targetId = await db.walletDao.insertWallet(
        WalletsCompanion.insert(
          name: 'OVO Dompet',
          type: WalletType.eWallet,
          initialBalance: const Value(50000.0),
          currentBalance: const Value(50000.0),
        ),
      );

      // Transfer 200,000 from BCA to OVO with 2,500 admin fee
      // Source should lose 200,000 + 2,500 = 202,500 (Remaining: 797,500)
      // Target should gain 200,000 (Remaining: 250,000)
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          walletId: sourceId,
          toWalletId: Value(targetId),
          type: TransactionType.transfer,
          amount: 200000.0,
          adminFee: const Value(2500.0),
          transactionDate: DateTime.now(),
          note: const Value('Top up OVO'),
        ),
      );

      final sourceWallet = await db.walletDao.getWalletById(sourceId);
      final targetWallet = await db.walletDao.getWalletById(targetId);

      expect(sourceWallet?.currentBalance, 797500.0);
      expect(targetWallet?.currentBalance, 250000.0);
    });

    test('TransactionDao: Delete transaction rolls back balance accurately', () async {
      final walletId = await db.walletDao.insertWallet(
        WalletsCompanion.insert(
          name: 'Kas',
          type: WalletType.cash,
          initialBalance: const Value(300000.0),
          currentBalance: const Value(300000.0),
        ),
      );

      final expenseCat = (await db.categoryDao.getCategoriesByType(CategoryType.expense)).first;

      final txId = await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          walletId: walletId,
          type: TransactionType.expense,
          amount: 50000.0,
          categoryId: Value(expenseCat.id),
          transactionDate: DateTime.now(),
        ),
      );

      var walletAfterExpense = await db.walletDao.getWalletById(walletId);
      expect(walletAfterExpense?.currentBalance, 250000.0);

      // Now delete the transaction
      await db.transactionDao.deleteTransactionById(txId);

      final walletAfterDelete = await db.walletDao.getWalletById(walletId);
      expect(walletAfterDelete?.currentBalance, 300000.0);
    });
  });
}
