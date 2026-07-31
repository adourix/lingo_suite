import 'package:drift/drift.dart';

import '../app_database.dart';

class ExpensesRepository {
  final AppDatabase db;

  ExpensesRepository(this.db);

  // Add Expense

  Future<int> insert(ExpensesCompanion expense) {
    return db.into(db.expenses).insert(expense);
  }

  // Watch Expenses (Realtime)

  Stream<List<Expense>> watchAll() {
    return db.select(db.expenses).watch();
  }

  // Get All Expenses

  Future<List<Expense>> getAll() {
    return db.select(db.expenses).get();
  }

  // Get Expense By Id

  Future<Expense?> getById(int id) {
    return (db.select(
      db.expenses,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  // Total Expenses

  Future<double> totalExpenses({
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await db
        .customSelect(
          '''
    SELECT COALESCE(SUM(amount),0) AS total
    FROM expenses

    WHERE expense_date >= ?
    AND expense_date <= ?

    ''',
          variables: [Variable.withDateTime(from), Variable.withDateTime(to)],
        )
        .getSingle();

    return result.read<double>('total');
  }

  // Delete Expense

  Future<int> delete(int id) {
    return (db.delete(db.expenses)..where((e) => e.id.equals(id))).go();
  }

  // Update Expense

  Future<bool> update(Expense expense) {
    return db.update(db.expenses).replace(expense);
  }

  Future<List<Expense>> getExpensesByDate({
    required DateTime from,
    required DateTime to,
  }) {
    return (db.select(db.expenses)
          ..where((e) => e.expenseDate.isBetweenValues(from, to))
          ..orderBy([
            (e) => OrderingTerm(
              expression: e.expenseDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }
}
