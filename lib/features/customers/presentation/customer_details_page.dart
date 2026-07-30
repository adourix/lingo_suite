import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'invoice_details_page.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/customer_sales_provider.dart';
import 'widgets/pay_debt_dialog.dart';
import '../../../core/providers/customers_repository_provider.dart';

class CustomerDetailsPage extends ConsumerWidget {
  final Customer customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(customerSalesProvider(customer.id));

    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      customer.name,

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text("Phone: ${customer.phone ?? '-'}"),

                    const SizedBox(height: 8),

                    Text(
                      "Balance: ${customer.balance} EGP",

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  final amount = await showDialog<double>(
                    context: context,

                    builder: (_) => const PayDebtDialog(),
                  );

                  if (amount == null) return;

                  final repo = ref.read(customersRepositoryProvider);

                  final newBalance = customer.balance - amount;

                  if (newBalance < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Payment is greater than debt"),
                      ),
                    );

                    return;
                  }

                  await repo.update(
                    customer.copyWith(
                      balance: newBalance,

                      updatedAt: DateTime.now(),
                    ),
                  );

                  ref.invalidate(customerSalesProvider(customer.id));

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },

                icon: const Icon(Icons.payments),

                label: const Text("Pay Debt"),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Invoices",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: sales.when(
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return const Center(child: Text("No invoices"));
                  }

                  return ListView.builder(
                    itemCount: invoices.length,

                    itemBuilder: (context, index) {
                      final invoice = invoices[index];

                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    InvoiceDetailsPage(invoice: invoice),
                              ),
                            );
                          },
                          title: Text(invoice.invoiceNumber),

                          subtitle: Text(
                            "Total: ${invoice.total} EGP\n"
                            "Paid: ${invoice.paid} EGP\n"
                            "Remaining: ${invoice.remaining} EGP",
                          ),
                        ),
                      );
                    },
                  );
                },

                loading: () => const Center(child: CircularProgressIndicator()),

                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
