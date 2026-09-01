import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'sales_repository_provider.dart';

final invoicesProvider = StreamProvider<List<Sale>>((ref) {
  final repo = ref.watch(salesRepositoryProvider);

  return repo.watchAllSales();
});
