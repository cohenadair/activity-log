import 'package:sqflite/sqflite.dart';

/// Case-insensitive check for a row with the given [name] in [tableName].
Future<bool> nameExists(
  Database database,
  String tableName,
  String name,
) async {
  final query = "SELECT COUNT(*) FROM $tableName WHERE name = ? COLLATE NOCASE";
  return Sqflite.firstIntValue(await database.rawQuery(query, [name])) == 1;
}

/// Returns the number of rows in [tableName].
Future<int> rowCount(Database database, String tableName) async {
  final query = "SELECT COUNT(*) FROM $tableName";
  return Sqflite.firstIntValue(await database.rawQuery(query)) ?? 0;
}
