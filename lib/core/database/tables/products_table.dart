import 'package:drift/drift.dart';

import 'categories_table.dart';
import 'suppliers_table.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 2, max: 200)();

  TextColumn get sku => text().nullable()();

  TextColumn get barcode => text().nullable()();

  IntColumn get categoryId => integer()
      .references(Categories, #id, onDelete: KeyAction.setNull)
      .nullable()();

  IntColumn get supplierId => integer()
      .references(Suppliers, #id, onDelete: KeyAction.setNull)
      .nullable()();

  RealColumn get costPrice => real()();

  RealColumn get sellingPrice => real()();

  IntColumn get quantity => integer().withDefault(const Constant(0))();

  IntColumn get minimumQuantity => integer().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  TextColumn get imagePath => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
