import 'package:drift/drift.dart';

import 'products_table.dart';
import 'sales_table.dart';

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get saleId => integer().references(Sales, #id)();

  IntColumn get productId => integer().references(Products, #id).nullable()();

  TextColumn get itemName => text()();

  IntColumn get quantity => integer()();

  RealColumn get unitPrice => real()();

  RealColumn get costPrice => real().withDefault(const Constant(0))();

  RealColumn get discount => real().withDefault(const Constant(0))();

  RealColumn get total => real()();

  BoolColumn get isManual => boolean().withDefault(const Constant(false))();
}
