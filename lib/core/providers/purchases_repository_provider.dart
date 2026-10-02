import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/purchases_repository.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) {
  final user = ref.watch(authUserProvider);
  return PurchasesRepository(
    ref.watch(databaseProvider),
    actorId: user?.id,
  );
});
