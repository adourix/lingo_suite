import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/analytics_provider.dart';
import '../../../core/providers/expenses_provider.dart';
import '../../../core/utils/report_filter.dart';
import 'widgets/add_expense_dialog.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.invalidate(totalSalesProvider);
      ref.invalidate(totalCostProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(profitProvider);

      ref.invalidate(financialSummaryProvider);

      ref.invalidate(periodExpensesProvider);
      ref.invalidate(periodInvoicesProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(totalSalesProvider);

    final cost = ref.watch(totalCostProvider);

    final profit = ref.watch(profitProvider);

    final expenses = ref.watch(totalExpensesProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Reports & Analysis",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Business performance overview",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),

                ElevatedButton.icon(
                  onPressed: () async {
                    await showDialog(
                      context: context,

                      builder: (_) => const AddExpenseDialog(),
                    );

                    ref.invalidate(totalExpensesProvider);

                    ref.invalidate(profitProvider);

                    ref.invalidate(financialSummaryProvider);

                    ref.invalidate(periodExpensesProvider);
                  },

                  icon: const Icon(Icons.add),

                  label: const Text("Add Expense"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _periodButtons(context, ref),

            const SizedBox(height: 30),

            GridView.count(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 4,

              crossAxisSpacing: 20,

              mainAxisSpacing: 20,

              childAspectRatio: 1.8,

              children: [
                _statCard("Total Sales", sales, Icons.point_of_sale),

                _statCard("Total Cost", cost, Icons.shopping_cart),

                _statCard("Total Expenses", expenses, Icons.money_off),

                _statCard("Net Profit", profit, Icons.trending_up),
              ],
            ),

            const SizedBox(height: 30),

            _expensesDetails(ref),

            const SizedBox(height: 30),

            _invoicesDetails(ref),
          ],
        ),
      ),
    );
  }

  Widget _periodButtons(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    void setPeriod(DateTime from, DateTime to) {
      ref.read(analyticsPeriodProvider.notifier).state = AnalyticsPeriod(
        from: from,
        to: to,
      );

      ref.invalidate(totalSalesProvider);
      ref.invalidate(totalCostProvider);
      ref.invalidate(profitProvider);
      ref.invalidate(totalExpensesProvider);

      ref.invalidate(financialSummaryProvider);

      ref.invalidate(periodExpensesProvider);
      ref.invalidate(periodInvoicesProvider);
    }

    return Wrap(
      spacing: 10,

      children: [
        _periodButton("Today", () {
          setPeriod(DateTime(now.year, now.month, now.day), now);
        }),

        _periodButton("Week", () {
          setPeriod(now.subtract(const Duration(days: 7)), now);
        }),

        _periodButton("Month", () {
          setPeriod(DateTime(now.year, now.month, 1), now);
        }),

        _periodButton("Custom", () async {
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: now,
          );

          if (range == null) return;

          setPeriod(
            range.start,

            DateTime(
              range.end.year,
              range.end.month,
              range.end.day,
              23,
              59,
              59,
            ),
          );
        }),
      ],
    );
  }

  Widget _periodButton(String text, VoidCallback onPressed) {
    return FilledButton(onPressed: onPressed, child: Text(text));
  }

  Widget _statCard(String title, AsyncValue<double> value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [Text(title), Icon(icon)],
            ),

            const Spacer(),

            value.when(
              data: (v) => Text(
                "${v.toStringAsFixed(0)} EGP",

                style: const TextStyle(
                  fontSize: 24,
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

  Widget _expensesDetails(WidgetRef ref) {
    final expenses = ref.watch(periodExpensesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Expenses Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            expenses.when(
              loading: () => const CircularProgressIndicator(),

              error: (e, _) => Text(e.toString()),

              data: (items) {
                if (items.isEmpty) {
                  return const Text("No expenses in this period");
                }

                return Column(
                  children: [
                    ...items.map(
                      (expense) => ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.money_off),
                        ),

                        title: Text(expense.title),

                        subtitle: Text(expense.category),

                        trailing: Text("${expense.amount} EGP"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoicesDetails(WidgetRef ref) {
    final invoices = ref.watch(periodInvoicesProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  "Invoices Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                FilledButton.icon(
                  icon: const Icon(Icons.cleaning_services),

                  label: const Text("Clear Period"),

                  onPressed: () async {
                    await ReportFilter.clearNow();

                    ref.invalidate(periodInvoicesProvider);

                    ref.invalidate(totalSalesProvider);

                    ref.invalidate(profitProvider);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            invoices.when(
              loading: () => const CircularProgressIndicator(),

              error: (e, _) => Text(e.toString()),

              data: (items) {
                if (items.isEmpty) {
                  return const Text("No invoices in this period");
                }

                final total = items.fold<double>(
                  0,
                  (sum, item) => sum + item.total,
                );

                return Column(
                  children: [
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Period Sales",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),

                          Text(
                            "${total.toStringAsFixed(2)} EGP",

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...items.map(
                      (invoice) => ListTile(
                        onTap: () {
                          _showInvoiceDetails(context, ref, invoice);
                        },

                        leading: const CircleAvatar(
                          child: Icon(Icons.receipt_long),
                        ),

                        title: Text(invoice.invoiceNumber),

                        subtitle: Text(
                          invoice.saleDate.toString().split(".").first,
                        ),

                        trailing: Text(
                          "${invoice.total.toStringAsFixed(2)} EGP",

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetails(
    BuildContext context,
    WidgetRef ref,
    dynamic invoice,
  ) {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: Text(invoice.invoiceNumber),

        content: SizedBox(
          width: 400,

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text("Date: ${invoice.saleDate}"),

              const SizedBox(height: 10),

              Text(
                "Total: ${invoice.total} EGP",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Invoice Items",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text("Items details will be loaded here"),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
