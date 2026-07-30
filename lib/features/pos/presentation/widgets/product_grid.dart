import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/pos_search_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/providers/products_provider.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyword = ref.watch(posSearchQueryProvider);

    final productsAsync = ref.watch(productsSearchProvider(keyword));

    return productsAsync.when(
      data: (products) {
        return GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: .82,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return ProductCard(
              product: product,
              onTap: () {
                ref.read(cartProvider.notifier).addProduct(product);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }
}
