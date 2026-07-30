import 'package:drift/drift.dart';

import 'customers_table.dart';

class CustomerPayments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get customerId => integer().references(Customers, #id)();

  RealColumn get amount => real()();

  TextColumn get method => text()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
