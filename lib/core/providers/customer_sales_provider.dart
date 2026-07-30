import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'sales_repository_provider.dart';

final customerSalesProvider = FutureProvider.family<List<Sale>, int>((
  ref,
  customerId,
) async {
  final repo = ref.watch(salesRepositoryProvider);

  return repo.getCustomerSales(customerId);
});
