import 'sales_repository.dart';

/// Source-compatible wrapper around the canonical invoice return operation.
extension SalesReturnExtension on SalesRepository {
  Future<void> returnSaleCompletely(int saleId) => returnSale(saleId);
}
