import 'package:flutter/material.dart';

class AddSupplierDebtDialog extends StatefulWidget {
  const AddSupplierDebtDialog({super.key});

  @override
  State<AddSupplierDebtDialog> createState() => _AddSupplierDebtDialogState();
}

class _AddSupplierDebtDialogState extends State<AddSupplierDebtDialog> {
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Supplier Debt"),

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

          child: const Text("Add"),
        ),
      ],
    );
  }
}
