import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/customers_provider.dart';

class CustomerSearchDialog extends ConsumerStatefulWidget {
  const CustomerSearchDialog({super.key});

  @override
  ConsumerState<CustomerSearchDialog> createState() =>
      _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends ConsumerState<CustomerSearchDialog> {
  String keyword = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Search Customer"),

      content: SizedBox(
        width: 400,

        height: 450,

        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "Name or phone number",

                prefixIcon: Icon(Icons.search),

                border: OutlineInputBorder(),
              ),

              onChanged: (value) {
                setState(() {
                  keyword = value;
                });
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ref
                  .watch(customersProvider)
                  .when(
                    data: (customers) {
                      final filtered = customers.where((customer) {
                        final name = customer.name.toLowerCase();

                        final phone = customer.phone ?? "";

                        final search = keyword.toLowerCase();

                        return name.contains(search) || phone.contains(keyword);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(child: Text("No customers"));
                      }

                      return ListView.builder(
                        itemCount: filtered.length,

                        itemBuilder: (context, index) {
                          final customer = filtered[index];

                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),

                            title: Text(customer.name),

                            subtitle: Text(customer.phone ?? ""),

                            onTap: () {
                              Navigator.pop(context, customer);
                            },
                          );
                        },
                      );
                    },

                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (e, _) => Text(e.toString()),
                  ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),

          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
