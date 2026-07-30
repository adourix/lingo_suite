import 'package:drift/drift.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get category => text()();

  RealColumn get amount => real()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get expenseDate =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
