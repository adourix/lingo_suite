import 'package:drift/drift.dart';

import 'users_table.dart';

class ActivityLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #id)();

  TextColumn get action => text()();

  TextColumn get entity => text()();

  IntColumn get entityId => integer().nullable()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
