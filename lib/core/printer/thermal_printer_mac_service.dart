import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

class ThermalPrinterMacService {
  static const String printerName = "BIXOLON SRP-330II";
  static const String cupsQueueName = "BIXOLON_SRP_330II";

  static Future<void> printInvoice({
    required Sale sale,
    required List<SaleItem> items,
  }) async {
    await _printMac(sale, items, cupsQueueName);
  }

  static Future<void> _printMac(
    Sale sale,
    List<SaleItem> items,
    String queueName,
  ) async {
    final bytes = <int>[];

    void add(String text) => bytes.addAll(text.codeUnits);
    void command(List<int> cmd) => bytes.addAll(cmd);
    void align(int value) => command([0x1B, 0x61, value]);
    void bold(bool value) => command([0x1B, 0x45, value ? 1 : 0]);
    void size(int value) => command([0x1D, 0x21, value]);

    void normal() {
      size(0x00);
      bold(false);
    }

    String line() => "================================================\n";
    String dash() => "------------------------------------------------\n";

    command([0x1B, 0x40]);

    align(1);
    bold(true);
    size(0x11);
    add("LINGO STORE\n");
    normal();
    add("Tel: 01552854444\n");
    add(line());

    align(0);
    bold(true);
    add("INVOICE DETAILS\n");
    bold(false);
    add(dash());
    add("Invoice : ${sale.invoiceNumber}\n");
    add("Date    : ${sale.saleDate}\n");
    add("Cashier : Admin\n");
    add(dash());

    bold(true);
    add("ITEM             QTY   PRICE   TOTAL\n");
    bold(false);
    add(dash());

    for (final item in items) {
      String name = item.itemName;
      if (name.length > 13) name = name.substring(0, 13);

      final price = item.total / item.quantity;

      add(
        "${name.padRight(14)}"
        "${item.quantity.toString().padLeft(4)}"
        "${price.toStringAsFixed(0).padLeft(9)}"
        "${item.total.toStringAsFixed(0).padLeft(9)}\n",
      );
    }

    add(dash());

    align(0);
    bold(true);
    add("SUMMARY\n");
    bold(false);
    add(dash());
    add("Subtotal : ${sale.subtotal.toStringAsFixed(2)} EGP\n");
    add("Discount : ${sale.discount.toStringAsFixed(2)} EGP\n");
    add("Tax      : ${sale.tax.toStringAsFixed(2)} EGP\n");
    add(dash());

    align(1);
    bold(true);
    size(0x10);
    add("TOTAL\n");
    add("${sale.total.toStringAsFixed(2)} EGP\n");
    normal();
    add(line());

    align(0);
    add("Payment : Cash\n");
    add("Paid    : ${sale.total.toStringAsFixed(2)} EGP\n");
    add("Change  : 0.00 EGP\n");
    add(dash());

    align(1);
    bold(true);
    add("THANK YOU!\n");
    bold(false);
    add("Visit Again\n");
    add("LINGO STORE\n");
    add("\n\n\n\n");

    command([0x1D, 0x56, 0x00]);

    final tempDir = await getTemporaryDirectory();
    final file = File("${tempDir.path}/lingo_invoice.raw");
    await file.writeAsBytes(bytes);

    final result = await Process.run(
      "/usr/bin/lp",
      ["-d", queueName, "-o", "raw", file.path],
      environment: {"LANG": "C", "LC_ALL": "C"},
    );

    if (result.exitCode != 0) {
      final error = result.stderr.toString().trim();
      throw Exception(
        error.isEmpty
            ? "Printer Error (lp exit code ${result.exitCode})"
            : "Printer Error: $error",
      );
    }
  }

}