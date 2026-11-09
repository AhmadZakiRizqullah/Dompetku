import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';

/// Singleton database provider — the single source of truth for the DB instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
