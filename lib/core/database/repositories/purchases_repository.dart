import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../auth/auth_models.dart';
import '../app_database.dart';

class PurchasesRepository {
  final AppDatabase db;
  final int? actorId;

  PurchasesRepository(this.db, {required this.actorId});

  Future<void> _authorize() async {
    final actor = actorId == null ? null :
        await (db.select(db.users)..where((u) => u.id.equals(actorId!))).getSingleOrNull();
    if (actor == null || !actor.isActive ||
        !Permissions.can(actor.role, Permissions.suppliers)) {
      throw StateError('User is not authorized to manage purchases');
    }
  }

  Future<List<Purchase>> getSupplierPurchases(int supplierId) =>
      (db.select(db.purchases)
        ..where((t) => t.supplierId.equals(supplierId))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<int> createPurchase({
    required int supplierId,
    required List<PurchaseItemData> items,
    required double paid,
    String? notes,
  }) async {
    await _authorize();
    if (items.isEmpty) throw ArgumentError('Purchase cannot be empty');
    if (paid < 0) throw ArgumentError('Paid amount cannot be negative');

    for (final item in items) {
      if (item.quantity <= 0 || item.unitCost < 0 || item.total < 0) {
        throw ArgumentError('Invalid purchase item');
      }
      final expectedTotal = item.quantity * item.unitCost;
      if ((item.total - expectedTotal).abs() > 0.01) {
        throw ArgumentError('Purchase item total does not match quantity × cost');
      }
    }

    return db.transaction(() async {
      final total = items.fold<double>(0, (sum, item) => sum + item.total);
      if (paid > total) throw ArgumentError('Paid amount cannot exceed purchase total');
      final remaining = total - paid;
      final timestamp = DateTime.now();
      final invoiceNumber =
          'PUR-\${DateFormat('yyyyMMddHHmmssSSS').format(timestamp)}-\${timestamp.microsecond.toString().padLeft(6, '0')}';

      final purchaseId = await db.into(db.purchases).insert(
        PurchasesCompanion.insert(
          invoiceNumber: invoiceNumber, supplierId: supplierId, total: total,
          paid: Value(paid), remaining: Value(remaining), notes: Value(notes),
        ),
      );

      for (final item in items) {
        await db.into(db.purchaseItems).insert(PurchaseItemsCompanion.insert(
          purchaseId: purchaseId, productId: item.productId, quantity: item.quantity,
          unitCost: item.unitCost, total: item.total,
        ));

        final product = await (db.select(db.products)
              ..where((tbl) => tbl.id.equals(item.productId))).getSingle();

        await (db.update(db.products)..where((tbl) => tbl.id.equals(item.productId))).write(
          ProductsCompanion(quantity: Value(product.quantity + item.quantity),
            updatedAt: Value(DateTime.now())),
        );

        await db.into(db.inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            productId: item.productId, type: 'purchase', quantity: item.quantity,
            referenceType: const Value('purchase'), referenceId: Value(purchaseId),
          ),
        );
      }

      if (remaining > 0) {
        final supplier = await (db.select(db.suppliers)
              ..where((tbl) => tbl.id.equals(supplierId))).getSingle();
        await (db.update(db.suppliers)..where((tbl) => tbl.id.equals(supplierId))).write(
          SuppliersCompanion(balance: Value(supplier.balance + remaining),
            updatedAt: Value(DateTime.now())),
        );
      }

      await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
        userId: actorId!, action: 'create', entity: 'purchase',
        entityId: Value(purchaseId),
        description: Value('Created purchase \$invoiceNumber'),
      ));
      return purchaseId;
    });
  }
}

class PurchaseItemData {
  final int productId;
  final int quantity;
  final double unitCost;
  final double total;

  const PurchaseItemData({
    required this.productId, required this.quantity,
    required this.unitCost, required this.total,
  });
}
