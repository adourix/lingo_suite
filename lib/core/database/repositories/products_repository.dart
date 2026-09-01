import 'package:drift/drift.dart';

import '../app_database.dart';

class ProductsRepository {
  final AppDatabase db;

  ProductsRepository(this.db);

  /// =========================
  /// Get All Products
  /// =========================

  Future<List<Product>> getAll() {
    return (db.select(
      db.products,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Stream<List<Product>> watchAll() {
    return (db.select(
      db.products,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  /// =========================
  /// Search
  /// =========================

  Future<List<Product>> search(String keyword) {
    return (db.select(db.products)..where(
          (tbl) =>
              tbl.name.like('%$keyword%') |
              tbl.sku.like('%$keyword%') |
              tbl.barcode.like('%$keyword%'),
        ))
        .get();
  }

  /// =========================
  /// Get By Id
  /// =========================

  Future<Product?> getById(int id) {
    return (db.select(
      db.products,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<Product?> getByBarcode(String barcode) {
    return (db.select(
      db.products,
    )..where((tbl) => tbl.barcode.equals(barcode))).getSingleOrNull();
  }

  /// =========================
  /// Add Product
  /// =========================

  Future<int> insert(ProductsCompanion product) {
    return db.into(db.products).insert(product);
  }

  /// =========================
  /// Update Product
  /// =========================

  Future<int> update(int id, ProductsCompanion product) {
    return (db.update(
      db.products,
    )..where((tbl) => tbl.id.equals(id))).write(product);
  }

  /// =========================
  /// Delete Product
  /// =========================

  Future<void> delete(int id) async {
    await (db.update(db.products)..where((tbl) => tbl.id.equals(id))).write(
      ProductsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// =========================
  /// Increase Stock
  /// =========================

  Future<void> increaseStock(int id, int quantity) async {
    final product = await getById(id);

    if (product == null) return;

    await update(
      id,
      ProductsCompanion(quantity: Value(product.quantity + quantity)),
    );
  }

  /// =========================
  /// Decrease Stock
  /// =========================

  Future<void> decreaseStock(int id, int quantity) async {
    final product = await getById(id);

    if (product == null) return;

    await update(
      id,
      ProductsCompanion(quantity: Value(product.quantity - quantity)),
    );
  }
}
