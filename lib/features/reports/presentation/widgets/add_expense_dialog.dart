import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/expenses_provider.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final titleController = TextEditingController();

  final amountController = TextEditingController();

  final notesController = TextEditingController();

  String category = "Other";

  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Expense"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: titleController,

              decoration: const InputDecoration(labelText: "Expense Title"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: amountController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: category,

              items: const [
                DropdownMenuItem(value: "Bills", child: Text("Bills")),

                DropdownMenuItem(value: "Salary", child: Text("Salary")),

                DropdownMenuItem(value: "Purchase", child: Text("Purchase")),

                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],

              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    category = v;
                  });
                }
              },

              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: notesController,

              maxLines: 3,

              decoration: const InputDecoration(labelText: "Notes"),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () {
                  Navigator.pop(context);
                },

          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: saving ? null : _save,

          child: saving
              ? const SizedBox(
                  width: 18,

                  height: 18,

                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Save"),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final title = titleController.text.trim();

    final amount = double.tryParse(amountController.text);

    if (title.isEmpty || amount == null) {
      return;
    }

    setState(() {
      saving = true;
    });

    final repo = ref.read(expensesRepositoryProvider);

    await repo.insert(
      ExpensesCompanion.insert(
        title: title,

        category: category,

        amount: amount,

        notes: Value(notesController.text.trim()),
      ),
    );

    ref.invalidate(expensesProvider);

    ref.invalidate(totalExpensesProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
