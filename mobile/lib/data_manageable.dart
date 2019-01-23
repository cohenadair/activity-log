import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';

abstract class DataManageable {
  /// Returns a stream that is notified on Activity data updates.
  Stream<List<Activity>> get activitiesUpdated;

  /// Returns a stream that is notified when a session starts or ends.
  Stream<Session> get sessionStateChanged;

  void addOrUpdateActivity(Activity activity);
  void removeActivity(String activityId);

  void startSession(Activity activity);
  void endSession(Activity activity);
  Future<List<Session>> getSessions(String activityId);

  Future<bool> activityNameExists(String name);
}