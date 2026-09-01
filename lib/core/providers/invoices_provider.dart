import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'sales_repository_provider.dart';

final invoicesProvider = FutureProvider<List<Sale>>((ref) async {
  final repo = ref.watch(salesRepositoryProvider);

  return repo.getAllSales();
});
