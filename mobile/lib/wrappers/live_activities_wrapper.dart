import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';

class LiveActivitiesWrapper {
  static var _instance = LiveActivitiesWrapper._();

  static LiveActivitiesWrapper get get => _instance;

  @visibleForTesting
  static void set(LiveActivitiesWrapper manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = LiveActivitiesWrapper._();

  LiveActivitiesWrapper._();

  LiveActivities newInstance() => LiveActivities();
}
