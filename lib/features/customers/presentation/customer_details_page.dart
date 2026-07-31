import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'invoice_details_page.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/customer_sales_provider.dart';
import '../../../core/providers/customers_repository_provider.dart';

import 'widgets/pay_debt_dialog.dart';

class CustomerDetailsPage extends ConsumerStatefulWidget {
  final Customer customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailsPage> createState() =>
      _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage> {
  bool paying = false;

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(customerSalesProvider(widget.customer.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.customer.name)),

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
                      widget.customer.name,

                      style: const TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text("Phone: ${widget.customer.phone ?? '-'}"),

                    const SizedBox(height: 8),

                    Text(
                      "Balance: ${widget.customer.balance} EGP",

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
                onPressed: paying
                    ? null
                    : () async {
                        final amount = await showDialog<double>(
                          context: context,

                          builder: (_) => const PayDebtDialog(),
                        );

                        if (amount == null) return;

                        final newBalance = widget.customer.balance - amount;

                        if (newBalance < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Payment is greater than debt"),
                            ),
                          );

                          return;
                        }

                        setState(() {
                          paying = true;
                        });

                        try {
                          final repo = ref.read(customersRepositoryProvider);

                          await repo
                              .update(
                                widget.customer.copyWith(
                                  balance: newBalance,

                                  updatedAt: DateTime.now(),
                                ),
                              )
                              .timeout(
                                const Duration(seconds: 5),

                                onTimeout: () {
                                  throw Exception("Database timeout");
                                },
                              );

                          ref.invalidate(
                            customerSalesProvider(widget.customer.id),
                          );

                          if (context.mounted) {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Debt paid successfully"),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              paying = false;
                            });
                          }
                        }
                      },

                icon: paying
                    ? const SizedBox(
                        width: 18,

                        height: 18,

                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.payments),

                label: Text(paying ? "Processing..." : "Pay Debt"),
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
