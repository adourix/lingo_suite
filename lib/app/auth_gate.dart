import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/auth_provider.dart';
import '../core/widgets/app_shell.dart';
import '../features/auth/presentation/login_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    return user == null ? const LoginPage() : const AppShell();
  }
}
