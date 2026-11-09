import 'package:drift/drift.dart';

/// Table definition for Categories (Income & Expense categories)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // INCOME, EXPENSE
  TextColumn get iconName => text().withDefault(const Constant('category'))();
}
