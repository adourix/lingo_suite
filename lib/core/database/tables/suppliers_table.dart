import 'package:drift/drift.dart';

class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 2, max: 100)();

  TextColumn get phone => text().nullable()();

  TextColumn get email => text().nullable()();
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get address => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
