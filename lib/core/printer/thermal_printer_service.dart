import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'printer_isolate.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../database/app_database.dart';

class ThermalPrinterService {
  static const String printerName = "BIXOLON SRP-330II";

  static Future<void> printInvoice({
    required Sale sale,
    required List<SaleItem> items,
  }) async {
    if (!Platform.isWindows) {
      throw Exception("Windows only");
    }
    await _checkPrinter();
    final bytes = _buildReceipt(sale, items);

    final port = ReceivePort();

    await Isolate.spawn(printerWorker, [port.sendPort, printerName, bytes]);

    final result = await port.first.timeout(
      const Duration(seconds: 10),

      onTimeout: () {
        return "Printer timeout";
      },
    );

    port.close();

    if (result != "OK") {
      throw Exception(result);
    }
  }

  static Future<void> _printWindows(Sale sale, List<SaleItem> items) async {
    await _checkPrinter();

    final bytes = _buildReceipt(sale, items);

    final printerPtr = printerName.toNativeUtf16();

    final handle = calloc<HANDLE>();

    try {
      final result = OpenPrinter(printerPtr, handle, nullptr);

      if (result == 0) {
        throw Exception("Cannot open printer");
      }

      final doc = calloc<DOC_INFO_1>();

      final docName = "LINGO STORE".toNativeUtf16();

      final raw = "RAW".toNativeUtf16();

      try {
        doc.ref.pDocName = docName;

        doc.ref.pDatatype = raw;

        final start = StartDocPrinter(handle.value, 1, doc.cast());

        if (start == 0) {
          throw Exception("Start document failed");
        }

        StartPagePrinter(handle.value);

        final buffer = calloc<Uint8>(bytes.length);

        final written = calloc<DWORD>();

        try {
          buffer.asTypedList(bytes.length).setAll(0, bytes);

          final ok = WritePrinter(handle.value, buffer, bytes.length, written);

          if (ok == 0) {
            throw Exception("Printer write failed");
          }
        } finally {
          calloc.free(buffer);

          calloc.free(written);
        }

        EndPagePrinter(handle.value);

        EndDocPrinter(handle.value);
      } finally {
        calloc.free(doc);

        calloc.free(docName);

        calloc.free(raw);
      }
    } finally {
      ClosePrinter(handle.value);

      calloc.free(handle);

      calloc.free(printerPtr);
    }
  }

  static Future<void> _checkPrinter() async {
    final result = await Process.run("powershell", [
      "-Command",
      """
      \$p = Get-Printer -Name '$printerName' -ErrorAction SilentlyContinue;

      if(\$null -eq \$p){
        exit 1
      }

      if(\$p.PrinterStatus -eq 'Offline'){
        exit 2
      }

      exit 0
      """,
    ]);

    if (result.exitCode == 1) {
      throw Exception("Printer not found");
    }

    if (result.exitCode == 2) {
      throw Exception("Printer offline");
    }
  }

  static List<int> _buildReceipt(Sale sale, List<SaleItem> items) {
    final bytes = <int>[];

    void add(String text) {
      bytes.addAll(text.codeUnits);
    }

    void command(List<int> cmd) {
      bytes.addAll(cmd);
    }

    void center() {
      command([0x1B, 0x61, 0x01]);
    }

    void left() {
      command([0x1B, 0x61, 0x00]);
    }

    void bold(bool value) {
      command([0x1B, 0x45, value ? 1 : 0]);
    }

    void size(int value) {
      command([0x1D, 0x21, value]);
    }

    void normalSize() {
      size(0x00);
    }

    void fullLine() {
      add("==========================================\n");
    }

    void thinLine() {
      add("------------------------------------------\n");
    }

    void dotsLine() {
      add("..........................................\n");
    }

    // INIT

    command([0x1B, 0x40]);

    // ======================
    // STORE HEADER
    // ======================

    center();

    bold(true);

    size(0x11);

    add("LINGO STORE\n");

    normalSize();

    bold(false);

    add("Sales & Inventory Management\n");

    add("Tel: 01552854444\n");

    fullLine();

    // ======================
    // INVOICE INFO
    // ======================

    left();

    bold(true);

    bold(false);

    add("Invoice : ${sale.invoiceNumber}\n");

    add("Date    : ${sale.saleDate}\n");

    add("Cashier : Admin\n");

    thinLine();

    // ======================
    // ITEMS
    // ======================

    bold(true);

    add("ITEM             QTY   PRICE   TOTAL\n");

    bold(false);

    thinLine();

    for (final item in items) {
      String name = item.itemName;

      if (name.length > 13) {
        name = name.substring(0, 13);
      }

      final price = item.total / item.quantity;

      add(
        "${name.padRight(14)}${item.quantity.toString().padLeft(4)}${price.toStringAsFixed(0).padLeft(9)}${item.total.toStringAsFixed(0).padLeft(9)}\n",
      );
    }

    dotsLine();

    // ======================
    // TOTAL
    // ======================

    center();

    bold(true);

    size(0x10);

    add("TOTAL\n");

    add("${sale.total.toStringAsFixed(2)} EGP\n");

    normalSize();

    bold(false);

    fullLine();

    // ======================
    // PAYMENT
    // ======================

    left();

    bold(true);

    add("PAYMENT\n");

    bold(false);

    thinLine();

    add("Method : Cash\n");

    add("Paid   : ${sale.paid.toStringAsFixed(2)} EGP\n");

    add("Remain : ${sale.remaining.toStringAsFixed(2)} EGP\n");

    thinLine();

    // ======================
    // FOOTER
    // ======================

    center();

    bold(true);

    add("THANK YOU!\n");

    bold(false);

    add("Visit Again\n");

    add("LINGO STORE\n");

    add("\n\n\n\n");

    // CUT PAPER

    command([0x1D, 0x56, 0x00]);

    return bytes;
  }
}
