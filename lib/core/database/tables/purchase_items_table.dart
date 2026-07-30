import 'package:drift/drift.dart';

import 'products_table.dart';
import 'purchases_table.dart';

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get purchaseId => integer().references(Purchases, #id)();

  IntColumn get productId => integer().references(Products, #id)();

  IntColumn get quantity => integer()();

  RealColumn get unitCost => real()();

  RealColumn get total => real()();
}
