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
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text("Top Products", style: AppTextStyles.h3),

            const SizedBox(height: 16),

            products.when(
              data: (data) => Column(
                children: data.map((p) {
                  return ListTile(
                    leading: const Icon(Icons.inventory_2),

                    title: Text(p["name"]),

                    subtitle: Text("Qty: ${p["quantity"]}"),

                    trailing: Text("${p["revenue"].toStringAsFixed(0)} EGP"),
                  );
                }).toList(),
              ),

              loading: () => const CircularProgressIndicator(),

              error: (e, _) => Text(e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
