import 'package:drift/drift.dart';

import 'users_table.dart';

class CashSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #id)();

  RealColumn get openingBalance => real()();

  RealColumn get closingBalance => real().nullable()();

  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get closedAt => dateTime().nullable()();

  BoolColumn get isClosed => boolean().withDefault(const Constant(false))();
}
