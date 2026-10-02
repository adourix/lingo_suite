import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              Text('Manage your products, prices and inventory.', style: AppTextStyles.body),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            try {
              final products = await ref.read(productsProvider.future);

              String csvEscape(String value) {
                return '"' + value.replaceAll('"', '""') + '"';
              }

              final totalQuantity = products.fold<int>(0, (sum, p) => sum + p.quantity);
              final totalPrice = products.fold<double>(0, (sum, p) => sum + (p.quantity * p.sellingPrice));
              final totalCost = products.fold<double>(0, (sum, p) => sum + (p.quantity * p.costPrice));
              final totalProfit = totalPrice - totalCost;

              final rows = <String>[
                [
                  'Product', 'SKU', 'Barcode', 'Quantity', 'Minimum Quantity',
                  'Cost Price', 'Selling Price', 'Profit',
                ].map(csvEscape).join(','),
                ...products.map((p) {
                  final profit = (p.sellingPrice - p.costPrice) * p.quantity;
                  return [
                    p.name, p.sku ?? '', p.barcode ?? '', p.quantity.toString(),
                    p.minimumQuantity.toString(), p.costPrice.toStringAsFixed(2),
                    p.sellingPrice.toStringAsFixed(2), profit.toStringAsFixed(2),
                  ].map(csvEscape).join(',');
                }),
                '',
                [
                  'TOTAL', '', '', totalQuantity.toString(), '',
                  totalCost.toStringAsFixed(2), totalPrice.toStringAsFixed(2),
                  totalProfit.toStringAsFixed(2),
                ].map(csvEscape).join(','),
              ];

              final csvBytes = utf8.encode(rows.join('\r\n'));
              await SharePlus.instance.share(
                ShareParams(
                  files: [
                    XFile.fromData(csvBytes, name: 'lingo_stock.csv', mimeType: 'text/csv'),
                  ],
                  text: 'Lingo Store Stock Export',
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export failed: ' + e.toString())),
              );
            }
          },
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Export'),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
          onPressed: () {
            showDialog(context: context, builder: (_) => const AddProductDialog());
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
      ],
    );
  }
}