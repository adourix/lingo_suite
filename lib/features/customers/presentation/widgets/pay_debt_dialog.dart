import 'package:flutter/material.dart';

class PayDebtDialog extends StatefulWidget {
  const PayDebtDialog({super.key});

  @override
  State<PayDebtDialog> createState() => _PayDebtDialogState();
}

class _PayDebtDialogState extends State<PayDebtDialog> {
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pay Debt"),

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
          onPressed: () {
            Navigator.pop(context);
          },

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
