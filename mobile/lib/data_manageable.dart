import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';

abstract class DataManageable {
  /// Returns a stream that is notified on Activity data updates.
  Stream<List<Activity>> get activitiesUpdated;

  void addActivity(Activity activity);
  void updateActivity(Activity activity);
  void removeActivity(String activityId);

  void startSession(Activity activity);
  void endSession(Activity activity);
  Future<List<Session>> getSessions(String activityId);

  /// Case-insensitive compare of a given name to all other activity names.
  Future<bool> activityNameExists(String name);
}