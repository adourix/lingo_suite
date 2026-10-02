import 'package:drift/drift.dart';

import '../../auth/auth_models.dart';
import '../app_database.dart';

class ExpensesRepository {
  final AppDatabase db;
  final int? actorId;

  ExpensesRepository(this.db, {required this.actorId});

  Future<void> _authorize() async {
    final actor = actorId == null ? null :
        await (db.select(db.users)..where((u) => u.id.equals(actorId!))).getSingleOrNull();
    if (actor == null || !actor.isActive ||
        !Permissions.can(actor.role, Permissions.reports)) {
      throw StateError('User is not authorized to manage expenses');
    }
  }

  Future<void> _audit(String action, int entityId, String description) async {
    if (actorId == null) return;
    await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
      userId: actorId!, action: action, entity: 'expense',
      entityId: Value(entityId), description: Value(description),
    ));
  }

  Future<int> insert(ExpensesCompanion expense) async {
    await _authorize();
    final id = await db.into(db.expenses).insert(expense);
    await _audit('create', id, 'Created expense');
    return id;
  }

  Stream<List<Expense>> watchAll() => db.select(db.expenses).watch();
  Future<List<Expense>> getAll() => db.select(db.expenses).get();

  Future<Expense?> getById(int id) =>
      (db.select(db.expenses)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<double> totalExpenses({required DateTime from, required DateTime to}) async {
    final result = await db.customSelect('''
      SELECT COALESCE(SUM(amount),0) AS total
      FROM expenses WHERE expense_date >= ? AND expense_date <= ?
    ''', variables: [Variable.withDateTime(from), Variable.withDateTime(to)]).getSingle();
    return result.read<double>('total');
  }

  Future<int> delete(int id) async {
    await _authorize();
    final result = await (db.delete(db.expenses)..where((e) => e.id.equals(id))).go();
    if (result > 0) await _audit('delete', id, 'Deleted expense');
    return result;
  }

  Future<bool> update(Expense expense) async {
    await _authorize();
    final changed = await db.update(db.expenses).replace(expense);
    if (changed) await _audit('update', expense.id, 'Updated expense');
    return changed;
  }

  Future<List<Expense>> getExpensesByDate({required DateTime from, required DateTime to}) =>
      (db.select(db.expenses)
        ..where((e) => e.expenseDate.isBetweenValues(from, to))
        ..orderBy([(e) => OrderingTerm(expression: e.expenseDate, mode: OrderingMode.desc)]))
      .get();
}
