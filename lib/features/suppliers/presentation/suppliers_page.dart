import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

import 'widgets/edit_supplier_dialog.dart';
import 'widgets/add_supplier_dialog.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/suppliers_repository_provider.dart';

import 'supplier_details_page.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(suppliersRepositoryProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  "Suppliers",

                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,

                      builder: (_) => const AddSupplierDialog(),
                    );

                    if (result == null) return;

                    final data = result as Map<String, dynamic>;

                    await repo.insert(
                      SuppliersCompanion.insert(
                        name: data["name"].toString(),

                        phone: Value(
                          data["phone"].toString().isEmpty
                              ? null
                              : data["phone"].toString(),
                        ),
                      ),
                    );

                    setState(() {});
                  },

                  icon: const Icon(Icons.add),

                  label: const Text("Add Supplier"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextField(
              controller: searchController,

              decoration: const InputDecoration(
                hintText: "Search supplier by name or phone",

                prefixIcon: Icon(Icons.search),
              ),

              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<List<Supplier>>(
                future: searchController.text.isEmpty
                    ? repo.getAll()
                    : repo.search(searchController.text),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No Suppliers"));
                  }

                  final suppliers = snapshot.data!;

                  return ListView.builder(
                    itemCount: suppliers.length,

                    itemBuilder: (context, index) {
                      final supplier = suppliers[index];

                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    SupplierDetailsPage(supplier: supplier),
                              ),
                            );
                          },

                          leading: const CircleAvatar(child: Icon(Icons.store)),

                          title: Text(supplier.name),

                          subtitle: Text(supplier.phone ?? ""),

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == "edit") {
                                final result = await showDialog(
                                  context: context,

                                  builder: (_) =>
                                      EditSupplierDialog(supplier: supplier),
                                );

                                if (result == null) return;

                                final data = result as Map<String, dynamic>;

                                await repo.update(
                                  supplier.id,

                                  SuppliersCompanion(
                                    name: Value(data["name"].toString()),

                                    phone: Value(
                                      data["phone"].toString().isEmpty
                                          ? null
                                          : data["phone"].toString(),
                                    ),

                                    updatedAt: Value(DateTime.now()),
                                  ),
                                );

                                setState(() {});
                              }

                              if (value == "delete") {
                                await repo.delete(supplier.id);

                                setState(() {});
                              }
                            },

                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: "edit",

                                child: Row(
                                  children: [
                                    Icon(Icons.edit),

                                    SizedBox(width: 8),

                                    Text("Edit"),
                                  ],
                                ),
                              ),

                              const PopupMenuItem(
                                value: "delete",

                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),

                                    SizedBox(width: 8),

                                    Text("Delete"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
