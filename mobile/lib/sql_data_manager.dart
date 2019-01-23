import 'dart:async';

import 'package:mobile/data_manageable.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';

class SQLiteDataManager implements DataManageable {
  final StreamController<List<Activity>> _activitiesUpdated;
  final StreamController<Session> _sessionStateChanged;

  SQLiteDataManager()
      : _activitiesUpdated = StreamController.broadcast(),
        _sessionStateChanged = StreamController.broadcast()
  {
    // When a new listener is added, trigger an event so the listener receives
    // the activity list immediately.
    _activitiesUpdated.onListen = () {
      _getActivities().then((List<Activity> activities) {
        _activitiesUpdated.add(activities);
      });
    };
  }

  @override
  Stream<List<Activity>> get activitiesUpdated => _activitiesUpdated.stream;

  @override
  Stream<Session> get sessionStateChanged => _sessionStateChanged.stream;

  Future<List<Activity>> _getActivities() async {
    return List(0);
  }

  @override
  void addOrUpdateActivity(Activity activity) {

  }

  @override
  void removeActivity(String activityId) {

  }

  @override
  void startSession(Activity activity) {

  }

  @override
  void endSession(Activity activity) {

  }

  @override
  Future<List<Session>> getSessions(String activityId) async {
    return List(0);
  }

  @override
  Future<bool> activityNameExists(String name) async {
    return false;
  }
}