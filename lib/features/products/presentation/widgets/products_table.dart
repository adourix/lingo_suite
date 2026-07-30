import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/product_actions_provider.dart';

import '../widgets/add_product_dialog.dart';

class ProductsTable extends ConsumerWidget {
  final List<Product> products;

  const ProductsTable({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 30,
          headingRowHeight: 55,
          dataRowMinHeight: 70,
          dataRowMaxHeight: 70,
          columns: const [
            DataColumn(label: Text("Image")),
            DataColumn(label: Text("SKU")),
            DataColumn(label: Text("Barcode")),
            DataColumn(label: Text("Product")),
            DataColumn(label: Text("Cost")),
            DataColumn(label: Text("Selling")),
            DataColumn(label: Text("Qty")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Actions")),
          ],
          rows: products.map((p) {
            return DataRow(
              cells: [
                DataCell(
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                DataCell(Text(p.sku ?? "-", style: AppTextStyles.bodySmall)),

                DataCell(
                  Text(p.barcode ?? "-", style: AppTextStyles.bodySmall),
                ),

                DataCell(Text(p.name, style: AppTextStyles.bodyMedium)),

                DataCell(Text("${p.costPrice.toStringAsFixed(2)} EGP")),

                DataCell(
                  Text(
                    "${p.sellingPrice.toStringAsFixed(2)} EGP",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                DataCell(Text("${p.quantity}")),

                DataCell(
                  _StatusBadge(stock: p.quantity, minimum: p.minimumQuantity),
                ),

                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AddProductDialog(product: p),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Product"),
                              content: const Text(
                                "Are you sure you want to delete this product?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );

                          if (ok == true) {
                            await ref.read(productActionsProvider).delete(p.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.stock, required this.minimum});

  final int stock;
  final int minimum;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (stock == 0) {
      color = Colors.red;
      text = "Out";
    } else if (stock <= minimum) {
      color = Colors.orange;
      text = "Low";
    } else {
      color = Colors.green;
      text = "Available";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
