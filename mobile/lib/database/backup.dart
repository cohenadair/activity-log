import 'dart:async';
import 'dart:convert';

import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:quiver/time.dart';

const _keyBackupActivities = "activities";
const _keyBackupSessions = "sessions";

const _keyBackupPreferences = "preferences";
const _keyBackupPreferencesLargestDurationUnit = "largest_duration_unit";
const _keyBackupPreferencesHomeDateRange = "home_date_range";

/// Returns a JSON [String] representation of the given [AppManager] database,
/// or `null` if there was an error.
Future<String> export(AppManager app, {
  Clock clock = const Clock(),
}) async {
  Map<String, dynamic> jsonMap = Map();

  // Activities.
  List<Activity> activityList = await app.dataManager.activities;
  jsonMap[_keyBackupActivities] = activityList.map((activity) {
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
  List<Session> sessionList = await app.dataManager.sessions;
  jsonMap[_keyBackupSessions] = sessionList.map((session) {
    if (session.inProgress) {
      // End any running sessions. This ensures that when the database
      // is imported, there isn't a potentially long session in progress.
      session = (SessionBuilder.fromSession(session)..clock = clock)
          .endNow()
          .build;
    }
    return session.toMap();
  }).toList();

  // Preferences.
  jsonMap[_keyBackupPreferences] = Map<String, dynamic>();
  jsonMap[_keyBackupPreferences][_keyBackupPreferencesLargestDurationUnit] =
      app.preferencesManager.largestDurationUnit.index;
  jsonMap[_keyBackupPreferences][_keyBackupPreferencesHomeDateRange] =
      app.preferencesManager.homeDateRange.id;

  return jsonEncode(jsonMap);
}