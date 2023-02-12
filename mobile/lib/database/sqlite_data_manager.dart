import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/sqlite_open_helper.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/model.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:mobile/widgets/activity_list_tile.dart';
import 'package:mobile/widgets/future_listener.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDataManager {
  late Database _database;

  final _activitiesUpdated = VoidStreamController();
  final Map<String, VoidStreamController> _sessionsUpdatedMap = Map();

  /// Used for a more seamless transition between the launch screen and
  /// [Activity] list. This value will be `null` after the app has loaded.
  ///
  /// This value is loaded during [SQLiteDataManager] initialization, and used
  /// as an initial value for a [ActivityListModelBuilder].
  late List<ActivityListTileModel> _initialActivityListTileModels;

  /// Events are added to this [Stream] when an [Activity] is added, removed,
  /// or modified.
  Stream<void> get activitiesUpdatedStream => _activitiesUpdated.stream;

  Future<void> initialize(AppManager app, [Database? database]) async {
    if (database == null) {
      _database = await SQLiteOpenHelper.open();
    } else {
      _database = database;
    }

    _initialActivityListTileModels = await getActivityListModel(
      dateRange: app.preferencesManager.homeDateRange.value,
    );
  }

  Future<bool> clearDatabase() async {
    Batch batch = _database.batch();

    batch.rawQuery("DELETE FROM activity");
    batch.rawQuery("DELETE FROM session");

    await batch.commit(noResult: true);

    // Confirm data has been deleted.
    return (await activityCount) <= 0 && (await sessionCount) <= 0;
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

  Future<int> _getRowCount(String tableName) async {
    String query = "SELECT COUNT(*) FROM $tableName";
    return Sqflite.firstIntValue(await _database.rawQuery(query)) ?? 0;
  }

  /// Events are added to this [Stream] when sessions for the given activity ID
  /// are updated.
  Stream<void> getSessionsUpdatedStream(String activityId) {
    if (!_sessionsUpdatedMap.containsKey(activityId)) {
      _sessionsUpdatedMap[activityId] = VoidStreamController();
    }
    return _sessionsUpdatedMap[activityId]!.stream;
  }

  Future<List<Activity>> get activities async {
    String query = "SELECT * FROM activity ORDER BY name";
    return (await _database.rawQuery(query)).map((map) {
      return Activity.fromMap(map);
    }).toList();
  }

  Future<List<Activity>> getActivities(List<String> ids) async {
    String query = '''
      SELECT * FROM activity 
      WHERE id IN ("${ids.join('","')}") 
      ORDER BY name
    ''';
    return (await _database.rawQuery(query)).map((map) {
      return Activity.fromMap(map);
    }).toList();
  }

  Future<int> get activityCount async => _getRowCount("activity");

  void addActivity(Activity activity) {
    _database.insert("activity", activity.toMap()).then((int value) {
      _activitiesUpdated.notify();
    });
  }

  /// Batch inserts the list of [Activity] objects into the database. To
  /// increase performance, a single insert may silently fail.
  Future<void> addActivities(List<Activity> activityList, {
    bool notify = false
  }) async {
    Batch batch = _database.batch();
    activityList.forEach((Activity activity) {
      batch.insert("activity", activity.toMap());
    });
    await batch.commit();

    if (notify) {
      _activitiesUpdated.notify();
    }
  }

  void updateActivity(Activity activity) {
    _update("activity", activity, _activitiesUpdated.notify);
  }

  void removeActivity(String activityId) {
    Batch batch = _database.batch();

    // Delete activity.
    batch.rawDelete("DELETE FROM activity WHERE id = ?", [activityId]);

    // Delete all associated sessions.
    batch.rawDelete("DELETE FROM session WHERE activity_id = ?", [activityId]);

    batch.commit().then((value) {
      _activitiesUpdated.notify();
    });
  }

  Future<List<Session>> get sessions async {
    String query = "SELECT * FROM session";
    return (await _database.rawQuery(query)).map((map) {
      return Session.fromMap(map);
    }).toList();
  }

  Future<int> get sessionCount async => _getRowCount("session");

  /// Batch inserts the list of [Session] objects into the database. To
  /// increase performance, a single insert may silently fail.
  Future<void> addSessions(List<Session> sessionList, {
    bool notify = false
  }) async {
    Batch batch = _database.batch();
    sessionList.forEach((Session session) {
      batch.insert("session", session.toMap());
    });
    await batch.commit();

    if (notify) {
      _activitiesUpdated.notify();
      sessionList.forEach((Session session) {
        if (_sessionsUpdatedMap.containsKey(session.activityId)) {
          _sessionsUpdatedMap[session.activityId]!.notify();
        }
      });
    }
  }

  /// Creates and starts a new [Session] for the given [Activity]. If the given
  /// [Activity] is already running, this method does nothing. Returns the ID
  /// of the new [Session].
  Future<String?> startSession(Activity activity) async {
    if (activity.isRunning) {
      // Only one session per activity can be running at a given time.
      return null;
    }

    Session newSession = SessionBuilder(activity.id).build;

    Batch batch = _database.batch();
    batch.insert("session", newSession.toMap());
    batch.rawUpdate(
      "UPDATE activity SET current_session_id = ? WHERE id = ?",
      [newSession.id, activity.id]
    );

    var _ = await batch.commit();
    _activitiesUpdated.notify();

    return newSession.id;
  }

  /// Ends the session for the given [Activity]. This method does nothing if
  /// the given [Activity] isn't running. Always returns `null`, which can and
  /// should be ignored.
  Future<void> endSession(Activity activity) async {
    if (!activity.isRunning) {
      // Can't end a session for an activity that isn't running.
      return null;
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

    var _ = await batch.commit();
    _activitiesUpdated.notify();

    return null;
  }

  void addSession(Session session) {
    _database.insert("session", session.toMap()).then((int value) {
      _notifySessionsUpdated(session.activityId);
    });
  }

  void updateSession(Session session) {
    _update("session", session, () {
      _notifySessionsUpdated(session.activityId);
    });
  }

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
  }

  Future<List<Session>> getSessions(String activityId) async {
    return getLimitedSessions(activityId, null);
  }

  Future<List<Session>> getRecentSessions(String activityId, int? limit) async {
    return getLimitedSessions(activityId, limit);
  }

  Future<int> getSessionCount(String activityId) async {
    String query = """
      SELECT COUNT(*) FROM session WHERE activity_id = ?
    """;
    return Sqflite.firstIntValue(await _database.rawQuery(query, [activityId])) ?? 0;
  }

  /// Returns the [Session] the given [Session] overlaps with, if one exists;
  /// `null` otherwise.
  Future<Session?> getOverlappingSession(Session session) async {
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
          AND ((start_timestamp < ? AND end_timestamp > ?)
            OR (end_timestamp IS NULL AND ? > start_timestamp)
          )
          LIMIT 1
      """;

      params = [
        session.activityId,
        session.id,
        session.endTimestamp,
        session.startTimestamp,
        session.endTimestamp,
      ];
    }

    List<Map<String, dynamic>> result = await _database.rawQuery(query, params);
    if (result.isEmpty) {
      return null;
    }

    return Session.fromMap(result.first);
  }

  Future<List<Session>> getLimitedSessions(String activityId, int? limit) async {
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

  /// Returns the session with the given ID, or `null` if one isn't found.
  Future<Session?> getSession(String? sessionId) async {
    if (sessionId == null) {
      return null;
    }

    String query = "SELECT * FROM session WHERE id = ?";
    Map<String, dynamic> map =
        (await _database.rawQuery(query, [sessionId])).first;

    return Session.fromMap(map);
  }

  /// Case-insensitive compare of a given name to all other activity names.
  Future<bool> activityNameExists(String name) async {
    String query = """
      SELECT COUNT(*) FROM activity WHERE name = ? COLLATE NOCASE
    """;
    return Sqflite.firstIntValue(await _database.rawQuery(query, [name])) == 1;
  }

  /// Returns a [SummarizedActivityList] object within the given date
  /// range. If the `activities` parameter is not `null`, the result is
  /// restricted to only those activities.
  ///
  /// Note that this will return a [SummarizedActivityList], even if there
  /// were no sessions for the associated [Activity] objects within the given
  /// [DisplayDateRange].
  ///
  /// If the given [DisplayDateRange] is `null`, the result will include all
  /// [Session] objects associated with each given [Activity].
  Future<SummarizedActivityList> getSummarizedActivities(
    DisplayDateRange? displayDateRange, [
    List<Activity> activities = const [],
  ]) async {
    DateRange? dateRange =
        displayDateRange == null ? null : displayDateRange.value;

    var activityList = List.of(activities);
    // Get all activities if none were provided.
    if (activityList.isEmpty) {
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
            AND is_banked = 0
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
            AND is_banked = 0
            ORDER BY start_timestamp
          """, [
            activity.id,
            dateRange.endMs,
            dateRange.startMs,
          ],
        );
      }

      List<Session> sessionList = [];

      sessionMapList.forEach((Map<String, dynamic> map) {
        sessionList.add(SessionBuilder
            .fromSession(Session.fromMap(map))
            .pinToDateRange(dateRange)
            .build);
      });

      summarizedActivities.add(SummarizedActivity(
        value: activity,
        displayDateRange: displayDateRange,
        sessions: sessionList,
      ));
    }

    summarizedActivities.sort((a, b) => a.value.name.compareTo(b.value.name));
    return SummarizedActivityList(summarizedActivities);
  }

  /// Returns a list of [ActivityListTileModel] objects meant to be used in
  /// a list of [ActivityListTile] widgets.
  ///
  /// The reason we have a separate model is because not all relative
  /// information is attached to an [Activity] object. Some properties, such as
  /// total duration, needs to be calculated from the session database table.
  ///
  /// The passed in [DateRange] object is used for calculating the total
  /// duration to display.
  Future<List<ActivityListTileModel>> getActivityListModel({
    required DateRange dateRange,
  }) async {
    String allActivitiesQuery = "SELECT * FROM activity";

    String inProgressSessionsQuery = """
      SELECT * FROM session WHERE end_timestamp IS NULL
    """;

    String totalDurationsQuery = """
      SELECT activity_id, SUM(end_timestamp - start_timestamp) as sum_value
      FROM session
      WHERE start_timestamp < ?
      AND (end_timestamp IS NULL OR end_timestamp > ?)
      AND is_banked = 0
      GROUP BY activity_id
    """;

    String bankedSessionsQuery = """
      SELECT activity_id, SUM(end_timestamp - start_timestamp) as sum_value
      FROM session
      WHERE start_timestamp < ?
      AND (end_timestamp IS NULL OR end_timestamp > ?)
      AND is_banked = 1
      GROUP BY activity_id
    """;

    Batch batch = _database.batch();
    batch.rawQuery(allActivitiesQuery);
    batch.rawQuery(inProgressSessionsQuery);
    batch.rawQuery(totalDurationsQuery, [dateRange.endMs, dateRange.startMs]);
    batch.rawQuery(bankedSessionsQuery, [dateRange.endMs, dateRange.startMs]);
    List<dynamic> mapList = await batch.commit();

    if (mapList.isEmpty) {
      return [];
    }

    Map<String, ActivityListTileModel> modelMap = Map();

    // Activities.
    mapList[0].forEach((activityMap) {
      Activity activity = Activity.fromMap(activityMap);
      modelMap[activity.id] = ActivityListTileModel(activity);
    });

    // In progress sessions.
    mapList[1].forEach((sessionMap) {
      Session session = Session.fromMap(sessionMap);
      modelMap[session.activityId]!.currentSession = session;
    });

    // Total durations.
    mapList[2].forEach((durationMap) {
      modelMap[durationMap["activity_id"]]!.duration =
          Duration(milliseconds: durationMap["sum_value"] ?? 0);
    });

    // Banked sessions.
    mapList[3].forEach((sessionMap) {
      var model = modelMap[sessionMap["activity_id"]]!;
      if (model.duration == null) {
        model.duration = Duration();
      }
      model.duration = model.duration! -
          Duration(milliseconds: sessionMap["sum_value"] ?? 0);
    });

    // Sort alphabetically.
    List<ActivityListTileModel> result = modelMap.values.toList();
    result.sort((a, b) => a.activity.name.compareTo(b.activity.name));

    return result;
  }

  void _notifySessionsUpdated(String activityId) {
    // Technically, when a session is added, the Activity is updated, although
    // the Activity table in the DB isn't directly updated.
    _activitiesUpdated.notify();
    _sessionsUpdatedMap[activityId]?.notify();
  }
}

