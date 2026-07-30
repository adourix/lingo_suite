import 'package:flutter/material.dart';

class PaySupplierDialog extends StatefulWidget {
  const PaySupplierDialog({super.key});

  @override
  State<PaySupplierDialog> createState() => _PaySupplierDialogState();
}

class _PaySupplierDialogState extends State<PaySupplierDialog> {
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pay Supplier"),

      content: TextField(
        controller: amountController,

        keyboardType: TextInputType.number,

        decoration: const InputDecoration(
          labelText: "Amount",

          suffixText: "EGP",

          border: OutlineInputBorder(),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),

          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);

            if (amount == null || amount <= 0) {
              return;
            }

            Navigator.pop(context, amount);
          },

          child: const Text("Pay"),
        ),
      ],
    );
  }
}
