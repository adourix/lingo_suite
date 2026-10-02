import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
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
                final actor = ref.read(authUserProvider);
                if (actor == null) return;
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
                    userId: actor.id,
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

  Future<void> _editUser(BuildContext context, WidgetRef ref, User user) async {
    final name = TextEditingController(text: user.fullName);
    final username = TextEditingController(text: user.username);
    var role = user.role;
    var isActive = user.isActive;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit User'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
                TextField(controller: username, decoration: const InputDecoration(labelText: 'Username')),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) => setState(() => role = value ?? role),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || username.text.trim().isEmpty) return;
                final actor = ref.read(authUserProvider);
                if (actor == null) return;
                if (user.id == actor.id && !isActive) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You cannot deactivate yourself')),
                  );
                  return;
                }
                try {
                  await ref.read(authRepositoryProvider).updateUser(
                    userId: user.id,
                    actorId: actor.id,
                    fullName: name.text,
                    username: username.text,
                    role: role,
                    isActive: isActive,
                  );
                  ref.invalidate(usersProvider);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ' + e.toString())),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    username.dispose();
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref, User user) async {
    final password = TextEditingController();
    final confirm = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password — ' + user.username),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
              TextField(controller: confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (password.text.length < 6 || password.text != confirm.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be 6+ characters and match')),
                );
                return;
              }
              final actor = ref.read(authUserProvider);
              if (actor == null) return;
              try {
                await ref.read(authRepositoryProvider).changePassword(
                  userId: user.id,
                  actorId: actor.id,
                  newPassword: password.text,
                );
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ' + e.toString())),
                  );
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
    password.dispose();
    confirm.dispose();
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
                      leading: CircleAvatar(
                        child: Icon(user.isActive ? Icons.person : Icons.person_off),
                      ),
                      title: Text(user.fullName),
                      subtitle: Text(
                        user.username + ' • ' + (user.isActive ? 'Active' : 'Disabled'),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(label: Text(user.role.toUpperCase())),
                          IconButton(
                            tooltip: 'Edit user',
                            onPressed: () => _editUser(context, ref, user),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Change password',
                            onPressed: () => _changePassword(context, ref, user),
                            icon: const Icon(Icons.lock_reset),
                          ),
                        ],
                      ),
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