/// A [FutureListener] wrapper for listening for [Activity] updates.
class ActivitiesBuilder extends StatelessWidget {
  final AppManager app;
  final Widget Function(BuildContext, List<Activity>) builder;

  ActivitiesBuilder({
    required this.app,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureListener.single(
      getFutureCallback: () => app.dataManager.activities,
      stream: app.dataManager._activitiesUpdated.stream,
      builder: (context, value) => builder(context, value as List<Activity>),
    );
  }
}

/// A [FutureListener] wrapper for listening for [ActivityListTileModel]
/// updates.
class ActivityListModelBuilder extends StatelessWidget {
  final AppManager app;
  final Widget Function(BuildContext, List<ActivityListTileModel>) builder;

  ActivityListModelBuilder({
    required this.app,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureListener(
      initialValues: [app.dataManager._initialActivityListTileModels],
      futuresHaveDataCallback: () =>
          // Cleanup now unused data.
          app.dataManager._initialActivityListTileModels = const [],
      getFutureCallbacks: [
        () => app.dataManager.getActivityListModel(
          dateRange: app.preferencesManager.homeDateRange.value,
        ),
      ],
      streams: [
        app.preferencesManager.homeDateRangeStream,
        app.dataManager._activitiesUpdated.stream,
      ],
      builder: (context, result) => builder(context, result?.first),
    );
  }
}

/// A [FutureListener] wrapper for listening for [Session] updates for a given
/// [Activity].
class SessionsBuilder extends StatelessWidget {
  final AppManager app;
  final String activityId;
  final Widget Function(BuildContext, List<Session>) builder;

  SessionsBuilder({
    required this.app,
    required this.activityId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureListener.single(
      getFutureCallback: () => app.dataManager.getSessions(activityId),
      stream: app.dataManager.getSessionsUpdatedStream(activityId),
      builder: (context, value) => builder(context, value as List<Session>),
    );
  }
}