import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';

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

  /// Returns a reference to the current user's activities, or null if there is
  /// no current user.
  CollectionReference _getActivitiesRef() {
    if (_app.authManager.userId == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .document(_app.authManager.userId)
        .collection('activities');
  }
}