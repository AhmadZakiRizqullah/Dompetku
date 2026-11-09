import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  // --- READ ---

  /// Stream all categories
  Stream<List<Category>> watchAllCategories() {
    return (select(categories)..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Future of all categories
  Future<List<Category>> getAllCategories() {
    return (select(categories)..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Stream categories by type (INCOME or EXPENSE)
  Stream<List<Category>> watchCategoriesByType(String type) {
    return (select(categories)
          ..where((c) => c.type.equals(type))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Future of categories by type
  Future<List<Category>> getCategoriesByType(String type) {
    return (select(categories)
          ..where((c) => c.type.equals(type))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Get category by ID
  Future<Category?> getCategoryById(int id) {
    return (select(categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get or create category by name and type (for Excel import)
  Future<int> getOrCreateCategory(String name, String type) async {
    final existing = await (select(categories)
          ..where((c) => c.name.equals(name) & c.type.equals(type)))
        .getSingleOrNull();

    if (existing != null) return existing.id;

    return into(categories).insert(
      CategoriesCompanion.insert(name: name, type: type),
    );
  }

  // --- CREATE ---

  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  // --- UPDATE ---

  Future<bool> updateCategory(CategoriesCompanion category) {
    return update(categories).replace(category);
  }

  // --- DELETE ---

  Future<int> deleteCategory(int categoryId) {
    return (delete(categories)..where((c) => c.id.equals(categoryId))).go();
  }
}
