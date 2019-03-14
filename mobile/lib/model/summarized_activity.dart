import 'package:flutter/material.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/tuple.dart';

/// A class that stores summarized data for an [Activity].
@immutable
class SummarizedActivity {
  final Activity value;
  final Duration totalDuration;
  final List<Session> sessions;

  SummarizedActivity({
    @required this.value,
    this.totalDuration = const Duration(),
    this.sessions,
  }) : assert(value != null);

  int get numberOfSessions => sessions.length;

  @override
  String toString() {
    return "{activity=${value.name}; duration=$totalDuration; "
        + "numberOfSessions=$numberOfSessions}";
  }
}

/// A class that stores summarized data for multiple [Activity] objects,
/// including summary data across all of its activities.
@immutable
class SummarizedActivityList {
  final List<SummarizedActivity> activities;

  /// A [Tuple] of [Activity] and its longest [Session].
  final Tuple<Activity, Session> longestSession;

  /// A [Tuple] of [Activity] and its number of sessions.
  final Tuple<Activity, int> mostFrequentActivity;

  SummarizedActivityList({
    this.activities,
    this.longestSession,
    this.mostFrequentActivity
  });
}