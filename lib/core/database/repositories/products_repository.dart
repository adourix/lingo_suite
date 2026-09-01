import 'package:drift/drift.dart';

import '../app_database.dart';

class ProductsRepository {
  final AppDatabase db;

  ProductsRepository(this.db);

  Future<List<Product>> getAll() {
    return (db.select(db.products)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Stream<List<Product>> watchAll() {
    return (db.select(db.products)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<Product>> search(String keyword) {
    return (db.select(db.products)
          ..where(
            (tbl) =>
                tbl.isActive.equals(true) &
                (tbl.name.like('%$keyword%') |
                    tbl.sku.like('%$keyword%') |
                    tbl.barcode.like('%$keyword%')),
          ))
        .get();
  }

  Future<Product?> getById(int id) {
    return (db.select(db.products)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Product?> getByBarcode(String barcode) {
    return (db.select(db.products)
          ..where((tbl) => tbl.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  Future<int> insert(ProductsCompanion product) {
    return db.into(db.products).insert(product);
  }

  Future<int> update(int id, ProductsCompanion product) {
    return (db.update(db.products)..where((tbl) => tbl.id.equals(id)))
        .write(product);
  }

  Future<void> delete(int id) async {
    await (db.update(db.products)..where((tbl) => tbl.id.equals(id))).write(
      ProductsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> increaseStock(int id, int quantity) async {
    final product = await getById(id);
    if (product == null) return;

    await update(
      id,
      ProductsCompanion(quantity: Value(product.quantity + quantity)),
    );
  }

  Future<void> decreaseStock(int id, int quantity) async {
    final product = await getById(id);
    if (product == null) return;

    await update(
      id,
      ProductsCompanion(quantity: Value(product.quantity - quantity)),
    );
  }
}
