import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'purchases_repository_provider.dart';

final supplierPurchasesProvider = FutureProvider.family<List<Purchase>, int>((
  ref,
  supplierId,
) async {
  final repo = ref.watch(purchasesRepositoryProvider);

  return repo.getSupplierPurchases(supplierId);
});
