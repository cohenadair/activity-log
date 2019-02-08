import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';

abstract class DataManageable {
  /// Returns a stream that is notified on Activity data updates.
  ///
  /// Subscribe to this stream to be notified when activities are added,
  /// removed, or modified.
  Stream<List<Activity>> get activitiesUpdated;

  /// Returns a stream that is notified on Session data updates. All Session
  /// objects returned are guaranteed to belong to the same Activity.
  ///
  /// Subscribe to this stream to be notified when sessions are added, removed,
  /// or modified from any Activity.
  Stream<List<Session>> get sessionsUpdated;

  void addActivity(Activity activity);
  void updateActivity(Activity activity);
  void removeActivity(String activityId);

  /// Creates and starts a new Session for the given Activity.
  void startSession(Activity activity);
  void endSession(Activity activity);
  void addSession(Session session);
  void updateSession(Session session);
  void removeSession(Session session);
  Future<List<Session>> getSessions(String activityId);
  Future<List<Session>> getRecentSessions(String activityId, int limit);
  Future<int> getSessionCount(String activityId);

  /// Returns the current session for the given Activity ID, or `null` if
  /// the given Activity isn't running.
  Future<Session> getCurrentSession(String activityId);

  /// Case-insensitive compare of a given name to all other activity names.
  Future<bool> activityNameExists(String name);
}