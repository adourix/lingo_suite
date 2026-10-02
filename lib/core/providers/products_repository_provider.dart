import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/products_repository.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final user = ref.watch(authUserProvider);
  return ProductsRepository(
    ref.watch(databaseProvider),
    actorId: user?.id,
  );
});
