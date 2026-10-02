import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_models.dart';
import '../auth/auth_repository.dart';
import 'database_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(databaseProvider));
});

final authUserProvider = StateProvider<AuthUser?>((ref) => null);

final authLoadingProvider = StateProvider<bool>((ref) => false);
