import 'dart:collection';

import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/tuple.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/time.dart';

/// A class that stores summarized data for an [Activity].
class SummarizedActivity {
  final Activity value;

  /// The [DisplayDateRange] for the summary. Set to `null` for "all dates".
  final DisplayDateRange? displayDateRange;

  final List<Session> sessions;
  final Clock clock;

  Session? _cachedShortestSession;
  Session? _cachedLongestSession;

  Duration? _cachedTotalDuration;
  Duration? _cachedDurationPerDay;
  Duration? _cachedDurationPerWeek;
  Duration? _cachedDurationPerMonth;

  int? _cachedLongestStreak;
  int? _cachedCurrentStreak;

  double? _cachedSessionsPerDay;
  double? _cachedSessionsPerWeek;
  double? _cachedSessionsPerMonth;

  SummarizedActivity({
    required this.value,
    required this.displayDateRange,
    this.sessions = const [],
    this.clock = const Clock(),
  });

  int get numberOfSessions => sessions.length;

  double get sessionsPerDay {
    if (_cachedSessionsPerDay == null) {
      _calculate();
    }
    return _cachedSessionsPerDay!;
  }

  double get sessionsPerWeek {
    if (_cachedSessionsPerWeek == null) {
      _calculate();
    }
    return _cachedSessionsPerWeek!;
  }

  double get sessionsPerMonth {
    if (_cachedSessionsPerMonth == null) {
      _calculate();
    }
    return _cachedSessionsPerMonth!;
  }

  Session? get shortestSession {
    if (_cachedShortestSession == null) {
      _cachedShortestSession = min(sessions);
    }
    return _cachedShortestSession;
  }

  Session? get longestSession {
    if (_cachedLongestSession == null) {
      _cachedLongestSession = max(sessions);
    }
    return _cachedLongestSession;
  }

  Duration get averageDurationOverall => getAverageDuration(numberOfSessions);

  Duration get totalDuration {
    if (_cachedTotalDuration == null) {
      _calculate();
    }
    return _cachedTotalDuration!;
  }

  Duration get averageDurationPerDay {
    if (_cachedDurationPerDay == null) {
      _calculate();
    }
    return _cachedDurationPerDay!;
  }

  Duration get averageDurationPerWeek {
    if (_cachedDurationPerWeek == null) {
      _calculate();
    }
    return _cachedDurationPerWeek!;
  }

  Duration get averageDurationPerMonth {
    if (_cachedDurationPerMonth == null) {
      _calculate();
    }
    return _cachedDurationPerMonth!;
  }

  int get longestStreak {
    if (_cachedLongestStreak == null) {
      _calculate();
    }
    return _cachedLongestStreak!;
  }

  int get currentStreak {
    if (_cachedCurrentStreak == null) {
      _calculate();
    }
    return _cachedCurrentStreak!;
  }

  void _calculate() {
    if (sessions.isEmpty) {
      _cachedTotalDuration = Duration();
      _cachedDurationPerDay = Duration();
      _cachedDurationPerWeek = Duration();
      _cachedDurationPerMonth = Duration();
      _cachedLongestStreak = 0;
      _cachedCurrentStreak = 0;
      _cachedSessionsPerDay = 0;
      _cachedSessionsPerWeek = 0;
      _cachedSessionsPerMonth = 0;
      return;
    }

    sessions.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
    Set<DateTime> allDateTimes = SplayTreeSet();

    int totalMs = 0;
    sessions.forEach((Session session) {
      totalMs += session.millisecondsDuration;
      allDateTimes.add(dateTimeToDayAccuracy(session.startDateTime));

      if (session.endDateTime != null) {
        allDateTimes.add(dateTimeToDayAccuracy(session.endDateTime!));
      }
    });

    _cachedTotalDuration = Duration(milliseconds: totalMs);

    // If the date range is null, restrict the range to the earliest
    // and latest sessions.
    DateRange range = displayDateRange == null
        ? DateRange(
            startDate: sessions.first.startDateTime,
            endDate: sessions.last.endDateTime ?? clock.now(),
          )
        : displayDateRange!.getValue(clock.now());

    _cachedDurationPerDay = getAverageDuration(range.days);
    _cachedDurationPerWeek = getAverageDuration(range.weeks);
    _cachedDurationPerMonth = getAverageDuration(range.months);

    // Iterate all days, keeping track of the longest streak.
    int currentStreak = 1;
    bool didResetStreak = false;
    _cachedLongestStreak = currentStreak;

    List<DateTime> dateTimeList = List.from(allDateTimes);
    dateTimeList.sort((lhs, rhs) => rhs.compareTo(lhs));
    DateTime last = dateTimeList.first;
    _cachedCurrentStreak = isSameDate(DateTime.now(), last) ? 1 : 0;

    for (int i = 1; i < dateTimeList.length; i++) {
      DateTime current = dateTimeList[i];
      DateTime lastsTomorrow = DateTime.fromMillisecondsSinceEpoch(
          last.millisecondsSinceEpoch - Duration.millisecondsPerDay);

      if (isSameYear(current, lastsTomorrow) &&
          isSameMonth(current, lastsTomorrow) &&
          current.day == lastsTomorrow.day) {
        if (!didResetStreak) {
          _cachedCurrentStreak = _cachedCurrentStreak! + 1;
        }
        currentStreak++;
      } else {
        didResetStreak = true;
        currentStreak = 1;
      }

      if (_cachedLongestStreak == null ||
          currentStreak > _cachedLongestStreak!) {
        _cachedLongestStreak = currentStreak;
      }

      last = current;
    }

    _cachedSessionsPerDay = getAverageSessions(range.days);
    _cachedSessionsPerWeek = getAverageSessions(range.weeks);
    _cachedSessionsPerMonth = getAverageSessions(range.months);
  }

