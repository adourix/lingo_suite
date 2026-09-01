import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/repositories/sales_delete_extension.dart';
import '../../../core/database/repositories/sales_return_extension.dart';
import '../../../core/providers/invoices_provider.dart';
import '../../../core/providers/sales_repository_provider.dart';
import '../../../core/providers/sale_items_provider.dart';

class InvoiceDetailsPage extends ConsumerWidget {
  final Sale invoice;

  const InvoiceDetailsPage({super.key, required this.invoice});

  Future<void> _returnInvoice(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Invoice'),
        content: const Text('This will return stock and reverse the invoice. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final repo = ref.read(salesRepositoryProvider);
    await repo.returnSaleCompletely(invoice.id);
    ref.invalidate(invoicesProvider);

    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _deleteInvoice(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('This will remove the invoice completely and restore stock. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    final repo = ref.read(salesRepositoryProvider);
    await repo.deleteSaleCompletely(invoice.id);
    ref.invalidate(invoicesProvider);

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(saleItemsProvider(invoice.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          if (!invoice.isReturned)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Return invoice',
              onPressed: () => _returnInvoice(context, ref),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteInvoice(context, ref),
          ),
        ],
      ),
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
                    Text('Invoice: ${invoice.invoiceNumber}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Subtotal: ${invoice.subtotal} EGP'),
                    Text('Discount: ${invoice.discount} EGP'),
                    Text('Tax: ${invoice.tax} EGP'),
                    Text('Total: ${invoice.total} EGP'),
                    Text('Paid: ${invoice.paid} EGP'),
                    Text('Remaining: ${invoice.remaining} EGP'),
                    if (invoice.isReturned) const Text('RETURNED'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: items.when(
                data: (items) => ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.itemName),
                      subtitle: Text('Qty: ${item.quantity}\nPrice: ${item.unitPrice} EGP'),
                      trailing: Text('${item.total} EGP'),
                    );
                  },
                ),
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
