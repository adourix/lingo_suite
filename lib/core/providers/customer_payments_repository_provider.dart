import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/customer_payments_repository.dart';
import 'database_provider.dart';

final customerPaymentsRepositoryProvider = Provider<CustomerPaymentsRepository>(
  (ref) {
    return CustomerPaymentsRepository(ref.watch(databaseProvider));
  },
);
