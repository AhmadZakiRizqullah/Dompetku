import 'package:drift/drift.dart';

/// Table definition for Wallets (Bank accounts, E-wallets, Cash)
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // BANK, EWALLET, CASH
  RealColumn get initialBalance => real().withDefault(const Constant(0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0))();
  TextColumn get iconName => text().withDefault(const Constant('wallet'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
