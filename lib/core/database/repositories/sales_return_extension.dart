import 'package:drift/drift.dart';

import '../app_database.dart';
import 'sales_repository.dart';

extension SalesReturnExtension on SalesRepository {
  Future<void> returnSaleCompletely(int saleId) async {
    await db.transaction(() async {
      final sale = await (db.select(db.sales)
            ..where((tbl) => tbl.id.equals(saleId)))
          .getSingle();

      if (sale.isReturned) {
        throw Exception('Invoice already returned');
      }

      final items = await (db.select(db.saleItems)
            ..where((tbl) => tbl.saleId.equals(saleId)))
          .get();

      for (final item in items) {
        if (item.productId == null) continue;

        final product = await (db.select(db.products)
              ..where((tbl) => tbl.id.equals(item.productId!)))
            .getSingle();

        await (db.update(db.products)
              ..where((tbl) => tbl.id.equals(product.id)))
            .write(
          ProductsCompanion(
            quantity: Value(product.quantity + item.quantity),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await db.into(db.inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            productId: product.id,
            type: 'return',
            quantity: item.quantity,
            referenceType: const Value('sale_return'),
            referenceId: Value(saleId),
          ),
        );
      }

      if (sale.customerId != null && sale.remaining > 0) {
        final customer = await (db.select(db.customers)
              ..where((tbl) => tbl.id.equals(sale.customerId!)))
            .getSingle();

        await (db.update(db.customers)
              ..where((tbl) => tbl.id.equals(customer.id)))
            .write(
          CustomersCompanion(
            balance: Value(customer.balance - sale.remaining),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      await (db.delete(db.payments)
            ..where((tbl) => tbl.saleId.equals(saleId)))
          .go();

      await (db.update(db.sales)
            ..where((tbl) => tbl.id.equals(saleId)))
          .write(
        SalesCompanion(isReturned: const Value(true)),
      );
    });
  }
}
