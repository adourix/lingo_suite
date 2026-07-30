import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/categories_provider.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

class ProductSearchBar extends ConsumerWidget {
  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onCategoryChanged,
    required this.onStockChanged,
    required this.onBarcodeSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onBarcodeSubmitted;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<String?> onStockChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search product...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          flex: 2,
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Scan barcode...',
              prefixIcon: const Icon(Icons.qr_code_scanner),
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onSubmitted: onBarcodeSubmitted,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        SizedBox(
          width: 180,
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text("Error"),
            data: (categories) {
              return DropdownButtonFormField<int?>(
                initialValue: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text("All Categories"),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: onCategoryChanged,
              );
            },
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        SizedBox(
          width: 170,
          child: DropdownButtonFormField<String>(
            initialValue: 'All',
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Stock')),
              DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
              DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock')),
              DropdownMenuItem(
                value: 'Out of Stock',
                child: Text('Out of Stock'),
              ),
            ],
            onChanged: onStockChanged,
          ),
        ),
      ],
    );
  }
}
