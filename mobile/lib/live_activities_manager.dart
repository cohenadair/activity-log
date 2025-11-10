import 'dart:async';

import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/dotted_version.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/root.dart';
import 'package:adair_flutter_lib/wrappers/device_info_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/url_scheme_data.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/wrappers/live_activities_wrapper.dart';
import 'package:mobile/wrappers/shared_preference_app_group_wrapper.dart';
import 'package:quiver/strings.dart';

import 'model/session.dart';

class LiveActivitiesManager {
  static var _instance = LiveActivitiesManager._();

  static LiveActivitiesManager get get => _instance;

  @visibleForTesting
  static void set(LiveActivitiesManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = LiveActivitiesManager._();

  LiveActivitiesManager._();

  static const _groupId = "group.cohenadair.activitylog";
  static const _urlScheme = "activity-log://my.app/end-activity?id=";
  static const _iosEndedActivitiesKey = "ended_activity_ids";
  static const _iosLogsKey = "logs";
  static const _iosGroupDataPollDuration = Duration(seconds: 1);

  final _log = Log("LiveActivitiesManager");
  late final LiveActivities _liveActivities;

  Timer? _iosGroupUpdatesTimer;

  Future<void> init() async {
    if (!await isSupported()) {
      _log.d("Live activities are not supported in current OS version");
      return;
    }

    _liveActivities = LiveActivitiesWrapper.get.newInstance()
      ..init(appGroupId: _groupId, urlScheme: _urlScheme);
    _liveActivities.urlSchemeStream().listen(_onUrlEvent);

    DataManager.get.sessionStream.listen(_onSessionEvent);

    if (IoWrapper.get.isIOS) {
      await SharedPreferenceAppGroupWrapper.get.setAppGroup(_groupId);
      await _checkIosGroupData();
    }
  }

  Future<bool> isSupported() async {
    if (IoWrapper.get.isAndroid) {
      return (await DeviceInfoWrapper.get.androidInfo).version.sdkInt >= 26;
    } else if (IoWrapper.get.isIOS) {
      var version = (await DeviceInfoWrapper.get.iosInfo).systemVersion;
      return DottedVersion.parse(version).major >= 17;
    }
    return false;
  }

  Future<void> _onSessionEvent(SessionEvent event) async {
    switch (event.type) {
      case SessionEventType.started:
        return _onSessionStarted(event.session);
      case SessionEventType.updated:
        return _onSessionUpdated(event.session);
      case SessionEventType.ended:
        return _onSessionEnded(event.session);
    }
  }

  Future<void> _onSessionStarted(Session session) async {
    if (SubscriptionManager.get.isFree) {
      _log.d("User is free; skipping create");
      return;
    }

    var activity = await DataManager.get.activity(session.activityId);
    if (activity == null) {
      _log.d("Can't create: ${session.activityId} doesn't exist");
      return;
    }

    _pollForIosGroupDataChanges();
    _log.d("Sending create request: ${session.activityId}");

    var bgColor = Root.get.buildContext.isDarkTheme
        ? AdairFlutterLibTheme.dark().colorScheme.surface
        : AppConfig.get.colorAppTheme;

    var id = await _liveActivities.createActivity(activity.id, {
      "url_scheme": _urlScheme,
      "activity_id": activity.id,
      "activity_name": activity.name,
      "session_start_timestamp": session.startTimestamp,
      "bg_r": bgColor.r,
      "bg_g": bgColor.g,
      "bg_b": bgColor.b,
      "bg_a": 0.6,
      "stop_bg_opacity": 0.35,
      "timer_font_size": 48.0,
      "activity_name_font_size": 20.0,
      "padding": 16.0,
      "ios_ended_activities_key": _iosEndedActivitiesKey,
    });

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

    var id = await DataManager.get.currentLiveActivityId(session.activityId);
    if (isEmpty(id)) {
      return;
    }

    _log.d("Sending update request: ${session.activityId}");

    await _liveActivities.updateActivity(id!, {
      "session_start_timestamp": session.startTimestamp,
    });
  }

  Future<void> _onSessionEnded(Session session) async {
    if (SubscriptionManager.get.isFree) {
      _log.d("User is free; skipping end");
      return;
    }

    _cancelIosGroupDataPolling();
    _log.d("Sending end request: ${session.activityId}");
    await _liveActivities.endActivity(session.activityId);
  }

  Future<void> _onUrlEvent(UrlSchemeData data) async {
    // TODO: Not needed for iOS. Confirm if needed for Android.
    _log.d("URL event: ${data.queryParameters}");

    var urlId = data.queryParameters.first["value"];
    if (urlId == null) {
      _log.d("null URL id");
      return;
    }

    _endActivity(urlId);
  }

  void _pollForIosGroupDataChanges() {
    if (IoWrapper.get.isAndroid) {
      return;
    }

    _iosGroupUpdatesTimer = Timer.periodic(
      _iosGroupDataPollDuration,
      (_) => _checkIosGroupData(),
    );
  }

  void _cancelIosGroupDataPolling() {
    _iosGroupUpdatesTimer?.cancel();
    _iosGroupUpdatesTimer = null;
  }

  Future<void> _endActivity(String id, [int? timestamp]) async {
    var activity = await DataManager.get.activity(id);
    if (activity == null) {
      _log.d("Activity id not found: $id");
      return;
    }

    _log.d("Ending session from live activity: ${activity.id}");
    await DataManager.get.endSession(activity, timestamp);
  }

  Future<void> _checkIosGroupData() async {
    if (IoWrapper.get.isAndroid) {
      return;
    }

    // Hack to print from iOS widget extensions.
    var logs = await SharedPreferenceAppGroupWrapper.get.getStringList(
      _iosLogsKey,
    );
    for (var log in logs ?? []) {
      _log.d("[iOS] $log");
    }
    await SharedPreferenceAppGroupWrapper.get.setStringList(_iosLogsKey, null);

    // Check for ended activities.
    var idTimePairs = await SharedPreferenceAppGroupWrapper.get.getStringList(
      _iosEndedActivitiesKey,
    );

    if (idTimePairs == null || idTimePairs.isEmpty) {
      return;
    }

    for (var pair in idTimePairs) {
      var split = pair.split(":");
      assert(split.length == 2, "Invalid ID-timestamp pair from group data");

      var timestamp = int.tryParse(split.last);
      assert(timestamp != null, "Invalid timestamp from group data");

      await _endActivity(split.first, timestamp);
    }

    // Clear shared data; no longer need it.
    await SharedPreferenceAppGroupWrapper.get.setStringList(
      _iosEndedActivitiesKey,
      null,
    );
  }
}
