import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'auth_models.dart';

class AuthRepository {
  final AppDatabase db;

  AuthRepository(this.db);

  Future<AuthUser?> login(String username, String password) async {
    final user = await (db.select(db.users)
          ..where((u) =>
              u.username.equals(username.trim()) &
              u.password.equals(password) &
              u.isActive.equals(true)))
        .getSingleOrNull();

    if (user == null) return null;

    await db.into(db.activityLogs).insert(
          ActivityLogsCompanion.insert(
            userId: user.id,
            action: 'login',
            entity: 'user',
            entityId: Value(user.id),
            description: Value('User logged in'),
          ),
        );

    return AuthUser.fromUser(user);
  }

  Future<void> logout(AuthUser user) async {
    await db.into(db.activityLogs).insert(
          ActivityLogsCompanion.insert(
            userId: user.id,
            action: 'logout',
            entity: 'user',
            entityId: Value(user.id),
            description: Value('User logged out'),
          ),
        );
  }
}
