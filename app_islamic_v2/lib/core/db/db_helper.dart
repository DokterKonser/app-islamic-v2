import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'migrations/migration_v1.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static const _dbName = 'app_islamic_v2.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = Directory.systemTemp;
    String path = join(documentsDirectory.path, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onOpen: (db) async {
        await db.execute('PRAGMA journal_mode=WAL;');
      },
      onCreate: (db, version) async {
        await MigrationV1.runMigration(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          if (i == 1) {
            await MigrationV1.runMigration(db);
          }
        }
      },
    );
  }
}
