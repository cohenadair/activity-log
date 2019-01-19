import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/time_utils.dart';

class DataManager {
  final AppManager _app;
  final Firestore _firestore = Firestore.instance;

  DataManager(this._app);

  /// Returns a StreamBuilder that displays the given widgets upon changes to
  /// the current user's activity collection.
  Widget getActivitiesListenerWidget({
    @required Widget loading,
    @required Widget error,
    @required Widget Function(List<Activity>) display,
  }) {
    CollectionReference activitiesRef = _getActivitiesRef();
    if (activitiesRef == null) {
      return error;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: activitiesRef.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return error;
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading;
        } else {
          return display(snapshot.data.documents.map((DocumentSnapshot doc) {
            return Activity.fromFirestore(doc);
          }).toList());
        }
      },
    );
  }

  DocumentReference _getUserRef() {
    return _firestore
        .collection('users')
        .document(_app.authManager.userId);
  }

  CollectionReference _getActivitiesRef() {
    return _getUserRef().collection('activities');
  }

  CollectionReference _getSessionsRef() {
    return _getUserRef().collection('sessions');
  }

  DocumentReference _getActivityRef(String activityId) {
    return _getActivitiesRef().document(activityId);
  }

  Query _getSessionsQuery(String activityId) {
    return _getSessionsRef().where(
      Session.keyActivityId,
      isEqualTo: activityId
    );
  }

  Future<void> addOrUpdateActivity(Activity activity) {
    return _getActivitiesRef().document(activity.id).setData(activity.toMap());
  }

  Future<void> removeActivity(String activityId) async {
    // Stash all sessions for the given activity, so the deleting can be done
    // in a transaction.
    QuerySnapshot snapshot = await _getSessionsQuery(activityId).getDocuments();

    await _firestore.runTransaction((Transaction tx) async {
      // Delete Activity.
      await tx.delete(_getActivitiesRef().document(activityId));

      // Delete all the Activity's sessions.
      snapshot.documents.forEach((DocumentSnapshot doc) async {
        await tx.delete(doc.reference);
      });
    });
  }

  Future<void> startSession(Activity activity) async {
    if (activity.isRunning) {
      // Can't start a session for an activity that is already running.
      return null;
    }

    DocumentReference activityDoc = _getActivityRef(activity.id);
    CollectionReference sessionsRef = _getSessionsRef();

    await _firestore.runTransaction((Transaction tx) async {
      // Add new session.
      Session newSession = SessionBuilder(activity.id).build;
      await tx.set(sessionsRef.document(newSession.id), newSession.toMap());

      // Update activity.
      Activity updatedActivity = (ActivityBuilder.fromActivity(activity)
          ..currentSessionId = newSession.id)
          .build;
      await tx.update(activityDoc, updatedActivity.toMap());
    });
  }

  Future<void> endSession(Activity activity) async {
    if (!activity.isRunning) {
      return null;
    }

    DocumentReference activityDoc = _getActivityRef(activity.id);
    DocumentReference sessionDoc =
        _getSessionsRef().document(activity.currentSessionId);

    await _firestore.runTransaction((Transaction tx) async {
      Session session = Session.fromFirestore(await tx.get(sessionDoc));

      // Update current session.
      Session updatedSession =
          SessionBuilder.fromSession(session).endNow().build;
      await tx.update(sessionDoc, updatedSession.toMap());

      // Update activity.
      Activity updatedActivity = (ActivityBuilder.fromActivity(activity)
          ..currentSessionId = null)
          .build;
      await tx.update(activityDoc, updatedActivity.toMap());
    });
  }

  /// Trimmed, case-insensitive compare of 'name' to all other activities.
  Future<bool> activityNameExists(String name) async {
    QuerySnapshot snapshot = await _getActivitiesRef().where(
      Activity.keyLowercaseName,
      isEqualTo: name.trim().toLowerCase()
    ).getDocuments();

    return snapshot.documents.isNotEmpty;
  }

  Future<String> getDisplayDuration(String activityId) async {
    QuerySnapshot snapshot = await _getSessionsQuery(activityId).getDocuments();

    int totalMillis = 0;

    // Add all previous sessions.
    snapshot.documents.forEach((DocumentSnapshot doc) {
      totalMillis += Session.fromFirestore(doc).millisecondsDuration;
    });

    int hours = (totalMillis / TimeUtils.msInHour).floor();
    totalMillis -= hours * TimeUtils.msInHour;
    int minutes = (totalMillis / TimeUtils.msInMinute).floor();
    totalMillis -= minutes * TimeUtils.msInMinute;
    int seconds = (totalMillis / TimeUtils.msInSecond).floor();

    return _formatDisplayDuration(hours, minutes, seconds);
  }

  String getZeroDisplayDuration() {
    return _formatDisplayDuration(0, 0, 0);
  }

  String _formatDisplayDuration(int hours, int minutes, int seconds) {
    return hours.toString() + 'h ' + minutes.toString() + 'm ' +
        seconds.toString() + 's';
  }
}