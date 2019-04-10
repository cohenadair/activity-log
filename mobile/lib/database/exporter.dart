import 'dart:async';
import 'dart:convert';

import 'package:mobile/app_manager.dart';
import 'package:mobile/database/backup_utils.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:quiver/time.dart';

/// Class for exporting app data to a JSON file.
class Exporter {
  final AppManager _app;
  final Clock _clock;

  Exporter(this._app, {
    Clock clock = const Clock(),
  }) : _clock = clock;

  /// Returns a [Map] representation of the given [AppManager] database.
  /// Format:
  /// {
  ///   "activities" : [],
  ///   "sessions" : [],
  ///   "preferences" : {},
  /// }
  Future<Map<String, dynamic>> get _jsonMap async {
    Map<String, dynamic> result = Map();

    // Activities.
    List<Activity> activityList = await _app.dataManager.activities;
    result[keyBackupActivities] = activityList.map((activity) {
      if (activity.isRunning) {
        // End any running activities. This ensures that when the database
        // is imported, there isn't a potentially long session in progress.
        activity = (ActivityBuilder.fromActivity(activity)
          ..currentSessionId = null)
            .build;
      }

      return activity.toMap();
    }).toList();

    // Sessions.
    List<Session> sessionList = await _app.dataManager.sessions;
    result[keyBackupSessions] = sessionList.map((session) {
      if (session.inProgress) {
        // End any running sessions. This ensures that when the database
        // is imported, there isn't a potentially long session in progress.
        session = (SessionBuilder.fromSession(session)..clock = _clock)
            .endNow()
            .build;
      }
      return session.toMap();
    }).toList();

    // Preferences.
    result[keyBackupPreferences] = Map<String, dynamic>();
    result[keyBackupPreferences][keyBackupPreferencesLargestDurationUnit] =
        _app.preferencesManager.largestDurationUnit.index;
    result[keyBackupPreferences][keyBackupPreferencesHomeDateRange] =
        _app.preferencesManager.homeDateRange.id;

    return result;
  }

  /// Returns a JSON [String] representation of the given [AppManager] database,
  /// or `null` if there was an error.
  Future<String> get toJsonString async {
    return jsonEncode(await _jsonMap);
  }
}