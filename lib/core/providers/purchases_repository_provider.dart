import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/purchases_repository.dart';
import 'database_provider.dart';

final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) {
  final db = ref.watch(databaseProvider);

  return PurchasesRepository(db);
});
