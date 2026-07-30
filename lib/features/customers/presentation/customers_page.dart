import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

import 'widgets/edit_customer_dialog.dart';
import 'widgets/add_customer_dialog.dart';

import '../../../core/providers/customers_repository_provider.dart';
import '../../../core/database/app_database.dart';

import 'customer_details_page.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(customersRepositoryProvider);

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
                  "Customers",

                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,

                      builder: (_) => const AddCustomerDialog(),
                    );

                    if (result == null) return;

                    final data = result as Map<String, dynamic>;

                    await repo.insert(
                      CustomersCompanion.insert(
                        name: Value(data["name"].toString()),

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

                  label: const Text("Add Customer"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextField(
              controller: searchController,

              decoration: const InputDecoration(
                hintText: "Search customer by name or phone...",

                prefixIcon: Icon(Icons.search),
              ),

              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder(
                future: searchController.text.isEmpty
                    ? repo.getAll()
                    : repo.search(searchController.text),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No Customers"));
                  }

                  final customers = snapshot.data!;

                  return ListView.builder(
                    itemCount: customers.length,

                    itemBuilder: (context, index) {
                      final customer = customers[index];

                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    CustomerDetailsPage(customer: customer),
                              ),
                            );
                          },

                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),

                          title: Text(customer.name),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(customer.phone ?? ""),

                              Text("Balance: ${customer.balance} EGP"),
                            ],
                          ),

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == "edit") {
                                final result = await showDialog(
                                  context: context,

                                  builder: (_) =>
                                      EditCustomerDialog(customer: customer),
                                );

                                if (result == null) return;

                                final data = result as Map<String, dynamic>;

                                await repo.update(
                                  customer.copyWith(
                                    name: data["name"].toString(),

                                    phone: Value(
                                      data["phone"].toString().isEmpty
                                          ? null
                                          : data["phone"].toString(),
                                    ),

                                    updatedAt: DateTime.now(),
                                  ),
                                );

                                setState(() {});
                              }

                              if (value == "delete") {
                                await repo.delete(customer.id);

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
