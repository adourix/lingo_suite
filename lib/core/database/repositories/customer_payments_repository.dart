import 'package:drift/drift.dart';

import '../app_database.dart';

class CustomerPaymentsRepository {
  final AppDatabase db;

  CustomerPaymentsRepository(this.db);

  Future<int> addPayment({
    required int customerId,
    required double amount,
    required String method,
    String? notes,
  }) async {
    return await db.transaction(() async {
      // 1- Add payment record

      final paymentId = await db
          .into(db.customerPayments)
          .insert(
            CustomerPaymentsCompanion.insert(
              customerId: customerId,

              amount: amount,

              method: method,

              notes: Value(notes),
            ),
          );

      // 2- Update customer balance

      final customer = await (db.select(
        db.customers,
      )..where((tbl) => tbl.id.equals(customerId))).getSingle();

      final newBalance = customer.balance - amount;

      await (db.update(
        db.customers,
      )..where((tbl) => tbl.id.equals(customerId))).write(
        CustomersCompanion(
          balance: Value(newBalance < 0 ? 0 : newBalance),

          updatedAt: Value(DateTime.now()),
        ),
      );

      return paymentId;
    });
  }

  Future<List<CustomerPayment>> getByCustomer(int customerId) {
    return (db.select(db.customerPayments)
          ..where((tbl) => tbl.customerId.equals(customerId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }
}
