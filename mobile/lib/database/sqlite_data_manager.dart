import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/database/data_manageable.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/model.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/tuple.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDataManager implements DataManageable {
  Database _database;
  final StreamController<List<Activity>> _activitiesUpdated;
  final Map<String, StreamController<List<Session>>> _sessionsUpdatedMap;

  SQLiteDataManager()
      : _activitiesUpdated = StreamController.broadcast(),
        _sessionsUpdatedMap = Map();

  @override
  void initialize(Database database) {
    _database = database;
  }

  void _update(String table, Model model, VoidCallback notify) {
    _database.update(
      table,
      model.toMap(),
      where: "id = ?",
      whereArgs: [model.id]
    ).then((int value) {
      notify();
    });
  }

  @override
  void getActivitiesUpdateStream(StreamHandler<List<Activity>> notifyNow) {
    if (notifyNow(_activitiesUpdated.stream)) {
      _notifyActivitiesUpdated();
    }
  }

  @override
  void getSessionsUpdatedStream(String activityId,
      StreamHandler<List<Session>> notifyNow)
  {
    if (!_sessionsUpdatedMap.containsKey(activityId)) {
      _sessionsUpdatedMap[activityId] = StreamController.broadcast();
    }

    if (notifyNow(_sessionsUpdatedMap[activityId].stream)) {
      _notifySessionsUpdated(activityId);
    }
  }

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
    _update("activity", activity, _notifyActivitiesUpdated);
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

    // Update session's end time.
    batch.rawUpdate("UPDATE session SET end_timestamp = ? WHERE id = ?",
      [DateTime.now().millisecondsSinceEpoch, activity.currentSessionId]
    );

    // Set the associated activity's current session to null.
    batch.rawUpdate(
      "UPDATE activity SET current_session_id = NULL WHERE id = ?",
      [activity.id]
    );

    batch.commit().then((List value) {
      _notifyActivitiesUpdated();
    });
  }

  @override
  void addSession(Session session) {
    _database.insert("session", session.toMap()).then((int value) {
      _notifySessionsUpdated(session.activityId);
    });
  }

  @override
  void updateSession(Session session) {
    _update("session", session, () {
      _notifySessionsUpdated(session.activityId);
    });
  }

  @override
  void removeSession(Session session) async {
    Batch batch = _database.batch();

    // Disassociate the session from activity if it is in progress.
    batch.rawUpdate(
      """
        UPDATE activity SET current_session_id = NULL 
          WHERE current_session_id = ?
      """,
      [session.id]
    );

    // Delete session.
    batch.rawDelete("DELETE FROM session WHERE id = ?", [session.id]);

    await batch.commit();

    _notifySessionsUpdated(session.activityId);
    _notifyActivitiesUpdated();
  }

  @override
  Future<List<Session>> getSessions(String activityId) async {
    return getLimitedSessions(activityId, null);
  }

  @override
  Future<List<Session>> getRecentSessions(String activityId, int limit) async {
    return getLimitedSessions(activityId, limit);
  }

  @override
  Future<int> getSessionCount(String activityId) async {
    String query = """
      SELECT COUNT(*) FROM session WHERE activity_id = ?
    """;
    return Sqflite.firstIntValue(await _database.rawQuery(query, [activityId]));
  }

  @override
  Future<Session> getOverlappingSession(Session session) async {
    String query;
    List<dynamic> params;

    if (session.inProgress) {
      // End timestamp is irrelevant for in progress sessions. Existing sessions
      // will never have an end timestamp greater than the input session, which
      // in this case can be assumed to be infinity.
      query = """
        SELECT * FROM session
          WHERE activity_id = ?
          AND id != ?
          AND ? <= start_timestamp
      """;

      params = [
        session.activityId,
        session.id,
        session.startTimestamp,
      ];
    } else {
      query = """
        SELECT * FROM session
          WHERE activity_id = ?
          AND id != ?
          AND start_timestamp < ?
          AND end_timestamp > ?
          LIMIT 1
      """;

      params = [
        session.activityId,
        session.id,
        session.endTimestamp,
        session.startTimestamp,
      ];
    }

    List<Map<String, dynamic>> result = await _database.rawQuery(query, params);
    if (result.isEmpty) {
      return null;
    }

    return Session.fromMap(result.first);
  }

  Future<List<Session>> getLimitedSessions(String activityId, int limit) async {
    String query;
    List<dynamic> args;

    if (limit == null) {
      query = """
        SELECT * FROM session 
          WHERE activity_id = ? 
          ORDER BY start_timestamp DESC
      """;
      args = [activityId];
    } else {
      query = """
        SELECT * FROM session 
          WHERE activity_id = ? 
          ORDER BY start_timestamp DESC
          LIMIT ?;
      """;
      args = [activityId, limit];
    }

    return (await _database.rawQuery(query, args)).map((map) {
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

  @override
  Future<SummarizedActivityList> getSummarizedActivities(DateRange dateRange,
      [List<Activity> activities]) async
  {
    List<Activity> activityList = activities == null ? [] : List.of(activities);

    // Get all activities if none were provided.
    if (activities == null || activities.length == 0) {
      var mapList = await _database.rawQuery("SELECT * FROM activity");
      mapList.forEach((map) => activityList.add(Activity.fromMap(map)));
    }

    List<SummarizedActivity> summarizedActivities = [];

    // Get all sessions for all activities and construct a SummarizedActivity
    // object.
    for (Activity activity in activityList) {
      List<Map<String, dynamic>> sessionMapList;
      if (dateRange == null) {
        // No date range was provided, get all sessions.
        sessionMapList = await _database.rawQuery("""
          SELECT * FROM session
            WHERE activity_id = ?
            ORDER BY start_timestamp
          """, [
          activity.id
        ]);
      } else {
        // Query for sessions that belong to this Activity and overlap the
        // desired date range.
        sessionMapList = await _database.rawQuery("""
          SELECT * FROM session
            WHERE activity_id = ?
            AND start_timestamp < ?
            AND (end_timestamp IS NULL OR end_timestamp > ?)
            ORDER BY start_timestamp
          """, [
            activity.id,
            dateRange.endMs,
            dateRange.startMs,
          ],
        );
      }

      List<Session> sessionList = [];

      if (sessionMapList != null) {
        sessionMapList.forEach((Map<String, dynamic> map) {
          sessionList.add(SessionBuilder
              .fromSession(Session.fromMap(map))
              .pinToDateRange(dateRange)
              .build);
        });
      }

      summarizedActivities.add(SummarizedActivity(
        value: activity,
        dateRange: dateRange,
        sessions: sessionList,
      ));
    }

    summarizedActivities.sort((a, b) => a.value.name.compareTo(b.value.name));
    return SummarizedActivityList(summarizedActivities);
  }

  void _notifyActivitiesUpdated() {
    _getActivities().then((List<Activity> activities) {
      if (_activitiesUpdated.hasListener) {
        _activitiesUpdated.add(activities);
      }
    });
  }

  void _notifySessionsUpdated(String activityId) {
    getSessions(activityId).then((List<Session> sessions) {
      if (_sessionsUpdatedMap.containsKey(activityId) &&
          _sessionsUpdatedMap[activityId].hasListener)
      {
        _sessionsUpdatedMap[activityId].add(sessions);
      }
    });
  }
}