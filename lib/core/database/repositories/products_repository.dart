import 'package:drift/drift.dart';

import '../../auth/auth_models.dart';
import '../app_database.dart';

class ProductsRepository {
  final AppDatabase db;
  final int? actorId;

  ProductsRepository(this.db, {required this.actorId});

  Future<void> _authorize() async {
    final actor = actorId == null
        ? null
        : await (db.select(db.users)..where((u) => u.id.equals(actorId!)))
            .getSingleOrNull();
    if (actor == null || !actor.isActive ||
        !Permissions.can(actor.role, Permissions.products)) {
      throw StateError('User is not authorized to manage products');
    }
  }

  Future<void> _audit(String action, int entityId, String description) async {
    if (actorId == null) return;
    await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
      userId: actorId!, action: action, entity: 'product',
      entityId: Value(entityId), description: Value(description),
    ));
  }

  Future<List<Product>> getAll() => (db.select(db.products)
        ..where((t) => t.isActive.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Stream<List<Product>> watchAll() => (db.select(db.products)
        ..where((t) => t.isActive.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<List<Product>> search(String keyword) {
    final query = keyword.trim();
    if (query.isEmpty) return getAll();
    return (db.select(db.products)..where((tbl) =>
      tbl.isActive.equals(true) &
      (tbl.name.like('%$query%') | tbl.sku.equals(query) |
       tbl.sku.like('%$query%') | tbl.barcode.equals(query) |
       tbl.barcode.like('%$query%')))).get();
  }

  Future<Product?> getById(int id) =>
      (db.select(db.products)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Product?> getByBarcode(String barcode) =>
      (db.select(db.products)..where((t) => t.barcode.equals(barcode))).getSingleOrNull();

  Future<int> insert(ProductsCompanion product) async {
    await _authorize();
    final id = await db.into(db.products).insert(product);
    await _audit('create', id, 'Created product');
    return id;
  }

  Future<int> update(int id, ProductsCompanion product) async {
    await _authorize();
    if (product.quantity.present && product.quantity.value < 0) {
      throw ArgumentError('Stock quantity cannot be negative');
    }
    if (product.minimumQuantity.present && product.minimumQuantity.value < 0) {
      throw ArgumentError('Minimum quantity cannot be negative');
    }
    if (product.costPrice.present && product.costPrice.value < 0) {
      throw ArgumentError('Cost price cannot be negative');
    }
    if (product.sellingPrice.present && product.sellingPrice.value < 0) {
      throw ArgumentError('Selling price cannot be negative');
    }
    final changed = await (db.update(db.products)..where((t) => t.id.equals(id))).write(product);
    if (changed > 0) await _audit('update', id, 'Updated product');
    return changed;
  }

  Future<void> delete(int id) async {
    await _authorize();
    await (db.update(db.products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(isActive: const Value(false), updatedAt: Value(DateTime.now())),
    );
    await _audit('delete', id, 'Deactivated product');
  }

  Future<void> increaseStock(int id, int quantity) async {
    await _authorize();
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity', 'must be greater than zero');
    final product = await getById(id);
    if (product == null) return;
    await update(id, ProductsCompanion(quantity: Value(product.quantity + quantity)));
    await _audit('stock_increase', id, 'Increased stock by $quantity');
  }

  Future<void> decreaseStock(int id, int quantity) async {
    await _authorize();
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity', 'must be greater than zero');
    final product = await getById(id);
    if (product == null) return;
    if (quantity > product.quantity) {
      throw ArgumentError.value(quantity, 'quantity', 'cannot exceed current stock');
    }
    await update(id, ProductsCompanion(quantity: Value(product.quantity - quantity)));
    await _audit('stock_decrease', id, 'Decreased stock by $quantity');
  }
}
