import 'package:drift/drift.dart';

import '../../auth/auth_models.dart';
import '../app_database.dart';

class SuppliersRepository {
  final AppDatabase db;
  final int? actorId;

  SuppliersRepository(this.db, {required this.actorId});

  Future<void> _authorize() async {
    final actor = actorId == null ? null :
        await (db.select(db.users)..where((u) => u.id.equals(actorId!))).getSingleOrNull();
    if (actor == null || !actor.isActive ||
        !Permissions.can(actor.role, Permissions.suppliers)) {
      throw StateError('User is not authorized to manage suppliers');
    }
  }

  Future<void> _audit(String action, int entityId, String description) async {
    if (actorId == null) return;
    await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
      userId: actorId!, action: action, entity: 'supplier',
      entityId: Value(entityId), description: Value(description),
    ));
  }

  Future<List<Supplier>> getAll() => (db.select(db.suppliers)
        ..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Stream<List<Supplier>> watchAll() => (db.select(db.suppliers)
        ..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<Supplier?> getById(int id) =>
      (db.select(db.suppliers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insert(SuppliersCompanion supplier) async {
    await _authorize();
    final id = await db.into(db.suppliers).insert(supplier);
    await _audit('create', id, 'Created supplier');
    return id;
  }

  Future<int> update(int id, SuppliersCompanion supplier) async {
    await _authorize();
    final changed = await (db.update(db.suppliers)..where((t) => t.id.equals(id))).write(supplier);
    if (changed > 0) await _audit('update', id, 'Updated supplier');
    return changed;
  }

  Future<int> delete(int id) async {
    await _authorize();
    final purchases = await (db.select(db.purchases)..where((p) => p.supplierId.equals(id))).get();
    if (purchases.isNotEmpty) throw Exception('Cannot delete supplier with purchase history');
    final result = await (db.delete(db.suppliers)..where((t) => t.id.equals(id))).go();
    if (result > 0) await _audit('delete', id, 'Deleted supplier');
    return result;
  }

  Future<List<Supplier>> search(String query) =>
      (db.select(db.suppliers)..where((t) => t.name.contains(query) | t.phone.contains(query))).get();
}
