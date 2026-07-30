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
        return Directory(p.join(dir.path, 'database'));
      },
    ),
  );
}
