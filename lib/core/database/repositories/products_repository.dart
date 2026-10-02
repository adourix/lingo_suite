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
    final query = keyword.trim();

    return (db.select(db.products)
          ..where(
            (tbl) =>
                tbl.isActive.equals(true) &
                (tbl.name.like('%$query%') |
                    tbl.sku.like('%$query%') |
                    tbl.barcode.like('%$query%')),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
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
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'must be greater than zero');
    }

    final product = await getById(id);
    if (product == null) return;

    await update(
      id,
      ProductsCompanion(quantity: Value(product.quantity + quantity)),
    );
  }

  Future<void> decreaseStock(int id, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'must be greater than zero');
    }

    final product = await getById(id);
    if (product == null) return;

    if (quantity > product.quantity) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'cannot exceed current stock',
      );
    }

    await update(
      id,
      ProductsCompanion(quantity: Value(product.quantity - quantity)),
    );
  }
}
