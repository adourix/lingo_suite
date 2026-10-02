import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/providers/products_provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
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
            final products = await ref.read(productsProvider.future);
            final document = pw.Document();
            document.addPage(
              pw.MultiPage(
                pageFormat: PdfPageFormat.a4,
                build: (_) => [
                  pw.Text(
                    'Lingo Store - Stock Export',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.TableHelper.fromTextArray(
                    headers: ['Product', 'SKU', 'Barcode', 'Qty', 'Min Qty', 'Cost', 'Price'],
                    data: products.map((p) => [
                      p.name,
                      p.sku ?? '-',
                      p.barcode ?? '-',
                      p.quantity.toString(),
                      p.minimumQuantity.toString(),
                      p.costPrice.toStringAsFixed(2),
                      p.sellingPrice.toStringAsFixed(2),
                    ]).toList(),
                  ),
                ],
              ),
            );
            await Printing.sharePdf(
              bytes: await document.save(),
              filename: 'lingo_stock.pdf',
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
