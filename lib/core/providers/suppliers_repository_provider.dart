import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/suppliers_repository.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  final user = ref.watch(authUserProvider);
  return SuppliersRepository(
    ref.watch(databaseProvider),
    actorId: user?.id,
  );
});
