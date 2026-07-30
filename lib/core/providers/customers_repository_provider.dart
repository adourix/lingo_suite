import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/customers_repository.dart';
import 'database_provider.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepository(ref.watch(databaseProvider));
});
