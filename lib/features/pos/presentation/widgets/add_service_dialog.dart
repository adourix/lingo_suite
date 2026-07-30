import 'package:flutter/material.dart';

class AddServiceDialog extends StatefulWidget {
  const AddServiceDialog({super.key});

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController(text: "1");

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Service"),

      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Service Name"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton(
          onPressed: () {
            Navigator.pop(context, (
              _name.text,
              double.tryParse(_price.text) ?? 0,
              int.tryParse(_qty.text) ?? 1,
            ));
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
