import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/sales_repository.dart';
import 'database_provider.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(databaseProvider));
});
