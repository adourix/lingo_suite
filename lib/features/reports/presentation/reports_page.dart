import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/providers/analytics_provider.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(totalSalesProvider);

    final cost = ref.watch(totalCostProvider);

    final profit = ref.watch(profitProvider);

    final customerDebt = ref.watch(customerDebtProvider);

    final supplierDebt = ref.watch(supplierDebtProvider);

    final stock = ref.watch(stockValueProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Reports & Analysis",

              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _periodButtons(context, ref),

            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  GridView.count(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    crossAxisCount: 3,

                    crossAxisSpacing: 16,

                    mainAxisSpacing: 16,

                    children: [
                      _card("Total Sales", sales),

                      _card("Total Cost", cost),

                      _card("Net Profit", profit),

                      _card("Customer Debt", customerDebt),

                      _card("Supplier Debt", supplierDebt),

                      _card("Stock Value", stock),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _salesChart(ref),

                  const SizedBox(height: 24),

                  _financialChart(ref),

                  const SizedBox(height: 24),

                  _debtChart(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debtChart(WidgetRef ref) {
    final debt = ref.watch(debtSummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: SizedBox(
          height: 320,

          child: debt.when(
            data: (data) {
              final customer = data["Customer Debt"] ?? 0;

              final supplier = data["Supplier Debt"] ?? 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Debt Overview",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 45,

                        sectionsSpace: 3,

                        sections: [
                          PieChartSectionData(
                            value: customer,

                            title: "Customers\n${customer.toStringAsFixed(0)}",

                            radius: 90,
                          ),

                          PieChartSectionData(
                            value: supplier,

                            title: "Suppliers\n${supplier.toStringAsFixed(0)}",

                            radius: 90,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },

            loading: () => const Center(child: CircularProgressIndicator()),

            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ),
      ),
    );
  }

  Widget _periodButtons(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 10,

      children: [
        ElevatedButton(
          onPressed: () {
            final now = DateTime.now();

            ref.read(analyticsPeriodProvider.notifier).state = AnalyticsPeriod(
              from: DateTime(now.year, now.month, now.day),

              to: now,
            );
          },

          child: const Text("Today"),
        ),

        ElevatedButton(
          onPressed: () {
            final now = DateTime.now();

            ref.read(analyticsPeriodProvider.notifier).state = AnalyticsPeriod(
              from: now.subtract(const Duration(days: 7)),

              to: now,
            );
          },

          child: const Text("Week"),
        ),

        ElevatedButton(
          onPressed: () {
            final now = DateTime.now();

            ref.read(analyticsPeriodProvider.notifier).state = AnalyticsPeriod(
              from: DateTime(now.year, now.month, 1),

              to: now,
            );
          },

          child: const Text("Month"),
        ),

        ElevatedButton(
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,

              firstDate: DateTime(2020),

              lastDate: DateTime.now(),
            );

            if (range == null) return;

            ref.read(analyticsPeriodProvider.notifier).state = AnalyticsPeriod(
              from: range.start,

              to: range.end,
            );
          },

          child: const Text("Custom"),
        ),
      ],
    );
  }

  Widget _salesChart(WidgetRef ref) {
    final chart = ref.watch(salesChartProvider);

    return Card(
      child: SizedBox(
        height: 300,

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: chart.when(
            data: (data) {
              return LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) {
                        return FlSpot(
                          e.key.toDouble(),

                          (e.value["total"] as num).toDouble(),
                        );
                      }).toList(),

                      isCurved: true,
                    ),
                  ],
                ),
              );
            },

            loading: () => const CircularProgressIndicator(),

            error: (e, _) => Text(e.toString()),
          ),
        ),
      ),
    );
  }

  Widget _financialChart(WidgetRef ref) {
    final summary = ref.watch(financialSummaryProvider);

    return Card(
      child: SizedBox(
        height: 300,

        child: summary.when(
          data: (data) {
            return BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(
                    x: 0,

                    barRods: [BarChartRodData(toY: data.sales)],
                  ),

                  BarChartGroupData(
                    x: 1,

                    barRods: [BarChartRodData(toY: data.cost)],
                  ),

                  BarChartGroupData(
                    x: 2,

                    barRods: [BarChartRodData(toY: data.profit)],
                  ),
                ],
              ),
            );
          },

          loading: () => const CircularProgressIndicator(),

          error: (e, _) => Text(e.toString()),
        ),
      ),
    );
  }

  Widget _card(String title, AsyncValue<double> value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(title),

            const Spacer(),

            value.when(
              data: (v) => Text(
                "${v.toStringAsFixed(2)} EGP",

                style: const TextStyle(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),
              ),

              loading: () => const CircularProgressIndicator(),

              error: (e, _) => Text(e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
