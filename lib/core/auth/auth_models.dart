import '../database/app_database.dart';

class AuthUser {
  final int id;
  final String fullName;
  final String username;
  final String role;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
  });

  factory AuthUser.fromUser(User user) => AuthUser(
        id: user.id,
        fullName: user.fullName,
        username: user.username,
        role: user.role,
      );
}

class Permissions {
  static const dashboard = 'dashboard';
  static const pos = 'pos';
  static const products = 'products';
  static const customers = 'customers';
  static const suppliers = 'suppliers';
  static const reports = 'reports';
  static const manageUsers = 'manageUsers';
  static const auditLogs = 'auditLogs';

  static bool can(String role, String permission) {
    switch (role.toLowerCase()) {
      case 'admin':
        return true;
      case 'manager':
        return permission != manageUsers && permission != auditLogs;
      case 'cashier':
        return {
          dashboard,
          pos,
          customers,
        }.contains(permission);
      default:
        return false;
    }
  }
}
