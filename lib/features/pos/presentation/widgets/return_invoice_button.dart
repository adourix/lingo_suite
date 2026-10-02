import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/sales_repository_provider.dart';

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

        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Return Invoice'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Invoice number',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final sale = await repo.getSaleByInvoiceNumber(controller.text);
                  if (sale == null) return;
                  await repo.returnSale(sale.id);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Return'),
              ),
            ],
          ),
        );
      },
    );
  }
}
