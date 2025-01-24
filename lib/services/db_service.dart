import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Database? _database;

  Future<Database> _initDatabase() async {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    if (!isMobile) {
      sqfliteFfiInit();
    }

    var databaseFactoryLocal = isMobile ? databaseFactory : databaseFactoryFfi;
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final path = p.join(appDocumentsDir.path, "databases", "reservas.db");

    print("Database Path: $path");

    Database db = await databaseFactoryLocal.openDatabase(path,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              String sql =
                  await rootBundle.loadString('lib/scripts/init_db.sql');
              List<String> commands =
                  sql.split(';'); // Divide em várias instruções
              for (String command in commands) {
                if (command.trim().isNotEmpty) {
                  await db.execute(command);
                }
              }
            }));

    return db;
  }

  Future<void> initDatabase() async {
    _database = await _initDatabase();
    return;
  }

  Future<Database> getDatabaseInstance() async {
    return _database!;
  }
}
