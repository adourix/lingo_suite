import '../app_database.dart';
import 'sales_repository.dart';
import 'package:drift/drift.dart';

extension SalesDeleteExtension on SalesRepository {
  Future<void> deleteSaleCompletely(int saleId) async {
    await db.transaction(() async {
      final sale = await (db.select(db.sales)
            ..where((tbl) => tbl.id.equals(saleId)))
          .getSingle();

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

      await (db.delete(db.inventoryMovements)
            ..where((tbl) =>
                tbl.referenceType.equals('invoice') &
                tbl.referenceId.equals(saleId)))
          .go();

      await (db.delete(db.payments)
            ..where((tbl) => tbl.saleId.equals(saleId)))
          .go();

      await (db.delete(db.saleItems)
            ..where((tbl) => tbl.saleId.equals(saleId)))
          .go();

      await (db.delete(db.sales)
            ..where((tbl) => tbl.id.equals(saleId)))
          .go();
    });
  }
}
