import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteOpenHelper {
  static const String _name = "activitylog.db";
  static const int _version = 2;

  static const List<String> _schema0 = [
    """
    CREATE TABLE activity (
      id TEXT PRIMARY KEY,
      name TEXT UNIQUE NOT NULL,
      current_session_id TEXT REFERENCES session(id)
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

  static const List<String> _schema1 = [
    """
    ALTER TABLE session ADD COLUMN is_banked BOOLEAN DEFAULT false
    """,
  ];

  static const List<List<String>> _schema = [
    _schema0,
    _schema1,
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
    for (var schema in _schema) {
      _executeSchema(db, schema);
    }
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
    for (var query in schema) {
      db.execute(query);
    }
  }
}
