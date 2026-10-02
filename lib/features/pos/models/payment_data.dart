enum PaymentMethod { cash, visa, vodafoneCash, instaPay, customerCredit }

class PaymentData {
  final PaymentMethod method;
  final double amount;

  const PaymentData({
    required this.method,
    required this.amount,
  });
}

class PaymentResult {
  final List<PaymentData> payments;
  final double change;

  const PaymentResult({
    required this.payments,
    required this.change,
  });
}
