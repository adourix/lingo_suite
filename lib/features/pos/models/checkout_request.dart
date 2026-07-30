import 'cart_item.dart';
import 'payment_data.dart';

class CheckoutRequest {
  final List<CartItem> items;

  final int userId;

  final int? customerId;

  final List<PaymentData> payments;

  final double discount;

  final double tax;

  final String? notes;

  const CheckoutRequest({
    required this.items,

    required this.userId,

    required this.payments,

    this.customerId,

    this.discount = 0,

    this.tax = 0,

    this.notes,
  });
}
