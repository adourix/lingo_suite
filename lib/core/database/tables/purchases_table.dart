import 'package:drift/drift.dart';

import 'suppliers_table.dart';

class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get invoiceNumber => text()();

  IntColumn get supplierId => integer().references(Suppliers, #id)();

  RealColumn get total => real()();

  RealColumn get paid => real().withDefault(const Constant(0))();

  RealColumn get remaining => real().withDefault(const Constant(0))();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get purchaseDate =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
