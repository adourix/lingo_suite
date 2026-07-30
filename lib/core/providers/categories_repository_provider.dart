import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/categories_repository.dart';
import 'database_provider.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(databaseProvider));
});
