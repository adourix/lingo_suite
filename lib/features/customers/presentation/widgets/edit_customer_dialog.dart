import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class EditCustomerDialog extends StatefulWidget {
  final Customer customer;

  const EditCustomerDialog({super.key, required this.customer});

  @override
  State<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.customer.name);

    phoneController = TextEditingController(text: widget.customer.phone ?? "");
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
      title: const Text("Edit Customer"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: nameController,

              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: phoneController,

              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
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
