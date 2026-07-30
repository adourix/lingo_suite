import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/products_provider.dart';

import './widgets/product_search_bar.dart';
import './widgets/products_header.dart';
import './widgets/products_table.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';
  int? _selectedCategory;
  String? _stockFilter;
  String _barcode = '';
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProductsHeader(),

            const SizedBox(height: 20),

            ProductSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
              onBarcodeSubmitted: (barcode) {
                setState(() {
                  _barcode = barcode.trim();
                });
              },
              onCategoryChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              onStockChanged: (value) {
                setState(() {
                  _stockFilter = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

                data: (products) {
                  List<Product> filteredProducts = products;

                  if (_search.trim().isNotEmpty) {
                    filteredProducts = products.where((product) {
                      return product.name.toLowerCase().contains(
                        _search.toLowerCase(),
                      );
                    }).toList();
                  }
                  if (_barcode.isNotEmpty) {
                    filteredProducts = filteredProducts.where((p) {
                      return (p.barcode ?? '') == _barcode;
                    }).toList();
                  }

                  if (_selectedCategory != null) {
                    filteredProducts = filteredProducts.where((p) {
                      return p.categoryId == _selectedCategory;
                    }).toList();
                  }

                  if (_stockFilter != null && _stockFilter != 'All') {
                    switch (_stockFilter) {
                      case 'In Stock':
                        filteredProducts = filteredProducts.where((p) {
                          return p.quantity > p.minimumQuantity;
                        }).toList();
                        break;

                      case 'Low Stock':
                        filteredProducts = filteredProducts.where((p) {
                          return p.quantity > 0 &&
                              p.quantity <= p.minimumQuantity;
                        }).toList();
                        break;

                      case 'Out of Stock':
                        filteredProducts = filteredProducts.where((p) {
                          return p.quantity == 0;
                        }).toList();
                        break;
                    }
                  }
                  if (_selectedCategory != null) {
                    filteredProducts = filteredProducts.where((p) {
                      return p.categoryId == _selectedCategory;
                    }).toList();
                  }

                  if (_stockFilter != null && _stockFilter != 'All') {
                    switch (_stockFilter) {
                      case 'In Stock':
                        filteredProducts = filteredProducts.where((p) {
                          return p.quantity > p.minimumQuantity;
                        }).toList();
                        break;

                      case 'Low Stock':
                        filteredProducts = filteredProducts.where((p) {
                          return p.quantity > 0 &&
                              p.quantity <= p.minimumQuantity;
                        }).toList();
                        break;

                      case 'Out of Stock':
                        filteredProducts = filteredProducts.where((p) {
                          return p.quantity == 0;
                        }).toList();
                        break;
                    }
                  }
                  return ProductsTable(products: filteredProducts);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
