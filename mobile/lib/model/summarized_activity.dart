import 'dart:collection';

import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/tuple.dart';
import 'package:mobile/widgets/average_durations_list_item.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/time.dart';
import 'package:timezone/timezone.dart';

/// A class that stores summarized data for an [Activity].
class SummarizedActivity {
  final Activity value;

  /// The [DateRange] for the summary. Set to `null` for "all dates".
  final DateRange? dateRange;

  final List<Session> sessions;

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
    required this.dateRange,
    this.sessions = const [],
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
    _cachedShortestSession ??= min(sessions);
    return _cachedShortestSession;
  }

  Session? get longestSession {
    _cachedLongestSession ??= max(sessions);
    return _cachedLongestSession;
  }

  Duration get averageDurationOverall =>
      averageDuration(totalDuration.inMilliseconds, numberOfSessions);

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

  AverageDurations get averageDurations {
    return AverageDurations(
      overall: averageDurationOverall,
      perDay: averageDurationPerDay,
      perWeek: averageDurationPerWeek,
      perMonth: averageDurationPerMonth,
    );
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
      _cachedTotalDuration = const Duration();
      _cachedDurationPerDay = const Duration();
      _cachedDurationPerWeek = const Duration();
      _cachedDurationPerMonth = const Duration();
      _cachedLongestStreak = 0;
      _cachedCurrentStreak = 0;
      _cachedSessionsPerDay = 0;
      _cachedSessionsPerWeek = 0;
      _cachedSessionsPerMonth = 0;
      return;
    }

    sessions.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
    var allDateTimes = SplayTreeSet<TZDateTime>();

    int totalMs = 0;
    for (var session in sessions) {
      totalMs += session.millisecondsDuration;
      allDateTimes.add(dateTimeToDayAccuracy(session.startDateTime));

      if (session.endDateTime != null) {
        allDateTimes.add(dateTimeToDayAccuracy(session.endDateTime!));
      }
    }

    _cachedTotalDuration = Duration(milliseconds: totalMs);

    // If the date range is null, restrict the range to the earliest
    // and latest sessions.
    var range =
        dateRange ??
        DateRange(
          period: DateRange_Period.custom,
          startTimestamp: Int64(sessions.first.startTimestamp),
          endTimestamp: Int64(
            sessions.last.endTimestamp ??
                TimeManager.get.now().millisecondsSinceEpoch,
          ),
        );

    _cachedDurationPerDay = averageDuration(
      totalDuration.inMilliseconds,
      range.days,
    );
    _cachedDurationPerWeek = averageDuration(
      totalDuration.inMilliseconds,
      range.weeks,
    );
    _cachedDurationPerMonth = averageDuration(
      totalDuration.inMilliseconds,
      range.months,
    );

    // Iterate all days, keeping track of the longest streak.
    int currentStreak = 1;
    bool didResetStreak = false;
    _cachedLongestStreak = currentStreak;

    var dateTimeList = List.from(allDateTimes);
    dateTimeList.sort((lhs, rhs) => rhs.compareTo(lhs));
    var last = dateTimeList.first;
    var now = TimeManager.get.now();
    _cachedCurrentStreak = _cachedLongestStreak =
        isSameDate(now, last) ||
            isSameDate(now.subtract(Duration(days: 1)), last)
        ? 1
        : 0;
    var hasCurrentStreak = _cachedCurrentStreak == 1;

    for (int i = 1; i < dateTimeList.length; i++) {
      var current = _adjustDateTimeForDst(dateTimeList[i]);
      var lastsYesterday = _adjustDateTimeForDst(
        TimeManager.get.dateTime(
          last.millisecondsSinceEpoch - Duration.millisecondsPerDay,
        ),
      );

      if (isSameYear(current, lastsYesterday) &&
          isSameMonth(current, lastsYesterday) &&
          current.day == lastsYesterday.day) {
        if (!didResetStreak && hasCurrentStreak) {
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

  /// A crude way handle daylight savings time. Since streaks don't care about
  /// actual time (just the date), we can safely round the day up if a DateTime's
  /// hour is not equal to 0. Note that there's no need to round the day down
  /// in the opposite DST case, since the date will already be correct.
  TZDateTime _adjustDateTimeForDst(TZDateTime dateTime) {
    if (dateTime.hour == 23) {
      return TimeManager.get.dateTimeFromValues(
        dateTime.year,
        dateTime.month,
        dateTime.day + 1,
      );
    }
    return dateTime;
  }

  double getAverageSessions(num divisor) {
    if (divisor <= 0) {
      return 0;
    }

    return numberOfSessions / divisor;
  }

  @override
  String toString() {
    return "{activity=${value.name}; duration=$totalDuration; numberOfSessions=$numberOfSessions}";
  }
}

/// A class that stores summarized data for multiple [Activity] objects,
/// including summary data across all of its activities.
class SummarizedActivityList {
  final List<SummarizedActivity> activities;
  final DateRange? dateRange;
  final Clock clock;

  Tuple<Activity, Session>? _cachedLongestSession;
  Tuple<Activity, int>? _cachedMostFrequentActivity;

  List<SummarizedActivity>? _cachedActivitiesSortedByDuration;
  List<SummarizedActivity>? _cachedActivitiesSortedByNumberOfSessions;

  int? _cachedNumberOfSessions;
  int? _cachedTotalDuration;
  Duration? _cachedDurationPerDay;
  Duration? _cachedDurationPerWeek;
  Duration? _cachedDurationPerMonth;

  SummarizedActivityList(
    this.activities,
    this.dateRange, {
    this.clock = const Clock(),
  });

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

  Duration get averageDurationOverall =>
      averageDuration(totalDuration, numberOfSessions);

  int get numberOfSessions {
    if (_cachedNumberOfSessions == null) {
      _calculate();
    }
    return _cachedNumberOfSessions!;
  }

  int get totalDuration {
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

  AverageDurations get averageDurations {
    return AverageDurations(
      overall: averageDurationOverall,
      perDay: averageDurationPerDay,
      perWeek: averageDurationPerWeek,
      perMonth: averageDurationPerMonth,
    );
  }

  /// Returns a copy of `activities`, sorted descending by total duration.
  List<SummarizedActivity>? get activitiesSortedByDuration {
    if (_cachedActivitiesSortedByDuration == null) {
      List<SummarizedActivity> copy = List.of(activities);
      copy.sort((a, b) => b.totalDuration.compareTo(a.totalDuration));
      _cachedActivitiesSortedByDuration = copy;
    }
    return _cachedActivitiesSortedByDuration;
  }

  /// Returns a copy of `activities`, sorted descending by number of sessions.
  List<SummarizedActivity>? get activitiesSortedByNumberOfSessions {
    if (_cachedActivitiesSortedByNumberOfSessions == null) {
      List<SummarizedActivity> copy = List.of(activities);
      copy.sort((a, b) => b.numberOfSessions.compareTo(a.numberOfSessions));
      _cachedActivitiesSortedByNumberOfSessions = copy;
    }
    return _cachedActivitiesSortedByNumberOfSessions;
  }

  void _calculate() {
    _cachedTotalDuration = 0;
    _cachedNumberOfSessions = 0;

    Session? earliestSession;
    Session? latestSession;

    for (var activity in activities) {
      if (_cachedMostFrequentActivity == null ||
          activity.sessions.length > _cachedMostFrequentActivity!.second) {
        _cachedMostFrequentActivity = Tuple(
          activity.value,
          activity.sessions.length,
        );
      }

      for (var session in activity.sessions) {
        _cachedNumberOfSessions = _cachedNumberOfSessions! + 1;

        if (earliestSession == null ||
            earliestSession.startTimestamp > session.startTimestamp) {
          earliestSession = session;
        }

        if (latestSession == null ||
            latestSession.startTimestamp < session.startTimestamp) {
          latestSession = session;
        }

        if (_cachedLongestSession == null ||
            session > _cachedLongestSession!.second) {
          _cachedLongestSession = Tuple(activity.value, session);
        }
      }

      _cachedTotalDuration =
          _cachedTotalDuration! + activity.totalDuration.inMilliseconds;
    }

    // If the date range is null, restrict the range to the earliest
    // and latest sessions.
    var now = TimeManager.get.currentTimestamp;
    var range =
        dateRange ??
        DateRange(
          period: DateRange_Period.custom,
          startTimestamp: Int64(earliestSession?.startTimestamp ?? now),
          endTimestamp: Int64(latestSession?.endTimestamp ?? now),
        );

    _cachedDurationPerDay = averageDuration(totalDuration, range.days);
    _cachedDurationPerWeek = averageDuration(totalDuration, range.weeks);
    _cachedDurationPerMonth = averageDuration(totalDuration, range.months);
  }
}
