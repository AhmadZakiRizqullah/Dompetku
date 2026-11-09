import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';
import 'database_provider.dart';

// ─── Streams ───────────────────────────────────────────────────────────────

/// Stream of all categories
final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(databaseProvider).categoryDao.watchAllCategories();
});

/// Stream of income categories only
final incomeCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref
      .watch(databaseProvider)
      .categoryDao
      .watchCategoriesByType('INCOME');
});

/// Stream of expense categories only
final expenseCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref
      .watch(databaseProvider)
      .categoryDao
      .watchCategoriesByType('EXPENSE');
});

// ─── Notifier ──────────────────────────────────────────────────────────────

class CategoryNotifier extends AsyncNotifier<void> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  Future<void> build() async {}

  Future<void> addCategory({
    required String name,
    required String type,
    String iconName = 'category',
  }) async {
    await _db.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: name,
        type: type,
        iconName: Value(iconName),
      ),
    );
  }

  Future<void> updateCategory(Category category) async {
    await _db.categoryDao.updateCategory(category.toCompanion(true));
  }

  Future<void> deleteCategory(int categoryId) async {
    await _db.categoryDao.deleteCategory(categoryId);
  }
}

final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, void>(CategoryNotifier.new);
