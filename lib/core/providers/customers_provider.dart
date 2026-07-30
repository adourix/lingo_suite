import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'customers_repository_provider.dart';

final customersProvider = StreamProvider<List<Customer>>((ref) {
  final repo = ref.watch(customersRepositoryProvider);

  return repo.watchAll();
});

final customersSearchProvider = FutureProvider.family<List<Customer>, String>((
  ref,
  keyword,
) async {
  final repo = ref.watch(customersRepositoryProvider);

  if (keyword.trim().isEmpty) {
    return repo.getAll();
  }

  return repo.search(keyword);
});
