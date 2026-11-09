import 'package:drift/drift.dart';
import 'wallets_table.dart';
import 'categories_table.dart';

/// Table definition for Transactions (Income, Expense, Transfer)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  RealColumn get adminFee => real().withDefault(const Constant(0))();
  TextColumn get type => text()(); // INCOME, EXPENSE, TRANSFER
  DateTimeColumn get transactionDate => dateTime()();
  IntColumn get walletId =>
      integer().references(Wallets, #id)();
  IntColumn get toWalletId =>
      integer().nullable().references(Wallets, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
