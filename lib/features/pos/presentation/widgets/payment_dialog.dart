import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/payment_data.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  final double total;

  const PaymentDialog({super.key, required this.total});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  PaymentMethod method = PaymentMethod.cash;

  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    amountController.text = widget.total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Payment"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Text("Total: ${widget.total.toStringAsFixed(2)} EGP"),

            const SizedBox(height: 20),

            DropdownButtonFormField<PaymentMethod>(
              initialValue: method,

              decoration: const InputDecoration(
                labelText: "Payment Method",

                border: OutlineInputBorder(),
              ),

              items: PaymentMethod.values.map((e) {
                return DropdownMenuItem(value: e, child: Text(e.name));
              }).toList(),

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  method = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Amount",

                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child: const Text("Cancel"),
        ),

        FilledButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);

            if (amount == null) return;

            Navigator.pop(context, PaymentData(method: method, amount: amount));
          },

          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
