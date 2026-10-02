import 'package:drift/drift.dart';

import '../../auth/auth_models.dart';
import '../app_database.dart';

class CustomersRepository {
  final AppDatabase db;
  final int? actorId;

  CustomersRepository(this.db, {required this.actorId});

  Future<void> _authorize() async {
    final actor = actorId == null ? null :
        await (db.select(db.users)..where((u) => u.id.equals(actorId!))).getSingleOrNull();
    if (actor == null || !actor.isActive ||
        !Permissions.can(actor.role, Permissions.customers)) {
      throw StateError('User is not authorized to manage customers');
    }
  }

  Future<void> _audit(String action, int entityId, String description) async {
    if (actorId == null) return;
    await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
      userId: actorId!, action: action, entity: 'customer',
      entityId: Value(entityId), description: Value(description),
    ));
  }

  Future<List<Customer>> getAll() => db.select(db.customers).get();
  Stream<List<Customer>> watchAll() => db.select(db.customers).watch();

  Future<Customer?> getById(int id) =>
      (db.select(db.customers)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<Customer>> search(String keyword) =>
      (db.select(db.customers)..where((c) =>
        c.name.like('%$keyword%') | c.phone.like('%$keyword%'))).get();

  Future<int> insert(CustomersCompanion customer) async {
    await _authorize();
    final id = await db.into(db.customers).insert(customer);
    await _audit('create', id, 'Created customer');
    return id;
  }

  Future<bool> update(Customer customer) async {
    await _authorize();
    final changed = await db.update(db.customers).replace(customer);
    if (changed) await _audit('update', customer.id, 'Updated customer');
    return changed;
  }

  Future<int> delete(int id) async {
    await _authorize();
    final sales = await (db.select(db.sales)..where((s) => s.customerId.equals(id))).get();
    if (sales.isNotEmpty) throw Exception('Cannot delete customer with sales history');
    final payments = await (db.select(db.customerPayments)
          ..where((p) => p.customerId.equals(id))).get();
    if (payments.isNotEmpty) throw Exception('Cannot delete customer with payment history');
    final result = await (db.delete(db.customers)..where((c) => c.id.equals(id))).go();
    if (result > 0) await _audit('delete', id, 'Deleted customer');
    return result;
  }
}
