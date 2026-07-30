import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../../features/reports/models/financial_summary.dart';

class AnalyticsRepository {
  final AppDatabase db;

  AnalyticsRepository(this.db);

  Future<double> getTotalSales({
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await db
        .customSelect(
          '''
      SELECT SUM(total) as total
      FROM sales
      WHERE sale_date >= ?
      AND sale_date <= ?
      AND is_returned = 0
      ''',

          variables: [Variable.withDateTime(from), Variable.withDateTime(to)],
        )
        .getSingle();

    return result.read<double?>('total') ?? 0;
  }

  Future<double> getTotalCost({
    required DateTime from,

    required DateTime to,
  }) async {
    final result = await db
        .customSelect(
          '''
      SELECT 
      SUM(si.quantity * si.cost_price) as cost

      FROM sale_items si

      JOIN sales s

      ON s.id = si.sale_id

      WHERE s.sale_date >= ?

      AND s.sale_date <= ?

      ''',

          variables: [Variable.withDateTime(from), Variable.withDateTime(to)],
        )
        .getSingle();

    return result.read<double?>('cost') ?? 0;
  }

  Future<double> getProfit({
    required DateTime from,

    required DateTime to,
  }) async {
    final sales = await getTotalSales(from: from, to: to);

    final cost = await getTotalCost(from: from, to: to);

    return sales - cost;
  }

  Future<List<Map<String, dynamic>>> getSalesByDay({
    required DateTime from,

    required DateTime to,
  }) async {
    final result = await db
        .customSelect(
          '''
      SELECT

      DATE(sale_date) as day,

      SUM(total) as total


      FROM sales


      WHERE sale_date >= ?

      AND sale_date <= ?

      AND is_returned = 0


      GROUP BY DATE(sale_date)


      ORDER BY DATE(sale_date)

      ''',

          variables: [Variable.withDateTime(from), Variable.withDateTime(to)],
        )
        .get();

    return result.map((row) {
      return {
        "day": row.read<String>('day'),

        "total": row.read<double?>('total') ?? 0,
      };
    }).toList();
  }

  Future<double> getCustomerDebt() async {
    final result = await db.customSelect('''
      SELECT SUM(balance) as debt
      FROM customers
      ''').getSingle();

    return result.read<double?>('debt') ?? 0;
  }

  Future<double> getSupplierDebt() async {
    final result = await db.customSelect('''
      SELECT SUM(balance) as debt
      FROM suppliers
      ''').getSingle();

    return result.read<double?>('debt') ?? 0;
  }

  Future<double> getStockValue() async {
    final result = await db.customSelect('''
      SELECT

      SUM(quantity * cost_price) as value

      FROM products

      ''').getSingle();

    return result.read<double?>('value') ?? 0;
  }

  Future<FinancialSummary> getFinancialSummary({
    required DateTime from,

    required DateTime to,
  }) async {
    final sales = await getTotalSales(from: from, to: to);

    final cost = await getTotalCost(from: from, to: to);

    return FinancialSummary(sales: sales, cost: cost, profit: sales - cost);
  }

  // ============================
  // Dashboard Statistics
  // ============================

  Future<int> getTotalOrders() async {
    final result = await db.customSelect('''
      SELECT COUNT(*) as count
      FROM sales
      ''').getSingle();

    return result.read<int>('count');
  }

  Future<int> getTotalCustomers() async {
    final result = await db.customSelect('''
      SELECT COUNT(*) as count
      FROM customers
      ''').getSingle();

    return result.read<int>('count');
  }

  Future<int> getTotalProducts() async {
    final result = await db.customSelect('''
      SELECT COUNT(*) as count
      FROM products
      WHERE is_active = 1
      ''').getSingle();

    return result.read<int>('count');
  }

  Future<List<Map<String, dynamic>>> getTopProducts() async {
    final result = await db.customSelect('''
    SELECT 
      p.name as name,
      SUM(si.quantity) as quantity,
      SUM(si.total) as revenue

    FROM sale_items si

    JOIN products p

    ON p.id = si.product_id

    JOIN sales s

    ON s.id = si.sale_id

    WHERE s.is_returned = 0

    GROUP BY p.id

    ORDER BY quantity DESC

    LIMIT 5
    ''').get();

    return result.map((row) {
      return {
        "name": row.read<String>('name'),

        "quantity": row.read<int?>('quantity') ?? 0,

        "revenue": row.read<double?>('revenue') ?? 0,
      };
    }).toList();
  }
}
