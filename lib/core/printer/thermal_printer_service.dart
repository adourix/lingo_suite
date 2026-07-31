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
    ]).timeout(const Duration(seconds: 3));

    if (result.exitCode == 1) {
      throw Exception("Printer not found");
    }

    if (result.exitCode == 2) {
      throw Exception("Printer is offline");
    }
  }

  static List<int> _buildReceipt(Sale sale, List<SaleItem> items) {
    final bytes = <int>[];

    void add(String text) {
      bytes.addAll(text.codeUnits);
    }

    bytes.addAll([0x1B, 0x40]);

    // Center

    bytes.addAll([0x1B, 0x61, 0x01]);

    add("LINGO STORE\n");

    add("POS SYSTEM\n");

    add("==============================\n");

    // Left

    bytes.addAll([0x1B, 0x61, 0x00]);

    add("Invoice : ${sale.invoiceNumber}\n");

    add("Date    : ${sale.saleDate}\n");

    add("------------------------------\n");

    add("ITEM        QTY    PRICE TOTAL\n");

    add("------------------------------\n");

    for (final item in items) {
      add("${item.itemName}\n");

      add("${item.quantity} x ${item.total}\n");
    }

    add("------------------------------\n");

    bytes.addAll([0x1B, 0x61, 0x01]);

    add("TOTAL\n");

    add("${sale.total} EGP\n");

    add("\n\n\n");

    bytes.addAll([0x1D, 0x56, 0x00]);

    return bytes;
  }
}
