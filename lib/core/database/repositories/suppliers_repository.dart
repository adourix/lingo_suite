import 'package:drift/drift.dart';

import '../app_database.dart';

class SuppliersRepository {
  final AppDatabase db;

  SuppliersRepository(this.db);

  Future<List<Supplier>> getAll() {
    return (db.select(
      db.suppliers,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Stream<List<Supplier>> watchAll() {
    return (db.select(
      db.suppliers,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<Supplier?> getById(int id) {
    return (db.select(
      db.suppliers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insert(SuppliersCompanion supplier) {
    return db.into(db.suppliers).insert(supplier);
  }

  Future<int> update(int id, SuppliersCompanion supplier) {
    return (db.update(
      db.suppliers,
    )..where((t) => t.id.equals(id))).write(supplier);
  }

  Future<int> delete(int id) {
    return (db.delete(db.suppliers)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Supplier>> search(String query) async {
    return await (db.select(
          db.suppliers,
        )..where((tbl) => tbl.name.contains(query) | tbl.phone.contains(query)))
        .get();
  }
}
