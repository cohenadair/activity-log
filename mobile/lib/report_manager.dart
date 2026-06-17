import 'package:adair_flutter_lib/managers/manager.dart';
import 'package:adair_flutter_lib/utils/void_stream_controller.dart';
import 'package:flutter/material.dart';
import 'package:mobile/database/sqlite_open_helper.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/utils/database.dart';
import 'package:sqflite/sqflite.dart';

class ReportManager implements Manager {
  static var _instance = ReportManager._();

  static ReportManager get get => _instance;

  @visibleForTesting
  static void set(ReportManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = ReportManager._();

  ReportManager._();

  static const _table = "report";

  late Database _database;

  final _reportsUpdated = VoidStreamController();

  Stream<void> get reportsUpdatedStream => _reportsUpdated.stream;

  Stream<List<Report>> get reportsStream async* {
    yield await reports();
    await for (final _ in _reportsUpdated.stream) {
      yield await reports();
    }
  }

  @override
  Future<void> init([Database? database]) async {
    _database = database ?? await SQLiteOpenHelper.open();
  }

  Future<List<Report>> reports() async {
    return (await _database.rawQuery(
      "SELECT * FROM $_table ORDER BY name",
    )).map(_reportFromMap).toList();
  }

  Future<bool> reportNameExists(String name) =>
      nameExists(_database, _table, name);

  Future<void> addReport(Report report) async {
    await _database.insert(_table, report.toMap());
    _reportsUpdated.notify();
  }

  Future<void> updateReport(Report report) async {
    final rowsUpdated = await _database.update(
      _table,
      report.toMap(),
      where: "id = ?",
      whereArgs: [report.id],
    );
    if (rowsUpdated > 0) {
      _reportsUpdated.notify();
    }
  }

  Future<void> removeReport(String id) async {
    await _database.rawDelete("DELETE FROM $_table WHERE id = ?", [id]);
    _reportsUpdated.notify();
  }

  Report _reportFromMap(Map<String, dynamic> map) => Report.fromMap(map);
}
