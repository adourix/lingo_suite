import 'package:drift/drift.dart';

import '../../auth/auth_models.dart';
import '../app_database.dart';

class CustomerPaymentsRepository {
  final AppDatabase db;
  final int? actorId;

  CustomerPaymentsRepository(this.db, {required this.actorId});

  Future<void> _authorize() async {
    final actor = actorId == null ? null :
        await (db.select(db.users)..where((u) => u.id.equals(actorId!))).getSingleOrNull();
    if (actor == null || !actor.isActive ||
        !Permissions.can(actor.role, Permissions.customers)) {
      throw StateError('User is not authorized to manage customer payments');
    }
  }

  Future<int> addPayment({
    required int customerId,
    required double amount,
    required String method,
    String? notes,
  }) async {
    await _authorize();
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than zero');
    }

    return db.transaction(() async {
      final customer = await (db.select(db.customers)
            ..where((tbl) => tbl.id.equals(customerId))).getSingle();

      if (amount > customer.balance) {
        throw ArgumentError.value(amount, 'amount', 'cannot exceed customer balance');
      }

      final paymentId = await db.into(db.customerPayments).insert(
        CustomerPaymentsCompanion.insert(
          customerId: customerId,
          amount: amount,
          method: method,
          notes: Value(notes),
        ),
      );

      var remainingPayment = amount;
      final sales = await (db.select(db.sales)
            ..where((s) =>
                s.customerId.equals(customerId) &
                s.isReturned.equals(false) &
                s.remaining.isBiggerThanValue(0))
            ..orderBy([(s) => OrderingTerm.asc(s.saleDate)]))
          .get();

      for (final sale in sales) {
        if (remainingPayment <= 0) break;
        final applied = remainingPayment < sale.remaining
            ? remainingPayment
            : sale.remaining;

        await (db.update(db.sales)..where((s) => s.id.equals(sale.id))).write(
          SalesCompanion(
            paid: Value(sale.paid + applied),
            remaining: Value(sale.remaining - applied),
          ),
        );
        remainingPayment -= applied;
      }

      await (db.update(db.customers)..where((c) => c.id.equals(customerId)))
          .write(
        CustomersCompanion(
          balance: Value(customer.balance - amount),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          userId: actorId!,
          action: 'create',
          entity: 'customer_payment',
          entityId: Value(paymentId),
          description: Value('Added customer payment'),
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
