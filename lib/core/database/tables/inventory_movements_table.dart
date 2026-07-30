import 'package:drift/drift.dart';

import 'products_table.dart';

class InventoryMovements extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get productId => integer().references(Products, #id)();

  TextColumn get type => text()();

  IntColumn get quantity => integer()();

  TextColumn get referenceType => text().nullable()();

  IntColumn get referenceId => integer().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
