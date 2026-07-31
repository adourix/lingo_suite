import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/providers/analytics_provider.dart';

class RecentOrders extends ConsumerWidget {
  const RecentOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(recentSalesProvider);

    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text("Recent Orders", style: AppTextStyles.h3),

              Icon(Icons.receipt_long_outlined, color: AppColors.primary),
            ],
          ),

          const SizedBox(height: 20),

          sales.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(child: Text("No orders yet"));
              }

              return Column(
                children: orders.take(5).map((sale) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,

                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 45,

                          height: 45,

                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,

                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Icon(
                            Icons.receipt_outlined,

                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                sale.invoiceNumber,

                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                sale.saleDate.toString(),

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,

                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            "${sale.total.toStringAsFixed(0)} EGP",

                            style: TextStyle(
                              color: AppColors.success,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },

            loading: () => const Center(child: CircularProgressIndicator()),

            error: (e, _) => Text(e.toString()),
          ),
        ],
      ),
    );
  }
}
