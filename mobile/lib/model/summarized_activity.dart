import 'package:flutter/material.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/tuple.dart';
import 'package:quiver/iterables.dart';

/// A class that stores summarized data for an [Activity].
class SummarizedActivity {
  final Activity value;
  final Duration totalDuration;
  final List<Session> sessions;

  Session _cachedShortestSession;
  Session _cachedLongestSession;

  Duration _cachedDurationPerDay;
  Duration _cachedDurationPerWeek;
  Duration _cachedDurationPerMonth;

  SummarizedActivity({
    @required this.value,
    this.totalDuration = const Duration(),
    this.sessions,
  }) : assert(value != null),
       assert(totalDuration != null);

  int get numberOfSessions => sessions == null ? 0 : sessions.length;

  Session get shortestSession {
    if (_cachedShortestSession == null) {
      _cachedShortestSession = min(sessions);
    }
    return _cachedShortestSession;
  }

  Session get longestSession {
    if (_cachedLongestSession == null) {
      _cachedLongestSession = max(sessions);
    }
    return _cachedLongestSession;
  }

  Duration get averageDurationOverall => getAverage(numberOfSessions);

  Duration get averageDurationPerDay {
    if (_cachedDurationPerDay == null) {
      _calculateAverages();
    }
    return _cachedDurationPerDay;
  }

  Duration get averageDurationPerWeek {
    if (_cachedDurationPerWeek == null) {
      _calculateAverages();
    }
    return _cachedDurationPerWeek;
  }

  Duration get averageDurationPerMonth {
    if (_cachedDurationPerMonth == null) {
      _calculateAverages();
    }
    return _cachedDurationPerMonth;
  }

  void _calculateAverages() {
    if (sessions == null || sessions.isEmpty) {
      _cachedDurationPerDay = Duration();
      _cachedDurationPerWeek = Duration();
      _cachedDurationPerMonth = Duration();
      return;
    }

    Session earliestSession = sessions.first;
    Session latestSession = sessions.first;

    sessions.forEach((Session session) {
      if (session.startTimestamp < earliestSession.startTimestamp) {
        earliestSession = session;
      }

      if (session.endTimestamp > latestSession.endTimestamp) {
        latestSession = session;
      }
    });

    Duration difference =
        latestSession.endDateTime.difference(earliestSession.startDateTime);
    int numberOfDays = difference.inDays + 1;

    _cachedDurationPerDay = getAverage(numberOfDays);
    _cachedDurationPerWeek =
        getAverage((numberOfDays / DateTime.daysPerWeek).floor() + 1);

    DateTime startDate = earliestSession.startDateTime;
    DateTime endDate = latestSession.endDateTime;

    int numberOfMonths = 0;
    if (isSameYear(startDate, endDate)) {
      numberOfMonths = endDate.month - startDate.month + 1;
    } else {
      numberOfMonths = endDate.month +
          (DateTime.monthsPerYear - startDate.month + 1);
    }

    _cachedDurationPerMonth = getAverage(numberOfMonths);
  }

  Duration getAverage(int divisor) {
    if (divisor <= 0) {
      return Duration();
    }

    return Duration(milliseconds: (totalDuration.inMilliseconds / divisor)
        .round());
  }

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