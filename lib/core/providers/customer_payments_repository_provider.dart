import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/customer_payments_repository.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

final customerPaymentsRepositoryProvider =
    Provider<CustomerPaymentsRepository>((ref) {
  final user = ref.watch(authUserProvider);
  return CustomerPaymentsRepository(
    ref.watch(databaseProvider),
    actorId: user?.id,
  );
});
