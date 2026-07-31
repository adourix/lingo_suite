import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../core/database/app_database.dart';
import '../../../core/providers/suppliers_repository_provider.dart';

import 'widgets/pay_supplier_dialog.dart';
import 'widgets/add_supplier_debt_dialog.dart';

class SupplierDetailsPage extends ConsumerWidget {
  final Supplier supplier;

  const SupplierDetailsPage({super.key, required this.supplier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(supplier.name)),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      supplier.name,

                      style: const TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text("Phone: ${supplier.phone ?? '-'}"),

                    const SizedBox(height: 10),

                    Text(
                      "Balance: ${supplier.balance} EGP",

                      style: const TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  final amount = await showDialog<double>(
                    context: context,

                    builder: (_) => const AddSupplierDebtDialog(),
                  );

                  if (amount == null) return;

                  final repo = ref.read(suppliersRepositoryProvider);

                  await repo.update(
                    supplier.id,

                    SuppliersCompanion(
                      balance: Value(supplier.balance + amount),

                      updatedAt: Value(DateTime.now()),
                    ),
                  );

                  ref.invalidate(suppliersRepositoryProvider);

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },

                icon: const Icon(Icons.add_card),

                label: const Text("Add Debt"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  final amount = await showDialog<double>(
                    context: context,

                    builder: (_) => const PaySupplierDialog(),
                  );

                  if (amount == null) return;

                  final newBalance = supplier.balance - amount;

                  if (newBalance < 0) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Payment is greater than supplier balance",
                          ),
                        ),
                      );
                    }

                    return;
                  }

                  final repo = ref.read(suppliersRepositoryProvider);

                  await repo.update(
                    supplier.id,

                    SuppliersCompanion(
                      balance: Value(newBalance),

                      updatedAt: Value(DateTime.now()),
                    ),
                  );

                  ref.invalidate(suppliersRepositoryProvider);

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },

                icon: const Icon(Icons.payments),

                label: const Text("Pay Supplier"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
