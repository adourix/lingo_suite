import 'dart:io';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../database/app_database.dart';

class ThermalPrinterService {
  static Future<void> printInvoice({
    required Sale sale,
    required List<SaleItem> items,
  }) async {
    if (!Platform.isWindows) {
      throw Exception("Only Windows supported");
    }

    await _printWindows(sale, items);
  }

  static Future<void> _printWindows(Sale sale, List<SaleItem> items) async {
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

    add("Tel: 01552854444\n");

    add(line());

    // INFO

    align(0);

    add("Invoice No : ${sale.invoiceNumber}\n");

    add("Date       : ${sale.saleDate}\n");

    add("Cashier    : Admin\n");

    add(dash());

    // TABLE HEADER

    bold(true);

    add("ITEM            QTY   PRICE   TOTAL\n");

    bold(false);

    add(dash());

    // ITEMS

    for (final item in items) {
      String name = item.itemName;

      if (name.length > 15) {
        name = name.substring(0, 15);
      }

      final price = item.total / item.quantity;

      final text =
          name.padRight(16) +
          item.quantity.toString().padLeft(4) +
          price.toStringAsFixed(0).padLeft(8) +
          item.total.toStringAsFixed(0).padLeft(9) +
          "\n";

      add(text);
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

    add("Thank You For Your Purchase\n");

    add("Visit Again ♥\n");

    bold(true);

    add("LINGO STORE\n");

    bold(false);

    add("\n\n\n\n");

    // CUT

    bytes.addAll([0x1D, 0x56, 0x00]);

    // RAW PRINT WINDOWS

    final printerPtr = printerName.toNativeUtf16();

    final handle = calloc<HANDLE>();

    final opened = OpenPrinter(printerPtr, handle, nullptr);

    calloc.free(printerPtr);

    if (opened == 0) {
      throw Exception("Printer not found");
    }

    final doc = calloc<DOC_INFO_1>();

    final docName = "Flutter POS".toNativeUtf16();

    final raw = "RAW".toNativeUtf16();

    doc.ref.pDocName = docName;

    doc.ref.pDatatype = raw;

    StartDocPrinter(handle.value, 1, doc.cast());

    StartPagePrinter(handle.value);

    final buffer = calloc<Uint8>(bytes.length);

    buffer.asTypedList(bytes.length).setAll(0, bytes);

    final written = calloc<DWORD>();

    WritePrinter(handle.value, buffer, bytes.length, written);

    EndPagePrinter(handle.value);

    EndDocPrinter(handle.value);

    ClosePrinter(handle.value);

    calloc.free(buffer);
    calloc.free(written);
    calloc.free(doc);
    calloc.free(handle);
    calloc.free(docName);
    calloc.free(raw);
  }
}
