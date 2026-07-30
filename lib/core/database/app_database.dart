import 'package:drift/drift.dart';

import 'connection.dart';

// Tables

import 'tables/purchases_table.dart';
import 'tables/purchase_items_table.dart';
import 'tables/inventory_movements_table.dart';
import 'tables/categories_table.dart';
import 'tables/customers_table.dart';
import 'tables/products_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/payments_table.dart';
import 'tables/activity_logs_table.dart';
import 'tables/cash_sessions_table.dart';
import 'tables/expenses_table.dart';
import 'tables/settings_table.dart';
import 'tables/users_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/customer_payments_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,

    Customers,

    Suppliers,

    Products,

    CustomerPayments,

    Purchases,

    PurchaseItems,

    Sales,

    SaleItems,

    Payments,

    InventoryMovements,

    Expenses,

    Users,

    CashSessions,

    ActivityLogs,

    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      await into(users).insert(
        UsersCompanion.insert(
          fullName: 'Admin',
          username: 'admin',
          password: '123456',
          role: 'admin',
        ),
      );
    },

    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 6) {
        // Add supplier balance column
        // for old databases

        await m.addColumn(suppliers, suppliers.balance);
      }
    },

    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
