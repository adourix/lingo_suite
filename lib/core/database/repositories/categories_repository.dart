import 'package:drift/drift.dart';

import '../app_database.dart';

class CategoriesRepository {
  final AppDatabase db;

  CategoriesRepository(this.db);

  Future<List<Category>> getAll() {
    return (db.select(
      db.categories,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Stream<List<Category>> watchAll() {
    return (db.select(
      db.categories,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<Category?> getById(int id) {
    return (db.select(
      db.categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insert(CategoriesCompanion category) {
    return db.into(db.categories).insert(category);
  }

  Future<int> update(int id, CategoriesCompanion category) {
    return (db.update(
      db.categories,
    )..where((t) => t.id.equals(id))).write(category);
  }

  Future<int> delete(int id) {
    return (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
  }
}
