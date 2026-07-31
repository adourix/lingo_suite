import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/repositories/expenses_repository.dart';

import 'analytics_provider.dart';
import 'database_provider.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  final db = ref.watch(databaseProvider);

  return ExpensesRepository(db);
});

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final repo = ref.watch(expensesRepositoryProvider);

  return repo.watchAll();
});

final totalExpensesProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(expensesRepositoryProvider);

  final period = ref.watch(analyticsPeriodProvider);

  return repo.totalExpenses(from: period.from, to: period.to);
});
