import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

final usersProvider = FutureProvider.autoDispose<List<User>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.users)..orderBy([(u) => OrderingTerm.asc(u.fullName)])).get();
});

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  Future<void> _addUser(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final username = TextEditingController();
    final password = TextEditingController();
    var role = 'cashier';

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add User'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
                TextField(controller: username, decoration: const InputDecoration(labelText: 'Username')),
                TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) => setState(() => role = value ?? 'cashier'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || username.text.trim().isEmpty || password.text.isEmpty) return;
                final db = ref.read(databaseProvider);
                final id = await db.into(db.users).insert(
                  UsersCompanion.insert(
                    fullName: name.text.trim(),
                    username: username.text.trim(),
                    password: password.text,
                    role: role,
                  ),
                );
                await db.into(db.activityLogs).insert(
                  ActivityLogsCompanion.insert(
                    userId: id,
                    action: 'create',
                    entity: 'user',
                    entityId: Value(id),
                    description: Value('Created user ${username.text.trim()} with role $role'),
                  ),
                );
                ref.invalidate(usersProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    username.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Users', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _addUser(context, ref),
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: users.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: ' + error.toString())),
              data: (items) => Card(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final user = items[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(user.fullName),
                      subtitle: Text(user.username),
                      trailing: Text(user.role.toUpperCase()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}