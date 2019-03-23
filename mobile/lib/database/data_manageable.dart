import 'dart:async';

import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:sqflite/sqflite.dart';

/// Returns true if the stream should be notified immediately.
typedef StreamHandler<T> = bool Function(Stream<T>);

abstract class DataManageable {
  void initialize(Database database);

  /// Call this method to be notified when activities are added,
  /// removed, or modified.
  ///
  /// If `notifyNow` returns true, the stream will be notified immediately,
  /// for example, when using a `StreamBuilder` widget.
  void getActivitiesUpdateStream(StreamHandler<List<Activity>> notifyNow);

  /// Call this method to be notified when sessions are added, removed,
  /// or modified from the given Activity ID.
  ///
  /// If `notifyNow` returns true, the stream will be notified immediately,
  /// for example, when using a `StreamBuilder` widget.
  void getSessionsUpdatedStream(String activityId,
      StreamHandler<List<Session>> notifyNow);

  void addActivity(Activity activity);
  void updateActivity(Activity activity);
  void removeActivity(String activityId);

  /// Creates and starts a new [Session] for the given [Activity]. If the given
  /// [Activity] is already running, this method does nothing. Returns the ID
  /// of the new [Session].
  Future<String> startSession(Activity activity);

  /// Ends the session for the given [Activity]. This method does nothing if
  /// the given [Activity] isn't running. Always returns null, which can be
  /// ignored.
  Future<void> endSession(Activity activity);

  void addSession(Session session);
  void updateSession(Session session);
  void removeSession(Session session);
  Future<List<Session>> getSessions(String activityId);
  Future<List<Session>> getRecentSessions(String activityId, int limit);
  Future<int> getSessionCount(String activityId);

  /// Returns the [Session] the given session overlaps with, if one exists;
  /// `null` otherwise.
  Future<Session> getOverlappingSession(Session session);

  /// Returns the session with the given ID, or `null` if one isn't found.
  Future<Session> getSession(String sessionId);

  /// Case-insensitive compare of a given name to all other activity names.
  Future<bool> activityNameExists(String name);

  /// Returns a list of [SummarizedActivity] objects within the given date
  /// range. If the activities parameter is not `null`, the result is
  /// restricted to only those activities.
  ///
  /// Note that this will return a [SummarizedActivity], even if there were no
  /// sessions for the associated [Activity] within the given [DateRange].
  ///
  /// If the given [DateRange] is `null`, the result will include all [Session]
  /// objects associated with each [Activity].
  Future<SummarizedActivityList> getSummarizedActivities(DateRange dateRange,
      [List<Activity> activities]);

  /// Returns the total [Duration] for the given [Activity] ID. The result does
  /// not include in-progress sessions.
  Future<Duration> getTotalDuration(String activityId);

  /// Returns an [Activity.id]-to-[Duration] mapping for the total [Duration]
  /// of all [Activity] objects. The result does not include in-progress
  /// sessions.
  Future<Map<String, Duration>> getTotalDurations();
}