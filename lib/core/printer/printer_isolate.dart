import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

void printerWorker(List<dynamic> args) {
  final sendPort = args[0];

  final printerName = args[1];

  final bytes = args[2] as List<int>;

  try {
    final printerPtr = printerName.toNativeUtf16();

    final handle = calloc<HANDLE>();

    final opened = OpenPrinter(printerPtr, handle, nullptr);

    calloc.free(printerPtr);

    if (opened == 0) {
      sendPort.send("Cannot open printer");

      return;
    }

    final doc = calloc<DOC_INFO_1>();

    final docName = "LINGO STORE".toNativeUtf16();

    final raw = "RAW".toNativeUtf16();

    doc.ref.pDocName = docName;

    doc.ref.pDatatype = raw;

    final started = StartDocPrinter(handle.value, 1, doc.cast());

    if (started == 0) {
      sendPort.send("Start document failed");

      return;
    }

    StartPagePrinter(handle.value);

    final buffer = calloc<Uint8>(bytes.length);

    final written = calloc<DWORD>();

    buffer.asTypedList(bytes.length).setAll(0, bytes);

    final result = WritePrinter(handle.value, buffer, bytes.length, written);

    EndPagePrinter(handle.value);

    EndDocPrinter(handle.value);

    ClosePrinter(handle.value);

    calloc.free(buffer);
    calloc.free(written);
    calloc.free(doc);
    calloc.free(handle);
    calloc.free(docName);
    calloc.free(raw);

    if (result == 0) {
      sendPort.send("Print failed");
    } else {
      sendPort.send("OK");
    }
  } catch (e) {
    sendPort.send(e.toString());
  }
}
