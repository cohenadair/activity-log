import 'dart:async';

import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/url_scheme_data.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/wrappers/live_activities_wrapper.dart';
import 'package:mobile/wrappers/shared_preference_app_group_wrapper.dart';

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
    _liveActivities = LiveActivitiesWrapper.get.newInstance()
      ..init(appGroupId: _groupId, urlScheme: _urlScheme);
    _liveActivities.urlSchemeStream().listen(_onUrlEvent);

    await SharedPreferenceAppGroupWrapper.get.setAppGroup(_groupId);

    if (await isSupported) {
      DataManager.get.sessionStartedStream.listen(_onSessionStarted);
      DataManager.get.sessionEndedStream.listen(_onSessionEnded);
      await _endActivitiesFromIosGroupData();
    } else {
      _log.d("Live activities are not supported in current OS version");
    }
  }

  Future<bool> get isSupported => _liveActivities.areActivitiesSupported();

  Future<void> _onSessionStarted(Session session) async {
    if (SubscriptionManager.get.isFree) {
      _log.d("User is free; skipping live activity");
      return;
    }

    var activity = await DataManager.get.activity(session.activityId);
    if (activity == null) {
      _log.d("Can't create activity: ${session.activityId} doesn't exist");
      return;
    }

    _pollForIosGroupDataChanges();
    _log.d("Starting live activity: ${session.activityId}");
    await _liveActivities.createActivity(activity.id, {
      "url_scheme": _urlScheme,
      "activity_id": activity.id,
      "activity_name": activity.name,
      "session_start_timestamp": session.startTimestamp,
      "background_red": AppConfig.get.colorAppTheme.r,
      "background_green": AppConfig.get.colorAppTheme.g,
      "background_blue": AppConfig.get.colorAppTheme.b,
      "background_opacity": 50,
      "ios_ended_activities_key": _iosEndedActivitiesKey,
    });
  }

  Future<void> _onSessionEnded(Session session) async {
    _cancelIosGroupDataPolling();
    _log.d("Ending live activity: ${session.activityId}");
    await _liveActivities.endActivity(session.activityId);
  }

  Future<void> _onUrlEvent(UrlSchemeData data) async {
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
      (_) => _endActivitiesFromIosGroupData(),
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

  Future<void> _endActivitiesFromIosGroupData() async {
    // Hack to print from iOS widget extensions.
    var logs = await SharedPreferenceAppGroupWrapper.get.getStringList(
      _iosLogsKey,
    );
    for (var log in logs ?? []) {
      _log.d("[iOS] $log");
    }
    await SharedPreferenceAppGroupWrapper.get.setStringList(_iosLogsKey, null);

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
