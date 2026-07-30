import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'categories_repository_provider.dart';

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.watchAll();
});
