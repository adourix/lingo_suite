import 'dart:io';

import '../database/app_database.dart';

class ThermalPrinterMacService {
  static Future<void> printInvoice({
    required Sale sale,
    required List<SaleItem> items,
  }) async {
    await _printMac(sale, items);
  }

  static Future<void> _printMac(Sale sale, List<SaleItem> items) async {
    const printerName = "BIXOLON SRP-330II";

    final List<int> bytes = [];

    void add(String text) {
      bytes.addAll(text.codeUnits);
    }

    String line() => "================================================\n";

    String dash() => "------------------------------------------------\n";

    void align(int value) {
      bytes.addAll([0x1B, 0x61, value]);
    }

    void bold(bool value) {
      bytes.addAll([0x1B, 0x45, value ? 1 : 0]);
    }

    void size(int value) {
      bytes.addAll([0x1D, 0x21, value]);
    }

    // INIT

    bytes.addAll([0x1B, 0x40]);

    // HEADER

    align(1);

    bold(true);

    size(0x11);

    add("LINGO STORE\n");

    size(0x00);

    bold(false);

    add("POS & INVENTORY SYSTEM\n");

    add("Tel: 01000000000\n");

    add(line());

    // INFO

    align(0);

    add("Invoice No : ${sale.invoiceNumber}\n");

    add("Date       : ${sale.saleDate}\n");

    add("Cashier    : Admin\n");

    add(dash());

    // TABLE

    bold(true);

    add("ITEM            QTY   PRICE   TOTAL\n");

    bold(false);

    add(dash());

    for (final item in items) {
      String name = item.itemName;

      if (name.length > 15) {
        name = name.substring(0, 15);
      }

      final price = item.total / item.quantity;

      add(
        name.padRight(16) +
            item.quantity.toString().padLeft(4) +
            price.toStringAsFixed(0).padLeft(8) +
            item.total.toStringAsFixed(0).padLeft(9) +
            "\n",
      );
    }

    add(dash());

    // TOTAL

    align(1);

    bold(true);

    size(0x10);

    add("TOTAL\n");

    add("${sale.total} EGP\n");

    size(0x00);

    bold(false);

    add(line());

    // PAYMENT

    align(0);

    add("Payment : Cash\n");

    add("Paid    : ${sale.total} EGP\n");

    add("Change  : 0 EGP\n");

    add(dash());

    // FOOTER

    align(1);

    bold(true);

    add("Thank You For Your Purchase\n");

    bold(false);

    add("Visit Again ♥\n");

    add("LINGO STORE\n");

    add("\n\n\n\n");

    // CUT

    bytes.addAll([0x1D, 0x56, 0x00]);

    final file = File("/tmp/lingo_invoice.raw");

    await file.writeAsBytes(bytes);

    final result = await Process.run("lp", ["-d", printerName, file.path]);

    if (result.exitCode != 0) {
      throw Exception(result.stderr.toString());
    }
  }
}
