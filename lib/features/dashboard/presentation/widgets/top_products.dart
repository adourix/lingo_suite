import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/providers/analytics_provider.dart';

class TopProducts extends ConsumerWidget {
  const TopProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(topProductsProvider);

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text("Top Products", style: AppTextStyles.h3),

                Icon(
                  Icons.trending_up_rounded,

                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            products.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text("No products yet"));
                }

                return Column(
                  children: data.take(5).map((p) {
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
                            width: 44,

                            height: 44,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),

                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12),
                            ),

                            child: Icon(
                              Icons.inventory_2_outlined,

                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  p["name"],

                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "Sold: ${p["quantity"]}",

                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "${p["revenue"].toStringAsFixed(0)} EGP",

                            style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
