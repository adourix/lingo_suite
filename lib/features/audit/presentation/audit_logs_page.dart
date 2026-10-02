import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

final auditLogsProvider = FutureProvider.autoDispose<List<ActivityLog>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.activityLogs)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(200))
      .get();
});

class AuditLogsPage extends ConsumerWidget {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(auditLogsProvider);
    final db = ref.watch(databaseProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: ' + error.toString())),
        data: (items) => Card(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final log = items[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(log.action.toUpperCase() + ' • ' + log.entity),
                subtitle: FutureBuilder<User?>(
                  future: (db.select(db.users)..where((u) => u.id.equals(log.userId))).getSingleOrNull(),
                  builder: (context, snapshot) {
                    final actor = snapshot.data;
                    final actorText = actor == null
                        ? 'User #' + log.userId.toString()
                        : actor.fullName + ' (' + actor.username + ')';
                    return Text(
                      (log.description ?? '') + '\n' + actorText + ' • ' + log.createdAt.toString(),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}