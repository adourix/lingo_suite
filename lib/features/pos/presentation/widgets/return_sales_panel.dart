import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/sales_repository_provider.dart';

class ReturnSalesPanel extends ConsumerWidget {
  const ReturnSalesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(salesRepositoryProvider);

    return FutureBuilder(
      future: repo.getAllSales(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final sales = snapshot.data!.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Invoices'),
            ...sales.map((sale) => ListTile(
              title: Text(sale.invoiceNumber),
              trailing: sale.isReturned
                  ? const Text('Returned')
                  : TextButton(
                      onPressed: () async {
                        await repo.returnSale(sale.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invoice returned')),
                          );
                        }
                      },
                      child: const Text('Return'),
                    ),
            )),
          ],
        );
      },
    );
  }
}
