import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/time.dart';

void main() {
  Session buildSession(String activityId, DateTime start, DateTime end, {
    Clock clock = const Clock(),
  }) {
    SessionBuilder builder = SessionBuilder(activityId)
      ..startTimestamp = start.millisecondsSinceEpoch
      ..clock = clock;

    if (end != null) {
      builder.endTimestamp = end.millisecondsSinceEpoch;
    }

    return builder.build;
  }

  group("Averages are calculated correctly", () {
    test("Empty sessions", () {
      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: DateRange(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
        sessions: [],
      );

      expect(activity.totalDuration, equals(Duration()));
      expect(activity.averageDurationOverall, equals(Duration()));
      expect(activity.averageDurationPerDay, equals(Duration()));
      expect(activity.averageDurationPerWeek, equals(Duration()));
      expect(activity.averageDurationPerMonth, equals(Duration()));
      expect(activity.longestStreak, equals(0));
    });

    test("Null sessions", () {
      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: DateRange(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
        sessions: null,
      );

      expect(activity.totalDuration, equals(Duration()));
      expect(activity.averageDurationOverall, equals(Duration()));
      expect(activity.averageDurationPerDay, equals(Duration()));
      expect(activity.averageDurationPerWeek, equals(Duration()));
      expect(activity.averageDurationPerMonth, equals(Duration()));
      expect(activity.longestStreak, equals(0));
    });

    test("Same month", () {
      List<Session> sessions = [
        buildSession("",
          DateTime(2018, 12, 15, 3),
          DateTime(2018, 12, 15, 10),
        ), // 7 hours
        buildSession("",
          DateTime(2018, 12, 24, 7),
          DateTime(2018, 12, 24, 12),
        ), // 5 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: DateRange(
          // 1 month, 3 weeks, 16 days
          startDate: DateTime(2018, 12, 12, 3),
          endDate: DateTime(2018, 12, 27, 12),
        ),
        sessions: sessions,
      );

      expect(activity.totalDuration, equals(Duration(hours: 12)));
      expect(activity.averageDurationOverall, equals(Duration(hours: 6)));
      expect(activity.averageDurationPerDay.inMilliseconds, equals(2700000));
      expect(activity.averageDurationPerWeek, equals(Duration(hours: 4)));
      expect(activity.averageDurationPerMonth, equals(Duration(hours: 12)));
      expect(activity.longestStreak, equals(1));
    });

    test("Span multiple months in the same year", () {
      List<Session> sessions = [
        buildSession("",
          DateTime(2019, 5, 15, 3),
          DateTime(2019, 5, 15, 10),
        ), // 7 hours
        buildSession("",
          DateTime(2019, 1, 24, 7),
          DateTime(2019, 1, 24, 12),
        ), // 5 hours
        buildSession("",
          DateTime(2019, 3, 10, 15),
          DateTime(2019, 3, 10, 21),
        ), // 6 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: DateRange(
          // 5 months, 18 weeks, 119 days
          startDate: DateTime(2019, 1, 20, 7),
          endDate: DateTime(2019, 5, 18, 10),
        ),
        sessions: sessions,
      );

      expect(activity.totalDuration, equals(Duration(hours: 18)));
      expect(activity.averageDurationOverall, equals(Duration(hours: 6)));
      expect(activity.averageDurationPerDay.inMilliseconds, equals(544538));
      expect(activity.averageDurationPerWeek.inMilliseconds, equals(3600000));
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(12960000));
      expect(activity.longestStreak, equals(1));
    });

    test("Span multiple months in different years", () {
      List<Session> sessions = [
        buildSession("",
          DateTime(2019, 3, 15, 3),
          DateTime(2019, 3, 15, 10),
        ), // 7 hours
        buildSession("",
          DateTime(2018, 11, 24, 7),
          DateTime(2018, 11, 24, 12),
        ), // 5 hours
        buildSession("",
          DateTime(2019, 1, 10, 15),
          DateTime(2019, 1, 10, 21),
        ), // 6 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: DateRange(
          // 5 months, 18 weeks, 119 days
          startDate: DateTime(2018, 11, 20, 7),
          endDate: DateTime(2019, 3, 18, 10),
        ),
        sessions: sessions,
      );

      expect(activity.totalDuration, equals(Duration(hours: 18)));
      expect(activity.averageDurationOverall, equals(Duration(hours: 6)));
      expect(activity.averageDurationPerDay.inMilliseconds, equals(544538));
      expect(activity.averageDurationPerWeek.inMilliseconds, equals(3600000));
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(12960000));
      expect(activity.longestStreak, equals(1));
    });
  });

  group("Boundary sessions are calculated correctly", () {
    List<Session> sessions = [
      buildSession("",
        DateTime(2019, 3, 15, 3),
        DateTime(2019, 3, 15, 10),
      ), // 7 hours
      buildSession("",
        DateTime(2018, 11, 24, 7),
        DateTime(2018, 11, 24, 12),
      ), // 5 hours
      buildSession("",
        DateTime(2019, 1, 10, 15),
        DateTime(2019, 1, 10, 21),
      ), // 6 hours
      buildSession("",
        DateTime(2019, 10, 10, 1),
        DateTime(2019, 10, 10, 20),
      ), // 19 hours
    ];

    SummarizedActivity activity = SummarizedActivity(
      value: ActivityBuilder("").build,
      dateRange: DateRange(
        startDate: DateTime(2018, 11, 15, 7),
        endDate: DateTime(2019, 10, 25, 20),
      ),
      sessions: sessions,
    );

    test("Max", () {
      expect(activity.longestSession.millisecondsDuration,
          sessions[3].millisecondsDuration);
    });

    test("Min", () {
      expect(activity.shortestSession.millisecondsDuration,
          sessions[1].millisecondsDuration);
    });
  });

  group("Longest streak is calculated correctly", () {
    test("Longest streak", () {
      Activity activity = ActivityBuilder("Activity").build;
      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        dateRange: DateRange(
          startDate: DateTime(2018, 1, 5, 12),
          endDate: DateTime(2018, 1, 25, 21),
        ),
        sessions: [
          buildSession(
            activity.id,
            DateTime(2018, 1, 8, 12),
            DateTime(2018, 1, 8, 15),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 1, 9, 12),
            DateTime(2018, 1, 9, 15),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 1, 10, 12),
            DateTime(2018, 1, 10, 15),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 1, 11, 7),
            DateTime(2018, 1, 11, 10),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 1, 12, 7),
            DateTime(2018, 1, 12, 10),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 1, 20, 20),
            DateTime(2018, 1, 20, 21),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 3, 10, 20),
            DateTime(2018, 3, 10, 21),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 3, 10, 15),
            DateTime(2018, 3, 10, 18),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 3, 10, 4),
            DateTime(2018, 3, 10, 5),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 3, 11, 20),
            DateTime(2018, 3, 11, 21),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 3, 12, 20),
            DateTime(2018, 3, 12, 21),
          ),
          buildSession(
            activity.id,
            DateTime(2018, 3, 13, 20),
            DateTime(2018, 3, 13, 21),
          ),
        ],
      );

      expect(summarizedActivity.longestStreak, equals(5));
    });
  });

  group("Date range pinning", () {
    test("Infinte date range is pinned to earliest/latest sessions", () {
      List<Session> sessions = [
        buildSession("",
          DateTime(2019, 3, 15, 3),
          DateTime(2019, 3, 15, 10),
        ), // 7 hours
        buildSession("",
          DateTime(2018, 11, 24, 7),
          DateTime(2018, 11, 24, 12),
        ), // 5 hours
        buildSession("",
          DateTime(2019, 1, 10, 15),
          DateTime(2019, 1, 10, 21),
        ), // 6 hours
        buildSession("",
          DateTime(2019, 10, 10, 1),
          DateTime(2019, 10, 10, 20),
        ), // 19 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: null,
        sessions: sessions,
      );

      // Average is only over 12 months.
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(11100000));
    });
  });

  group("Summarized activity list", () {
    test("Longest and most frequent session returns correct result", () async {
      Activity activity1 = ActivityBuilder("Activity1").build;
      Activity activity2 = ActivityBuilder("Activity2").build;
      Activity activity3 = ActivityBuilder("Activity3").build;

      SummarizedActivity summarizedActivity1 = SummarizedActivity(
        value: activity1,
        dateRange: DateRange(
          startDate: DateTime(2018, 1, 10, 5),
          endDate: DateTime(2018, 1, 20, 10),
        ),
        sessions: [
          buildSession(
            activity1.id,
            DateTime(2018, 1, 15, 5),
            DateTime(2018, 1, 15, 7),
          ),
          buildSession(
            activity1.id,
            DateTime(2018, 1, 15, 7),
            DateTime(2018, 1, 15, 10),
          ),
        ],
      );

      SummarizedActivity summarizedActivity2 = SummarizedActivity(
        value: activity2,
        dateRange: DateRange(
          startDate: DateTime(2018, 1, 5, 12),
          endDate: DateTime(2018, 1, 25, 21),
        ),
        sessions: [
          buildSession(
            activity2.id,
            DateTime(2018, 1, 10, 12),
            DateTime(2018, 1, 10, 15),
          ),
          buildSession(
            activity2.id,
            DateTime(2018, 1, 15, 7),
            DateTime(2018, 1, 15, 10),
          ),
          buildSession(
            activity2.id,
            DateTime(2018, 1, 20, 20),
            DateTime(2018, 1, 20, 21),
          ),
        ],
      );

      Session longestSession = buildSession(
        activity3.id,
        DateTime(2018, 1, 25, 1),
        DateTime(2018, 1, 25, 7),
      );

      SummarizedActivity summarizedActivity3 = SummarizedActivity(
        value: activity3,
        dateRange: DateRange(
          startDate: DateTime(2018, 1, 20, 1),
          endDate: DateTime(2018, 1, 29, 7),
        ),
        sessions: [longestSession],
      );

      SummarizedActivityList result = SummarizedActivityList([
        summarizedActivity1,
        summarizedActivity2,
        summarizedActivity3,
      ]);

      expect(result.activities, isNotNull);
      expect(result.activities.length, equals(3));

      expect(result.mostFrequentActivity.first, equals(activity2));
      expect(result.mostFrequentActivity.second, equals(3));

      expect(result.longestSession.first, equals(activity3));
      expect(result.longestSession.second.millisecondsDuration,
          equals(longestSession.millisecondsDuration));
    });
  });

  group("In-progress sessions", () {
    test("Single in-progress session", () {
      Clock clock = Clock.fixed(DateTime(2019, 11, 1));

      List<Session> sessions = [
        buildSession("",
          DateTime(2019, 3, 15, 3),
          DateTime(2019, 3, 15, 10),
        ), // 7 hours
        buildSession("",
          DateTime(2018, 11, 24, 7),
          DateTime(2018, 11, 24, 12),
        ), // 5 hours
        buildSession("",
          DateTime(2019, 10, 31, 23),
          null,
          clock: clock,
        ), // 1 hours
        buildSession("",
          DateTime(2019, 10, 10, 1),
          DateTime(2019, 10, 10, 20),
        ), // 19 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: null,
        sessions: sessions,
        clock: clock,
      );

      // Average is over 13 months.
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(8861538));
    });

    test("Multiple in-progress session", () {
      Clock clock = Clock.fixed(DateTime(2019, 11, 1));

      List<Session> sessions = [
        buildSession("",
          DateTime(2019, 3, 15, 3),
          DateTime(2019, 3, 15, 10),
        ), // 7 hours
        buildSession("",
          DateTime(2018, 11, 24, 7),
          DateTime(2018, 11, 24, 12),
        ), // 5 hours
        buildSession("",
          DateTime(2019, 10, 31, 23),
          null,
          clock: clock,
        ), // 1 hour
        buildSession("",
          DateTime(2019, 10, 10, 1),
          DateTime(2019, 10, 10, 20),
        ), // 19 hours
        buildSession("",
          DateTime(2019, 10, 31, 22),
          null,
          clock: clock,
        ), // 2 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: null,
        sessions: sessions,
        clock: clock,
      );

      // Average is over 13 months.
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(9415385));
    });
  });
}