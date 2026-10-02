enum PaymentMethod { cash, visa, vodafoneCash, instaPay, customerCredit }

class PaymentData {
  final PaymentMethod method;
  final double amount;

  const PaymentData({
    required this.method,
    required this.amount,
  });
}
