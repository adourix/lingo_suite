import 'package:drift/drift.dart';

import 'customers_table.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get invoiceNumber => text().unique()();

  IntColumn get customerId => integer().references(Customers, #id).nullable()();

  IntColumn get userId => integer()();
  TextColumn get status => text().withDefault(const Constant('completed'))();

  RealColumn get subtotal => real()();

  RealColumn get discount => real().withDefault(const Constant(0))();
  BoolColumn get isReturned => boolean().withDefault(const Constant(false))();
  RealColumn get tax => real().withDefault(const Constant(0))();

  RealColumn get total => real()();

  RealColumn get paid => real().withDefault(const Constant(0))();

  RealColumn get remaining => real().withDefault(const Constant(0))();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get saleDate => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
