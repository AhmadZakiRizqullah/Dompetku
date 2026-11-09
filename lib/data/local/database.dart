import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/wallets_table.dart';
import 'tables/categories_table.dart';
import 'tables/transactions_table.dart';
import 'daos/wallet_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';
import '../../core/constants/app_constants.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Wallets, Categories, Transactions],
  daos: [WalletDao, CategoryDao, TransactionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            await _seedDefaultData();
          }
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle future migrations here
        },
      );

  /// Seed default categories and a default wallet on first install
  Future<void> _seedDefaultData() async {
    await batch((b) {
      b.insertAll(categories, [
        for (final cat in DefaultCategories.income)
          CategoriesCompanion.insert(
            name: cat['name']!,
            type: CategoryType.income,
            iconName: Value(cat['icon']!),
          ),
        for (final cat in DefaultCategories.expense)
          CategoriesCompanion.insert(
            name: cat['name']!,
            type: CategoryType.expense,
            iconName: Value(cat['icon']!),
          ),
      ]);
      b.insertAll(wallets, [
        for (final wallet in DefaultWallets.wallets)
          WalletsCompanion.insert(
            name: wallet['name']!,
            type: wallet['type']!,
            iconName: Value(wallet['icon']!),
          ),
      ]);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dompetku.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
