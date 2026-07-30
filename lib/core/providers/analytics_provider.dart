import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sales_repository_provider.dart';
import '../database/app_database.dart';
import '../../features/reports/models/financial_summary.dart';
import '../database/repositories/analytics_repository.dart';
import 'database_provider.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final db = ref.watch(databaseProvider);

  return AnalyticsRepository(db);
});

class AnalyticsPeriod {
  final DateTime from;

  final DateTime to;

  const AnalyticsPeriod({required this.from, required this.to});
}

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) {
  final now = DateTime.now();

  return AnalyticsPeriod(from: DateTime(now.year, now.month, 1), to: now);
});

final totalSalesProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  final period = ref.watch(analyticsPeriodProvider);

  return repo.getTotalSales(from: period.from, to: period.to);
});
final topProductsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  return repo.getTopProducts();
});
final totalCostProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  final period = ref.watch(analyticsPeriodProvider);

  return repo.getTotalCost(from: period.from, to: period.to);
});

final profitProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  final period = ref.watch(analyticsPeriodProvider);

  return repo.getProfit(from: period.from, to: period.to);
});

final customerDebtProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  return repo.getCustomerDebt();
});

final supplierDebtProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  return repo.getSupplierDebt();
});

final stockValueProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  return repo.getStockValue();
});

final salesChartProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  final period = ref.watch(analyticsPeriodProvider);

  return repo.getSalesByDay(from: period.from, to: period.to);
});

final financialSummaryProvider = FutureProvider<FinancialSummary>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  final period = ref.watch(analyticsPeriodProvider);

  return repo.getFinancialSummary(from: period.from, to: period.to);
});

final debtSummaryProvider = FutureProvider<Map<String, double>>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  final customerDebt = await repo.getCustomerDebt();

  final supplierDebt = await repo.getSupplierDebt();

  return {"Customer Debt": customerDebt, "Supplier Debt": supplierDebt};
});

// ===============================
// Dashboard Providers
// ===============================

final totalOrdersProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  return repo.getTotalOrders();
});

final totalCustomersProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  return repo.getTotalCustomers();
});

final recentSalesProvider = FutureProvider<List<Sale>>((ref) async {
  final repo = ref.watch(salesRepositoryProvider);

  final sales = await repo.getAllSales();

  return sales.take(5).toList();
});
final totalProductsProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);

  return repo.getTotalProducts();
});
