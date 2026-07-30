import 'package:drift/drift.dart';

import 'sales_table.dart';

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get saleId => integer().references(Sales, #id)();

  TextColumn get method => text()();

  RealColumn get amount => real()();

  TextColumn get reference => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
