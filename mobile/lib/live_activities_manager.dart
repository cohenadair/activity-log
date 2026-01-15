import 'dart:async';
import 'dart:convert';

import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/managers/manager.dart';
import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/dotted_version.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/root.dart';
import 'package:adair_flutter_lib/wrappers/device_info_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_activities/live_activities.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/wrappers/live_activities_wrapper.dart';
import 'package:mobile/wrappers/shared_preference_app_group_wrapper.dart';
import 'package:mobile/wrappers/shared_preferences_wrapper.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import 'model/session.dart';

class LiveActivitiesManager implements Manager {
  static var _instance = LiveActivitiesManager._();

  static LiveActivitiesManager get get => _instance;

  @visibleForTesting
  static void set(LiveActivitiesManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = LiveActivitiesManager._();

  LiveActivitiesManager._();

  static const _groupId = "group.cohenadair.activitylog";
  static const _endedActivitiesKey = "ended_activity_ids";
  static const _groupDataPollDuration = Duration(seconds: 1);
  static const _iosLogsKey = "logs";

  final _log = Log("LiveActivitiesManager");
  late final LiveActivities _liveActivities;
  late final SharedPreferencesAsync _androidPrefs;

  Timer? _groupUpdatesTimer;

  @override
  Future<void> init() async {
    if (!await isSupported()) {
      _log.d("Live activities are not supported in current OS version");
      return;
    }

    _liveActivities = LiveActivitiesWrapper.get.newInstance();
    await _liveActivities.init(
      appGroupId: _groupId,
      requireNotificationPermission: false,
    );

    DataManager.get.sessionStream.listen(_onSessionEvent);

    if (IoWrapper.get.isIOS) {
      await SharedPreferenceAppGroupWrapper.get.setAppGroup(_groupId);
    } else {
      _androidPrefs = SharedPreferencesWrapper.get.sharedPreferencesAsync(
        options: SharedPreferencesAsyncAndroidOptions(
          backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
          originalSharedPreferencesOptions:
              AndroidSharedPreferencesStoreOptions(fileName: _groupId),
        ),
      );
    }

    await _checkGroupData();
  }

  Future<bool> isSupported() async {
    if (IoWrapper.get.isAndroid) {
      return (await DeviceInfoWrapper.get.androidInfo).version.sdkInt >= 26;
    } else {
      final version = (await DeviceInfoWrapper.get.iosInfo).systemVersion;
      return DottedVersion.parse(version).major >= 17;
    }
  }

  Future<void> _onSessionEvent(SessionEvent event) async {
    switch (event.type) {
      case SessionEventType.started:
        return _onSessionStarted(event.session);
      case SessionEventType.updated:
        return _onSessionUpdated(event.session);
      case SessionEventType.ended:
      case SessionEventType.deleted:
        return _onSessionEndedOrDeleted(event.session);
    }
  }

  Future<void> _onSessionStarted(Session session) async {
    if (SubscriptionManager.get.isFree) {
      _log.d("User is free; skipping create");
      return;
    }

    final activity = await DataManager.get.activity(session.activityId);
    if (activity == null) {
      _log.d("Can't create: ${session.activityId} doesn't exist");
      return;
    }

    _pollForGroupDataChanges();
    _log.d("Sending create request: ${session.activityId}");

    final bgColor = Root.get.buildContext.isDarkTheme
        ? AdairFlutterLibTheme.dark().colorScheme.surface
        : AppConfig.get.colorAppTheme;

    String? id;
    try {
      id = await _liveActivities.createActivity(activity.id, {
        "activity_id": activity.id,
        "activity_name": activity.name,
        "session_start_timestamp": session.startTimestamp,
        "tint_r": bgColor.r,
        "tint_g": bgColor.g,
        "tint_b": bgColor.b,
        "tint_a": 0.6,
      });
    } on PlatformException catch (e) {
      if (e.details is String &&
          e.details.contains("User has denied activities")) {
        _log.d("User has disallowed live activities");
        return;
      }

      _log.e(e, reason: "Live activity creation");
      return;
    }

    if (id == null) {
      _log.d("Live activity creation failed for activity ${activity.id}");
      return;
    }

    await DataManager.get.updateActivity(
      (ActivityBuilder.fromActivity(
        activity,
      )..currentLiveActivityId = id).build,
    );
  }

  Future<void> _onSessionUpdated(Session session) async {
    if (SubscriptionManager.get.isFree) {
      _log.d("User is free; skipping update");
      return;
    }

    final id = await DataManager.get.currentLiveActivityId(session.activityId);
    if (isEmpty(id)) {
      return;
    }

    _log.d("Sending update request: ${session.activityId}");

    await _liveActivities.updateActivity(id!, {
      "session_start_timestamp": session.startTimestamp,
    });
  }

  Future<void> _onSessionEndedOrDeleted(Session session) async {
    if (SubscriptionManager.get.isFree) {
      _log.d("User is free; skipping end");
      return;
    }

    _cancelGroupDataPolling();
    _log.d("Sending end request: ${session.activityId}");
    await _liveActivities.endActivity(session.activityId);
  }

  void _pollForGroupDataChanges() {
    _groupUpdatesTimer = Timer.periodic(
      _groupDataPollDuration,
      (_) => _checkGroupData(),
    );
  }

  void _cancelGroupDataPolling() {
    _groupUpdatesTimer?.cancel();
    _groupUpdatesTimer = null;
  }

  Future<void> _endActivity(String id, [int? timestamp]) async {
    final activity = await DataManager.get.activity(id);
    if (activity == null) {
      _log.d("Activity id not found: $id");
      return;
    }

    _log.d("Ending session from live activity: ${activity.id}");
    await DataManager.get.endSession(activity, timestamp);
  }

  Future<void> _checkGroupDataIos() async {
    // Hack to print from iOS widget extensions.
    final logs = await SharedPreferenceAppGroupWrapper.get.getStringList(
      _iosLogsKey,
    );
    for (var log in logs ?? []) {
      _log.d("[iOS] $log");
    }
    await SharedPreferenceAppGroupWrapper.get.setStringList(_iosLogsKey, null);

    await _checkGroupDataForEndedActivities(
      endedActivities: SharedPreferenceAppGroupWrapper.get.getStringList,
      clearEndedActivities: (key) =>
          SharedPreferenceAppGroupWrapper.get.setStringList(key, null),
    );
  }

  Future<void> _checkGroupDataAndroid() async {
    await _checkGroupDataForEndedActivities(
      endedActivities: (key) async {
        final prefs = await _androidPrefs.getString(key);
        // Note that SharedPreferences on Android doesn't support String lists,
        // only sets, which don't translate to Flutter, so we use a JSON array
        // instead.
        return isEmpty(prefs) ? null : List<String>.from(jsonDecode(prefs!));
      },
      clearEndedActivities: (key) => _androidPrefs.setString(key, ""),
    );
  }

  Future<void> _checkGroupDataForEndedActivities({
    required Future<List<String>?> Function(String key) endedActivities,
    required Future<void> Function(String key) clearEndedActivities,
  }) async {
    final idTimePairs = await endedActivities(_endedActivitiesKey);

    if (idTimePairs == null || idTimePairs.isEmpty) {
      return;
    }

    for (var pair in idTimePairs) {
      final split = pair.split(":");
      assert(split.length == 2, "Invalid ID-timestamp pair from group data");

      final timestamp = int.tryParse(split.last);
      assert(timestamp != null, "Invalid timestamp from group data");

      await _endActivity(split.first, timestamp);
    }

    // Clear shared data; no longer need it.
    await clearEndedActivities(_endedActivitiesKey);
  }

  Future<void> _checkGroupData() async {
    if (IoWrapper.get.isIOS) {
      await _checkGroupDataIos();
    } else {
      await _checkGroupDataAndroid();
    }
  }
}
