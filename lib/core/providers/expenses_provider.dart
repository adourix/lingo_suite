import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/repositories/expenses_repository.dart';

import 'database_provider.dart';
import 'analytics_provider.dart';

// Repository

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  final db = ref.watch(databaseProvider);

  return ExpensesRepository(db);
});

// All Expenses Stream

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final repo = ref.watch(expensesRepositoryProvider);

  return repo.watchAll();
});

// Expenses By Selected Period

final periodExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = ref.watch(expensesRepositoryProvider);

  final period = ref.watch(analyticsPeriodProvider);

  return repo.getExpensesByDate(from: period.from, to: period.to);
});

// Total Expenses By Selected Period

final totalExpensesProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(expensesRepositoryProvider);

  final period = ref.watch(analyticsPeriodProvider);

  return repo.totalExpenses(from: period.from, to: period.to);
});
