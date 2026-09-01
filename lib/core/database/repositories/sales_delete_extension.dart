import '../app_database.dart';
import 'sales_repository.dart';
import 'package:drift/drift.dart';

extension SalesDeleteExtension on SalesRepository {
  Future<void> deleteSaleCompletely(int saleId) async {
    await db.transaction(() async {
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
