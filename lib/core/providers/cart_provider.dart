import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/pos/models/cart_item.dart';
import '../database/app_database.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final index = state.indexWhere(
      (e) => e.type == CartItemType.product && e.product?.id == product.id,
    );

    if (index != -1) {
      final item = state[index];

      final updated = item.copyWith(quantity: item.quantity + 1);

      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];

      return;
    }

    state = [
      ...state,
      CartItem(
        type: CartItemType.product,
        product: product,
        name: product.name,
        price: product.sellingPrice,
      ),
    ];
  }

  void addService({
    required String name,
    required double price,
    int quantity = 1,
  }) {
    state = [
      ...state,
      CartItem(
        type: CartItemType.service,
        name: name,
        price: price,
        quantity: quantity,
      ),
    ];
  }

  void increase(int index) {
    final item = state[index];

    if (item.product != null) {
      if (item.quantity >= item.product!.quantity) {
        return;
      }
    }

    state = [
      ...state.sublist(0, index),
      item.copyWith(quantity: item.quantity + 1),
      ...state.sublist(index + 1),
    ];
  }

  void decrease(int index) {
    final item = state[index];

    if (item.quantity == 1) {
      remove(index);
      return;
    }

    state = [
      ...state.sublist(0, index),
      item.copyWith(quantity: item.quantity - 1),
      ...state.sublist(index + 1),
    ];
  }

  void remove(int index) {
    final list = [...state];
    list.removeAt(index);
    state = list;
  }

  void clear() {
    state = [];
  }

  double get subtotal => state.fold(0, (a, b) => a + b.subtotal);

  int get itemsCount => state.fold(0, (a, b) => a + b.quantity);
}
