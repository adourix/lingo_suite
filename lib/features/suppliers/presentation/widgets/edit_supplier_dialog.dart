import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class EditSupplierDialog extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierDialog({super.key, required this.supplier});

  @override
  State<EditSupplierDialog> createState() => _EditSupplierDialogState();
}

class _EditSupplierDialogState extends State<EditSupplierDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.supplier.name);

    phoneController = TextEditingController(text: widget.supplier.phone ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();

    phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Supplier"),

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
