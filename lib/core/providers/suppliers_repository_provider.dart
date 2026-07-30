import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/suppliers_repository.dart';
import 'database_provider.dart';

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  return SuppliersRepository(ref.watch(databaseProvider));
});
