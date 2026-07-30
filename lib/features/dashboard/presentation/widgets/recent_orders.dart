import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../../../core/providers/analytics_provider.dart';

class RecentOrders extends ConsumerWidget {
  const RecentOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(recentSalesProvider);

    return Container(
      padding: AppSpacing.card,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text("Recent Orders", style: AppTextStyles.h3),

          const SizedBox(height: 20),

          sales.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Text("No orders yet");
              }

              return Column(
                children: orders.take(5).map((sale) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(sale.invoiceNumber.substring(0, 1)),
                    ),

                    title: Text(sale.invoiceNumber),

                    subtitle: Text(sale.saleDate.toString()),

                    trailing: Text("${sale.total} EGP"),
                  );
                }).toList(),
              );
            },

            loading: () {
              return const CircularProgressIndicator();
            },

            error: (e, _) {
              return Text(e.toString());
            },
          ),
        ],
      ),
    );
  }
}
