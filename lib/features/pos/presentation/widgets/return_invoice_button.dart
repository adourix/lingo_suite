import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/sales_repository_provider.dart';
import '../../../../core/providers/auth_provider.dart';

class ReturnInvoiceButton extends ConsumerWidget {
  const ReturnInvoiceButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.assignment_return),
      label: const Text('Return Invoice'),
      onPressed: () async {
        final controller = TextEditingController();
        final repo = ref.read(salesRepositoryProvider);

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Find Invoice'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Invoice number',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Search'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        final sale = await repo.getSaleByInvoiceNumber(controller.text.trim());

        if (!context.mounted) return;

        if (sale == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice not found')),
          );
          return;
        }

        final shouldReturn = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(sale.invoiceNumber),
            content: Text(
              'Total: ${sale.total}\n\nConfirm returning this invoice?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Return'),
              ),
            ],
          ),
        );

        if (shouldReturn != true) return;

        try {
          await repo.returnSale(sale.id, ref.read(authUserProvider)!.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invoice returned successfully')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      },
    );
  }
}
