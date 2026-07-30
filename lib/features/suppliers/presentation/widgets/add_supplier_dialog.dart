import 'package:flutter/material.dart';

class AddSupplierDialog extends StatefulWidget {
  const AddSupplierDialog({super.key});

  @override
  State<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<AddSupplierDialog> {
  final nameController = TextEditingController();

  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();

    phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Supplier"),

      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          TextField(
            controller: nameController,

            decoration: const InputDecoration(
              labelText: "Supplier Name",

              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: phoneController,

            keyboardType: TextInputType.phone,

            decoration: const InputDecoration(
              labelText: "Phone",

              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),

          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              "name": nameController.text,

              "phone": phoneController.text,
            });
          },

          child: const Text("Save"),
        ),
      ],
    );
  }
}
