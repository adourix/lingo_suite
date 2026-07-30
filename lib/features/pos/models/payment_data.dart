enum PaymentMethod { cash, visa, vodafoneCash, instaPay, customerCredit }

class PaymentData {
  final PaymentMethod method;

  final double amount;

  final int? customerId;

  const PaymentData({
    required this.method,

    required this.amount,

    this.customerId,
  });
}
