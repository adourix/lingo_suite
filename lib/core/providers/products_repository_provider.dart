import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/products_repository.dart';
import 'database_provider.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.watch(databaseProvider));
});
