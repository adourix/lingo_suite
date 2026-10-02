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
  Future<void> updateUser({
    required int userId,
    required int actorId,
    required String fullName,
    required String username,
    required String role,
    required bool isActive,
  }) async {
    final existing = await (db.select(db.users)..where((u) => u.id.equals(userId))).getSingleOrNull();
    if (existing == null) throw StateError('User not found');

    await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        fullName: Value(fullName.trim()),
        username: Value(username.trim()),
        role: Value(role),
        isActive: Value(isActive),
      ),
    );

    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        userId: actorId,
        action: 'update',
        entity: 'user',
        entityId: Value(userId),
        description: Value('Updated user ' + username.trim()),
      ),
    );
  }

  Future<void> changePassword({
    required int userId,
    required int actorId,
    required String newPassword,
  }) async {
    if (newPassword.isEmpty) throw ArgumentError('Password cannot be empty');

    final user = await (db.select(db.users)..where((u) => u.id.equals(userId))).getSingleOrNull();
    if (user == null) throw StateError('User not found');

    await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(password: Value(newPassword)),
    );

    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        userId: actorId,
        action: 'change_password',
        entity: 'user',
        entityId: Value(userId),
        description: Value('Changed password for ' + user.username),
      ),
    );
  }
}
