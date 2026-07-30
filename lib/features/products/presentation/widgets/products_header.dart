import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'add_product_dialog.dart';

class ProductsHeader extends StatelessWidget {
  const ProductsHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AddProductDialog(),
            );
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
