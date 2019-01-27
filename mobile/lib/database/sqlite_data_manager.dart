import 'dart:async';

import 'package:mobile/data_manageable.dart';
import 'package:mobile/database/sqlite_open_helper.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDataManager implements DataManageable {
  Database _database;
  final StreamController<List<Activity>> _activitiesUpdated;

  SQLiteDataManager()
      : _activitiesUpdated = StreamController.broadcast()
  {
    SQLiteOpenHelper.open().then((Database db) {
      // Initialize the database.
      _database = db;

      // Database is available, notify listeners.
      _notifyActivitiesUpdated();

      // When a new listener is added, trigger an event so the listener receives
      // the activity list immediately.
      _activitiesUpdated.onListen = () {
        _notifyActivitiesUpdated();
      };
    });
  }

  @override
  Stream<List<Activity>> get activitiesUpdated => _activitiesUpdated.stream;

  Future<List<Activity>> _getActivities() async {
    String query = "SELECT * FROM activity ORDER BY name";
    return (await _database.rawQuery(query)).map((map) {
      return Activity.fromMap(map);
    }).toList();
  }

  @override
  void addActivity(Activity activity) {
    _database.insert("activity", activity.toMap()).then((int value) {
      _notifyActivitiesUpdated();
    });
  }

  @override
  void updateActivity(Activity activity) {
    _database.update(
      "activity",
      activity.toMap(),
      where: "id = ?",
      whereArgs: [activity.id]
    ).then((int value) {
      _notifyActivitiesUpdated();
    });
  }

  @override
  void removeActivity(String activityId) {
    Batch batch = _database.batch();

    // Delete activity.
    batch.rawDelete("DELETE FROM activity WHERE id = ?", [activityId]);

    // Delete all associated sessions.
    batch.rawDelete("DELETE FROM session WHERE activity_id = ?", [activityId]);

    batch.commit().then((value) {
      _notifyActivitiesUpdated();
    });
  }

  @override
  void startSession(Activity activity) {
    if (activity.isRunning) {
      // Only one session per activity can be running at a given time.
      return;
    }

    Session newSession = SessionBuilder(activity.id).build;

    Batch batch = _database.batch();
    batch.insert("session", newSession.toMap());
    batch.rawUpdate(
      "UPDATE activity SET current_session_id = ? WHERE id = ?",
      [newSession.id, activity.id]
    );
    batch.commit().then((value) {
      _notifyActivitiesUpdated();
    });
  }

  @override
  void endSession(Activity activity) {
    if (!activity.isRunning) {
      // Can't end a session for an activity that isn't running.
      return;
    }

    Batch batch = _database.batch();
    batch.rawUpdate("UPDATE session SET end_timestamp = ? WHERE id = ?",
      [DateTime.now().millisecondsSinceEpoch, activity.currentSessionId]
    );
    batch.rawUpdate(
      "UPDATE activity SET current_session_id = NULL WHERE id = ?",
      [activity.id]
    );
    batch.commit().then((List value) {
      _notifyActivitiesUpdated();
    });
  }

  @override
  Future<List<Session>> getSessions(String activityId) async {
    String query = "SELECT * FROM session WHERE activity_id = ?";
    return (await _database.rawQuery(query, [activityId])).map((map) {
      return Session.fromMap(map);
    }).toList();
  }

  @override
  Future<Session> getCurrentSession(String activityId) async {
    String query = "SELECT * FROM session WHERE id = ?";

    Map<String, dynamic> map =
        (await _database.rawQuery(query, [activityId])).first;
    return Session.fromMap(map);
  }

  @override
  Future<bool> activityNameExists(String name) async {
    String query = """
      SELECT COUNT(*) FROM activity WHERE name = ? COLLATE NOCASE
    """;
    return Sqflite.firstIntValue(await _database.rawQuery(query, [name])) == 1;
  }

  void _notifyActivitiesUpdated() {
    _getActivities().then((List<Activity> activities) {
      _activitiesUpdated.add(activities);
    });
  }
}