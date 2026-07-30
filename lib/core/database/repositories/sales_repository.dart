import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../../../features/pos/models/payment_data.dart';
import '../app_database.dart';
import '../../../features/pos/models/checkout_request.dart';

class SalesRepository {
  final AppDatabase db;

  SalesRepository(this.db);

  Future<String> generateInvoiceNumber() async {
    final now = DateTime.now();
    final date = DateFormat('yyyyMMdd').format(now);

    final prefix = 'INV-$date-';

    final lastInvoice =
        await (db.select(db.sales)
              ..where((tbl) => tbl.invoiceNumber.like('$prefix%'))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.invoiceNumber)])
              ..limit(1))
            .getSingleOrNull();

    if (lastInvoice == null) {
      return '${prefix}0001';
    }
    final parts = lastInvoice.invoiceNumber.split('-');

    final lastNumber = int.tryParse(parts.last) ?? 0;

    final nextNumber = (lastNumber + 1).toString().padLeft(4, '0');

    return '$prefix$nextNumber';
  }

  Future<int> checkout(CheckoutRequest request) async {
    return await db.transaction(() async {
      final invoiceNumber = await generateInvoiceNumber();

      final subtotal = request.items.fold<double>(
        0,
        (sum, item) => sum + item.subtotal,
      );

      final isCreditSale = request.payments.any(
        (payment) => payment.method == PaymentMethod.customerCredit,
      );

      final paid = isCreditSale
          ? 0.0
          : request.payments.fold<double>(
              0.0,
              (sum, payment) => sum + payment.amount,
            );
      final total = subtotal - request.discount + request.tax;
      for (final item in request.items) {
        if (item.product != null) {
          if (item.quantity > item.product!.quantity) {
            throw Exception('Not enough stock for ${item.product!.name}');
          }
        }
      }
      final saleId = await db
          .into(db.sales)
          .insert(
            SalesCompanion.insert(
              invoiceNumber: invoiceNumber,

              userId: request.userId,

              customerId: Value(request.customerId),

              subtotal: subtotal,

              discount: Value(request.discount),

              tax: Value(request.tax),

              total: total,

              paid: Value(paid),

              remaining: Value(total - paid),

              notes: Value(request.notes),
            ),
          );

      for (final item in request.items) {
        await db
            .into(db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,

                productId: Value(item.product?.id),

                itemName: item.name,

                quantity: item.quantity,

                unitPrice: item.price,

                costPrice: Value(item.product?.costPrice ?? 0),

                discount: Value(item.discount),

                total: item.subtotal,

                isManual: Value(item.type.name == 'service'),
              ),
            );

        if (item.product != null) {
          final product = item.product!;

          if (product.quantity < item.quantity) {
            throw Exception('Not enough stock for ${product.name}');
          }

          await (db.update(
            db.products,
          )..where((tbl) => tbl.id.equals(product.id))).write(
            ProductsCompanion(
              quantity: Value(product.quantity - item.quantity),

              updatedAt: Value(DateTime.now()),
            ),
          );

          await db
              .into(db.inventoryMovements)
              .insert(
                InventoryMovementsCompanion.insert(
                  productId: product.id,

                  type: 'sale',

                  quantity: -item.quantity,

                  referenceType: const Value('invoice'),

                  referenceId: Value(saleId),
                ),
              );
        }
      }

      for (final payment in request.payments) {
        await db
            .into(db.payments)
            .insert(
              PaymentsCompanion.insert(
                saleId: saleId,

                method: payment.method.name,

                amount: payment.amount,
              ),
            );
      }

      // Update customer balance for credit sales
      if (request.customerId != null) {
        final remaining = total - paid;

        if (remaining > 0) {
          final customer = await (db.select(
            db.customers,
          )..where((tbl) => tbl.id.equals(request.customerId!))).getSingle();

          await (db.update(
            db.customers,
          )..where((tbl) => tbl.id.equals(customer.id))).write(
            CustomersCompanion(
              balance: Value(customer.balance + remaining),

              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
      return saleId;
    });
  }

  Future<Sale?> getSaleByInvoiceNumber(String invoiceNumber) {
    return (db.select(db.sales)
          ..where((tbl) => tbl.invoiceNumber.equals(invoiceNumber)))
        .getSingleOrNull();
  }

  Future<void> returnSale(int saleId) async {
    await db.transaction(() async {
      final sale = await (db.select(
        db.sales,
      )..where((tbl) => tbl.id.equals(saleId))).getSingle();

      if (sale.isReturned) {
        throw Exception('Invoice already returned');
      }

      final items = await (db.select(
        db.saleItems,
      )..where((tbl) => tbl.saleId.equals(saleId))).get();

      for (final item in items) {
        if (item.productId == null) {
          continue;
        }

        final product = await (db.select(
          db.products,
        )..where((tbl) => tbl.id.equals(item.productId!))).getSingle();

        // رجوع الكمية للمخزن

        await (db.update(
          db.products,
        )..where((tbl) => tbl.id.equals(product.id))).write(
          ProductsCompanion(
            quantity: Value(product.quantity + item.quantity),

            updatedAt: Value(DateTime.now()),
          ),
        );

        // تسجيل حركة المخزون

        await db
            .into(db.inventoryMovements)
            .insert(
              InventoryMovementsCompanion.insert(
                productId: product.id,
                type: 'return',
                quantity: item.quantity,
                referenceType: const Value('sale_return'),
                referenceId: Value(saleId),
              ),
            );
      }

      // تعليم الفاتورة أنها مرتجعة

      await (db.update(db.sales)..where((tbl) => tbl.id.equals(saleId))).write(
        SalesCompanion(isReturned: const Value(true)),
      );
    });
  }

  Future<List<Sale>> getAllSales() {
    return (db.select(
      db.sales,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.saleDate)])).get();
  }

  Future<List<SaleItem>> getSaleItems(int saleId) {
    return (db.select(
      db.saleItems,
    )..where((tbl) => tbl.saleId.equals(saleId))).get();
  }

  Future<Sale?> getSaleById(int id) {
    return (db.select(
      db.sales,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<Sale>> getCustomerSales(int customerId) async {
    return await (db.select(db.sales)
          ..where((tbl) => tbl.customerId.equals(customerId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }
}
