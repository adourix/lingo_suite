import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'suppliers_repository_provider.dart';

final suppliersProvider = StreamProvider<List<Supplier>>((ref) {
  final repo = ref.watch(suppliersRepositoryProvider);

  return repo.watchAll();
});
