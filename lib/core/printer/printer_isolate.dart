import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

void printerWorker(List<dynamic> args) {
  final sendPort = args[0];

  final printerName = args[1] as String;

  final bytes = args[2] as List<int>;

  final printerPtr = printerName.toNativeUtf16();

  final handle = calloc<HANDLE>();

  try {
    final opened = OpenPrinter(printerPtr, handle, nullptr);

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

    final page = StartPagePrinter(handle.value);

    if (page == 0) {
      sendPort.send("Start page failed");

      EndDocPrinter(handle.value);

      return;
    }

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

    calloc.free(docName);

    calloc.free(raw);

    calloc.free(handle);

    calloc.free(printerPtr);

    if (result == 0) {
      sendPort.send("WritePrinter failed");
    } else {
      sendPort.send("OK");
    }
  } catch (e) {
    sendPort.send(e.toString());
  }
}
