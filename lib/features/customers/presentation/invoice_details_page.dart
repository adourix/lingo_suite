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
      builder: (_) => AlertDialog(
        title: const Text('Return Invoice'),
        content: const Text('Return stock and reverse this invoice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Return')),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(salesRepositoryProvider).returnSaleCompletely(invoice.id);
    ref.invalidate(invoicesProvider);
    ref.invalidate(saleItemsProvider(invoice.id));

    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _deleteInvoice(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Delete this invoice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(salesRepositoryProvider).deleteSaleCompletely(invoice.id);
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
            Text('Invoice: ${invoice.invoiceNumber}'),
            Text('Total: ${invoice.total} EGP'),
            if (invoice.isReturned) const Text('RETURNED'),
            Expanded(
              child: items.when(
                data: (data) => ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (_, i) => ListTile(title: Text(data[i].itemName)),
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
