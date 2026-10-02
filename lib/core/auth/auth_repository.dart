import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'auth_models.dart';

class AuthRepository {
  final AppDatabase db;

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  AuthRepository(this.db);

  Future<AuthUser?> login(String username, String password) async {
    final user = await (db.select(db.users)
          ..where((u) =>
              u.username.equals(username.trim()) &
              u.password.equals(_hash(password)) &
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
  Future<void> _requireAdmin(int actorId) async {
    final actor = await (db.select(db.users)..where((u) => u.id.equals(actorId))).getSingleOrNull();
    if (actor == null || !actor.isActive || actor.role.toLowerCase() != 'admin') {
      throw StateError('Admin permission required');
    }
  }

  Future<int> createUser({
    required int actorId,
    required String fullName,
    required String username,
    required String password,
    required String role,
  }) async {
    await _requireAdmin(actorId);
    if (fullName.trim().isEmpty || username.trim().isEmpty || password.length < 6) {
      throw ArgumentError('Invalid user data');
    }
    final id = await db.into(db.users).insert(
      UsersCompanion.insert(
        fullName: fullName.trim(),
        username: username.trim(),
        password: Value(_hash(password)),
        role: role,
      ),
    );
    await db.into(db.activityLogs).insert(
      ActivityLogsCompanion.insert(
        userId: actorId,
        action: 'create',
        entity: 'user',
        entityId: Value(id),
        description: Value('Created user ' + username.trim() + ' with role ' + role),
      ),
    );
    return id;
  }

  Future<void> updateUser({
    required int userId,
    required int actorId,
    required String fullName,
    required String username,
    required String role,
    required bool isActive,
  }) async {
    await _requireAdmin(actorId);
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
    await _requireAdmin(actorId);
    if (newPassword.length < 6) throw ArgumentError('Password cannot be empty');

    final user = await (db.select(db.users)..where((u) => u.id.equals(userId))).getSingleOrNull();
    if (user == null) throw StateError('User not found');

    await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(password: Value(_hash(newPassword))),
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
