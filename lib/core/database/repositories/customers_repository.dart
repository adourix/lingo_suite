import 'package:drift/drift.dart';

import '../app_database.dart';

class CustomersRepository {
  final AppDatabase db;

  CustomersRepository(this.db);

  Future<List<Customer>> getAll() {
    return db.select(db.customers).get();
  }

  Stream<List<Customer>> watchAll() {
    return db.select(db.customers).watch();
  }

  Future<Customer?> getById(int id) {
    return (db.select(
      db.customers,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<List<Customer>> search(String keyword) {
    return (db.select(
          db.customers,
        )..where((c) => c.name.like('%$keyword%') | c.phone.like('%$keyword%')))
        .get();
  }

  Future<int> insert(CustomersCompanion customer) {
    return db.into(db.customers).insert(customer);
  }

  Future<bool> update(Customer customer) {
    return db.update(db.customers).replace(customer);
  }

  Future<int> delete(int id) async {
    final sales = await (db.select(db.sales)
          ..where((s) => s.customerId.equals(id)))
        .get();

    if (sales.isNotEmpty) {
      throw Exception('Cannot delete customer with sales history');
    }

    return (db.delete(db.customers)..where((c) => c.id.equals(id))).go();
  }
}
