import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'products_repository_provider.dart';

final productsProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productsRepositoryProvider);
  return repo.watchAll();
});

final productsSearchProvider = FutureProvider.family<List<Product>, String>((
  ref,
  keyword,
) async {
  final repo = ref.watch(productsRepositoryProvider);

  if (keyword.trim().isEmpty) {
    return repo.getAll();
  }

  return repo.search(keyword);
});

final productProvider = FutureProvider.family<Product?, int>((ref, id) async {
  final repo = ref.watch(productsRepositoryProvider);
  return repo.getById(id);
});
