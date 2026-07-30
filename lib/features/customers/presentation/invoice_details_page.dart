import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/sale_items_provider.dart';

class InvoiceDetailsPage extends ConsumerWidget {
  final Sale invoice;

  const InvoiceDetailsPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(saleItemsProvider(invoice.id));

    return Scaffold(
      appBar: AppBar(title: Text(invoice.invoiceNumber)),

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
                      "Invoice: ${invoice.invoiceNumber}",

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text("Subtotal: ${invoice.subtotal} EGP"),

                    Text("Discount: ${invoice.discount} EGP"),

                    Text("Tax: ${invoice.tax} EGP"),

                    Text(
                      "Total: ${invoice.total} EGP",

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text("Paid: ${invoice.paid} EGP"),

                    Text("Remaining: ${invoice.remaining} EGP"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Items",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: items.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text("No items"));
                  }

                  return ListView.builder(
                    itemCount: items.length,

                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Card(
                        child: ListTile(
                          title: Text(item.itemName),

                          subtitle: Text(
                            "Qty: ${item.quantity}\n"
                            "Price: ${item.unitPrice} EGP",
                          ),

                          trailing: Text("${item.total} EGP"),
                        ),
                      );
                    },
                  );
                },

                loading: () => const Center(child: CircularProgressIndicator()),

                error: (e, _) => Text(e.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