  Duration getAverageDuration(num divisor) {
    if (divisor <= 0) {
      return Duration();
    }

    return Duration(milliseconds: (totalDuration.inMilliseconds / divisor)
        .round());
  }

  double getAverageSessions(num divisor) {
    if (divisor <= 0) {
      return 0;
    }

    return numberOfSessions / divisor;
  }

  @override
  String toString() {
    return "{activity=${value.name}; duration=$totalDuration; "
        + "numberOfSessions=$numberOfSessions}";
  }
}

/// A class that stores summarized data for multiple [Activity] objects,
/// including summary data across all of its activities.
class SummarizedActivityList {
  final List<SummarizedActivity> activities;

  Tuple<Activity, Session>? _cachedLongestSession;
  Tuple<Activity, int>? _cachedMostFrequentActivity;

  List<SummarizedActivity>? _cachedActivitiesSortedByDuration;
  List<SummarizedActivity>? _cachedActivitiesSortedByNumberOfSessions;
  int? _cachedTotalDuration;

  SummarizedActivityList(this.activities);

  /// A [Tuple] of [Activity] and its longest [Session].
  Tuple<Activity, Session>? get longestSession {
    if (_cachedLongestSession == null) {
      _calculate();
    }
    return _cachedLongestSession;
  }

  /// A [Tuple] of [Activity] and its number of sessions.
  Tuple<Activity, int>? get mostFrequentActivity {
    if (_cachedMostFrequentActivity == null) {
      _calculate();
    }
    return _cachedMostFrequentActivity;
  }

  int get totalDuration {
    if (_cachedTotalDuration == null) {
      _calculate();
    }
    return _cachedTotalDuration!;
  }

  /// Returns a copy of `activities`, sorted descending by total duration.
  List<SummarizedActivity>? get activitiesSortedByDuration {
    if (_cachedActivitiesSortedByDuration == null) {
      List<SummarizedActivity> copy = List.of(activities);
      copy.sort((SummarizedActivity a, SummarizedActivity b) =>
          b.totalDuration.compareTo(a.totalDuration));
      _cachedActivitiesSortedByDuration = copy;
    }
    return _cachedActivitiesSortedByDuration;
  }

  /// Returns a copy of `activities`, sorted descending by number of sessions.
  List<SummarizedActivity>? get activitiesSortedByNumberOfSessions {
    if (_cachedActivitiesSortedByNumberOfSessions == null) {
      List<SummarizedActivity> copy = List.of(activities);
      copy.sort((SummarizedActivity a, SummarizedActivity b) =>
          b.numberOfSessions.compareTo(a.numberOfSessions));
      _cachedActivitiesSortedByNumberOfSessions = copy;
    }
    return _cachedActivitiesSortedByNumberOfSessions;
  }

  void _calculate() {
    _cachedTotalDuration = 0;

    activities.forEach((SummarizedActivity activity) {
      if (_cachedMostFrequentActivity == null
          || activity.sessions.length > _cachedMostFrequentActivity!.second)
      {
        _cachedMostFrequentActivity =
            Tuple(activity.value, activity.sessions.length);
      }

      activity.sessions.forEach((Session session) {
        if (_cachedLongestSession == null
            || session > _cachedLongestSession!.second)
        {
          _cachedLongestSession = Tuple(activity.value, session);
        }
      });

      _cachedTotalDuration =
          _cachedTotalDuration! + activity.totalDuration.inMilliseconds;
    });
  }
}