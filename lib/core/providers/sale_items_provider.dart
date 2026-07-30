import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'sales_repository_provider.dart';

final saleItemsProvider = FutureProvider.family<List<SaleItem>, int>((
  ref,
  saleId,
) async {
  final repo = ref.watch(salesRepositoryProvider);

  return repo.getSaleItems(saleId);
});
