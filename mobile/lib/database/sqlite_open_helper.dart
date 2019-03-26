import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteOpenHelper {
  static final String _name = "activitylog.db";
  static final int _version = 1;

  static final List<String> _schema0 = [
    """
    CREATE TABLE activity (
      id TEXT PRIMARY KEY,
      name TEXT UNIQUE NOT NULL,
      current_session_id INTEGER REFERENCES session(id)
    );
    """,
    """  
    CREATE TABLE session (
      id TEXT PRIMARY KEY,
      activity_id TEXT NOT NULL REFERENCES activity(id),
      start_timestamp INTEGER NOT NULL,
      end_timestamp INTEGER
    );
    """
  ];

  static final List<List<String>> _schema = [
    _schema0,
  ];

  static Future<Database> open() async {
    String path = join(await getDatabasesPath(), _name);
    print(path.toString());
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static void _onCreate(Database db, int version) {
    _schema.forEach((List<String> schema) => _executeSchema(db, schema));
  }

  static void _onUpgrade(Database db, int oldVersion, int newVersion) {
    for (int version = oldVersion; version < newVersion; ++version) {
      if (version >= _schema.length) {
        throw ArgumentError("Invalid database version: $newVersion");
      }
      _executeSchema(db, _schema[version]);
    }
  }

  static void _executeSchema(Database db, List<String> schema) {
    schema.forEach((String query) => db.execute(query));
  }
}