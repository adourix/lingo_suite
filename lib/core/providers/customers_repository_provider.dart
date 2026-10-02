import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/customers_repository.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final user = ref.watch(authUserProvider);
  return CustomersRepository(
    ref.watch(databaseProvider),
    actorId: user?.id,
  );
});
