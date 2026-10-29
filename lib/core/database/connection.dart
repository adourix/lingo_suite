import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Directory> _databaseDirectory() async {
  final supportDir = await getApplicationSupportDirectory();
  final databaseDir = Directory(p.join(supportDir.path, 'database'));
  await databaseDir.create(recursive: true);

  // Keep the existing database created by older builds. This prevents an
  // update from appearing to reset users, products, sales, etc.
  final oldDocumentsDir = await getApplicationDocumentsDirectory();
  final oldDatabaseFile = File(
    p.join(oldDocumentsDir.path, 'database', 'lingo_store.db'),
  );
  final newDatabaseFile = File(
    p.join(databaseDir.path, 'lingo_store.db'),
  );

  if (!await newDatabaseFile.exists() && await oldDatabaseFile.exists()) {
    await oldDatabaseFile.copy(newDatabaseFile.path);
  }

  return databaseDir;
}

QueryExecutor openConnection() {
  return driftDatabase(
    name: 'lingo_store.db',
    native: DriftNativeOptions(
      databaseDirectory: _databaseDirectory,
    ),
  );
}
