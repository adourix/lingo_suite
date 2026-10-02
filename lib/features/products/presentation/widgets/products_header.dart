import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/providers/products_provider.dart';
import 'add_product_dialog.dart';

class ProductsHeader extends ConsumerWidget {
  const ProductsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Products', style: AppTextStyles.h1),
              const SizedBox(height: 6),
              Text(
                'Manage your products, prices and inventory.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            try {
              final products = await ref.read(productsProvider.future);

              String csvEscape(String value) {
                return '"${value.replaceAll('"', '""')}"';
              }

              final rows = <String>[
                [
                  'Product',
                  'SKU',
                  'Barcode',
                  'Quantity',
                  'Minimum Quantity',
                  'Cost Price',
                  'Selling Price',
                ].map(csvEscape).join(','),
                ...products.map(
                  (p) => [
                    p.name,
                    p.sku ?? '',
                    p.barcode ?? '',
                    p.quantity.toString(),
                    p.minimumQuantity.toString(),
                    p.costPrice.toStringAsFixed(2),
                    p.sellingPrice.toStringAsFixed(2),
                  ].map(csvEscape).join(','),
                ),
              ];

              final directory = await getTemporaryDirectory();
              final file = File('${directory.path}/lingo_stock.csv');
              await file.writeAsString(
                rows.join('\r\n'),
                encoding: utf8,
              );

              await SharePlus.instance.share(
                ShareParams(
                  files: [XFile(file.path)],
                  text: 'Lingo Store Stock Export',
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export failed: $e')),
              );
            }
          },
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Export'),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AddProductDialog(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
      ],
    );
  }
}
