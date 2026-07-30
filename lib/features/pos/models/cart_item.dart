import '../../../core/database/app_database.dart';

enum CartItemType { product, service }

class CartItem {
  final CartItemType type;

  final Product? product;

  final String name;

  final double price;

  final int quantity;

  final double discount;

  const CartItem({
    required this.type,
    this.product,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.discount = 0,
  });

  double get subtotal => (price * quantity) - discount;

  CartItem copyWith({
    Product? product,
    String? name,
    double? price,
    int? quantity,
    double? discount,
  }) {
    return CartItem(
      type: type,
      product: product ?? this.product,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }
}
