import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../../../features/pos/models/payment_data.dart';
import '../app_database.dart';
import '../../../features/pos/models/checkout_request.dart';
import '../../auth/auth_models.dart';

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

    var nextNumber = 1;

    if (lastInvoice != null) {
      final match = RegExp(
        r'^INV-\d{8}-(\d+)',
      ).firstMatch(lastInvoice.invoiceNumber);

      nextNumber = (int.tryParse(match?.group(1) ?? '') ?? 0) + 1;
    }

    return '$prefix${nextNumber.toString().padLeft(4, '0')}-${now.microsecond.toString().padLeft(6, '0')}';
  }

  Future<int> checkout(CheckoutRequest request) async {
    final actor = await (db.select(db.users)..where((u) => u.id.equals(request.userId))).getSingleOrNull();
    if (actor == null || !actor.isActive || !Permissions.can(actor.role, Permissions.pos)) {
      throw StateError('User is not authorized to make sales');
    }
    if (request.items.isEmpty) {
      throw ArgumentError('Cart cannot be empty');
    }

    if (request.items.any((item) => item.quantity <= 0 || item.price < 0 || item.discount < 0)) {
      throw ArgumentError('Invalid sale item');
    }

    final subtotal = request.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final total = subtotal - request.discount + request.tax;
    if (subtotal < 0 || request.discount < 0 || request.tax < 0 || total < 0 || request.discount > subtotal) {
      throw ArgumentError('Invalid sale totals');
    }

    final paid = request.payments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.amount,
    );

    if (request.payments.any((payment) => payment.amount < 0)) {
      throw ArgumentError('Payment amount cannot be negative');
    }

    if (request.payments.isEmpty || paid <= 0) {
      throw ArgumentError('At least one payment is required');
    }

    final creditAmount = request.payments
        .where((payment) => payment.method == PaymentMethod.customerCredit)
        .fold<double>(0, (sum, payment) => sum + payment.amount);
    final effectivePaid = paid - creditAmount;
    final isCreditSale = creditAmount > 0;

    if (paid > total || effectivePaid < 0 || (creditAmount > 0 && (total - effectivePaid - creditAmount).abs() > 0.01)) {
      throw ArgumentError('Invalid payment total');
    }

    if (effectivePaid > total) {
      throw ArgumentError('Payment cannot exceed invoice total');
    }

    if (isCreditSale && request.customerId == null) {
      throw ArgumentError('Customer is required for credit sales');
    }

    return await db.transaction(() async {
      final invoiceNumber = await generateInvoiceNumber();

      final freshProducts = <int, Product>{};
      for (final item in request.items) {
        if (item.product == null) continue;

        final product = await (db.select(db.products)
              ..where((p) => p.id.equals(item.product!.id)))
            .getSingleOrNull();

        if (product == null || !product.isActive) {
          throw Exception('Product is no longer available: ${item.name}');
        }

        if (item.quantity > product.quantity) {
          throw Exception('Not enough stock for ${product.name}');
        }

        freshProducts[product.id] = product;
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

              paid: Value(effectivePaid),

              remaining: Value(total - effectivePaid),

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

                costPrice: Value(item.product == null ? 0 : freshProducts[item.product!.id]!.costPrice),

                discount: Value(item.discount),

                total: item.subtotal,

                isManual: Value(item.type.name == 'service'),
              ),
            );

        if (item.product != null) {
          final product = freshProducts[item.product!.id]!;
          final newQuantity = product.quantity - item.quantity;

          await (db.update(
            db.products,
          )..where((tbl) => tbl.id.equals(product.id))).write(
            ProductsCompanion(
              quantity: Value(newQuantity),

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
        final remaining = total - effectivePaid;

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
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          userId: request.userId,
          action: 'create',
          entity: 'sale',
          entityId: Value(saleId),
          description: Value('Created invoice $invoiceNumber'),
        ),
      );

      return saleId;
    });
  }

  Future<Sale?> getSaleByInvoiceNumber(String invoiceNumber) {
    return (db.select(db.sales)
          ..where((tbl) => tbl.invoiceNumber.equals(invoiceNumber)))
        .getSingleOrNull();
  }

  Future<void> returnSale(int saleId, int actorId) async {
    final actor = await (db.select(db.users)..where((u) => u.id.equals(actorId))).getSingleOrNull();
    if (actor == null || !actor.isActive || !Permissions.can(actor.role, Permissions.pos)) {
      throw StateError('User is not authorized to return sales');
    }
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
        if (item.productId == null) continue;

        final product = await (db.select(
          db.products,
        )..where((tbl) => tbl.id.equals(item.productId!))).getSingle();

        await (db.update(
          db.products,
        )..where((tbl) => tbl.id.equals(product.id))).write(
          ProductsCompanion(
            quantity: Value(product.quantity + item.quantity),
            updatedAt: Value(DateTime.now()),
          ),
        );

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

      // عكس دين العميل
      if (sale.customerId != null && sale.remaining > 0) {
        final customer = await (db.select(
          db.customers,
        )..where((tbl) => tbl.id.equals(sale.customerId!))).getSingle();

        await (db.update(
          db.customers,
        )..where((tbl) => tbl.id.equals(customer.id))).write(
          CustomersCompanion(
            balance: Value(
              (customer.balance - sale.remaining).clamp(0, double.infinity),
            ),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // حذف المدفوعات المرتبطة بالفاتورة
      await (db.delete(
        db.payments,
      )..where((tbl) => tbl.saleId.equals(saleId))).go();

      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          userId: actorId,
          action: 'return',
          entity: 'sale',
          entityId: Value(saleId),
          description: Value('Returned invoice ${sale.invoiceNumber}'),
        ),
      );

      await (db.update(db.sales)..where((tbl) => tbl.id.equals(saleId))).write(
        const SalesCompanion(
          isReturned: Value(true),
          status: Value('returned'),
        ),
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

  Future<List<Sale>> getSalesByDate({
    required DateTime from,
    required DateTime to,
  }) {
    return (db.select(db.sales)
          ..where(
            (tbl) =>
                tbl.saleDate.isBiggerOrEqualValue(from) &
                tbl.saleDate.isSmallerOrEqualValue(to) &
                tbl.isReturned.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.saleDate)]))
        .get();
  }

  // Invoice Details

  Future<List<SaleItem>> getInvoiceItems(int saleId) => getSaleItems(saleId);

  // Invoice Payments

  Future<List<Payment>> getInvoicePayments(int saleId) {
    return (db.select(
      db.payments,
    )..where((tbl) => tbl.saleId.equals(saleId))).get();
  }
}
