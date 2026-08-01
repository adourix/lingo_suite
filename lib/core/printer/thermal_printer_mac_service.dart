import 'dart:io';

import '../database/app_database.dart';

class ThermalPrinterMacService {
  static const String printerName = "BIXOLON_SRP_330II";

  static Future<void> printInvoice({
    required Sale sale,
    required List<SaleItem> items,
  }) async {
    await _checkPrinter();

    await _printMac(
      sale,
      items,
    );
  }



  static Future<void> _printMac(
    Sale sale,
    List<SaleItem> items,
  ) async {

    final List<int> bytes = [];


    void add(String text) {
      bytes.addAll(
        text.codeUnits,
      );
    }


    void command(List<int> cmd) {
      bytes.addAll(cmd);
    }


    void align(int value) {
      command([
        0x1B,
        0x61,
        value,
      ]);
    }


    void bold(bool value) {
      command([
        0x1B,
        0x45,
        value ? 1 : 0,
      ]);
    }


    void size(int value) {
      command([
        0x1D,
        0x21,
        value,
      ]);
    }


    void normal() {
      size(0x00);
      bold(false);
    }


    String line() {
      return "================================================\n";
    }


    String dash() {
      return "------------------------------------------------\n";
    }



    // INIT

    command([
      0x1B,
      0x40,
    ]);



    // HEADER

    align(1);

    bold(true);

    size(0x11);


    add(
      "LINGO STORE\n",
    );


    normal();


    add(
      "POS & INVENTORY SYSTEM\n",
    );


    add(
      "Tel: 01000000000\n",
    );


    add(
      line(),
    );




    // INFO

    align(0);


    bold(true);

    add(
      "INVOICE DETAILS\n",
    );


    bold(false);


    add(
      dash(),
    );


    add(
      "Invoice : ${sale.invoiceNumber}\n",
    );


    add(
      "Date    : ${sale.saleDate}\n",
    );


    add(
      "Cashier : Admin\n",
    );


    add(
      dash(),
    );




    // ITEMS


    bold(true);


    add(
      "ITEM             QTY   PRICE   TOTAL\n",
    );


    bold(false);


    add(
      dash(),
    );



    for(final item in items){

      String name = item.itemName;


      if(name.length > 13){
        name = name.substring(0,13);
      }


      final price =
          item.total / item.quantity;



      add(
        name.padRight(14) +
        item.quantity
            .toString()
            .padLeft(4) +
        price
            .toStringAsFixed(0)
            .padLeft(9) +
        item.total
            .toStringAsFixed(0)
            .padLeft(9) +
        "\n",
      );

    }



    add(
      dash(),
    );




    // TOTAL


    align(1);


    bold(true);

    size(0x10);


    add(
      "TOTAL\n",
    );


    add(
      "${sale.total.toStringAsFixed(2)} EGP\n",
    );


    normal();


    add(
      line(),
    );




    // PAYMENT


    align(0);


    add(
      "Payment : Cash\n",
    );


    add(
      "Paid    : ${sale.total.toStringAsFixed(2)} EGP\n",
    );


    add(
      "Change  : 0.00 EGP\n",
    );


    add(
      dash(),
    );




    // FOOTER


    align(1);


    bold(true);


    add(
      "THANK YOU!\n",
    );


    bold(false);


    add(
      "Visit Again\n",
    );


    add(
      "LINGO STORE\n",
    );


    add(
      "\n\n\n\n",
    );




    // CUT PAPER

    command([
      0x1D,
      0x56,
      0x00,
    ]);




    final file = File(
      "/tmp/lingo_invoice.raw",
    );


    await file.writeAsBytes(
      bytes,
    );



    final result = await Process.run(
      "lp",
      [
        "-d",
        printerName,

        // send ESC/POS raw commands
        "-o",
        "raw",

        file.path,
      ],
    );



    if(result.exitCode != 0){

      throw Exception(
        "Printer Error:\n${result.stderr}",
      );

    }

  }




  static Future<void> _checkPrinter() async {


    final result = await Process.run(
      "lpstat",
      [
        "-p",
        printerName,
      ],
    );



    if(result.exitCode != 0){

      throw Exception(
        "Printer not found: $printerName",
      );

    }

  }

}
