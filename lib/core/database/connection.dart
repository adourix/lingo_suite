import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  return driftDatabase(
    name: 'lingo_store.db',

    native: DriftNativeOptions(
      databaseDirectory: () async {

        final dir = await getApplicationDocumentsDirectory();

        final databaseDir = Directory(
          p.join(
            dir.path,
            'database',
          ),
        );

        final databaseFile = File(
          p.join(
            databaseDir.path,
            'lingo_store.db',
          ),
        );


        print("=================================");
        print("LINGO STORE DATABASE PATH");
        print("Documents:");
        print(dir.path);

        print("");

        print("Database folder:");
        print(databaseDir.path);

        print("");

        print("Database file:");
        print(databaseFile.path);

        print("");

        print("Database exists:");
        print(await databaseFile.exists());

        print("=================================");


        return databaseDir;
      },
    ),
  );
}
