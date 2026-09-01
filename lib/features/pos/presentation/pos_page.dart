import 'package:flutter/material.dart';

import 'widgets/cart_panel.dart';
import 'widgets/product_grid.dart';
import 'widgets/pos_search_bar.dart';
import 'widgets/return_sales_panel.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const PosSearchBar(),
          const SizedBox(height: 16),
          const ReturnSalesPanel(),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  flex: 7,
                  child: ProductGrid(),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 380,
                  child: CartPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
