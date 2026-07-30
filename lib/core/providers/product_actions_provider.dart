import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/products_repository_provider.dart';
import '../../../core/providers/products_provider.dart';

final productActionsProvider = Provider<ProductActions>((ref) {
  return ProductActions(ref);
});

class ProductActions {
  ProductActions(this.ref);

  final Ref ref;

  Future<void> delete(int id) async {
    final repo = ref.read(productsRepositoryProvider);

    await repo.delete(id);

    ref.invalidate(productsProvider);
  }
}
