import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/time.dart';

import '../test_utils.dart';

void main() {
  Session buildSession(
    String activityId,
    DateTime start,
    DateTime? end, {
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
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        )),
        sessions: [],
      );

      expect(activity.totalDuration, equals(const Duration()));
      expect(activity.averageDurationOverall, equals(const Duration()));
      expect(activity.averageDurationPerDay, equals(const Duration()));
      expect(activity.averageDurationPerWeek, equals(const Duration()));
      expect(activity.averageDurationPerMonth, equals(const Duration()));
      expect(activity.longestStreak, equals(0));
      expect(activity.sessionsPerDay, equals(0));
      expect(activity.sessionsPerWeek, equals(0));
      expect(activity.sessionsPerMonth, equals(0));
    });

    test("Null sessions", () {
      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        )),
      );

      expect(activity.totalDuration, equals(const Duration()));
      expect(activity.averageDurationOverall, equals(const Duration()));
      expect(activity.averageDurationPerDay, equals(const Duration()));
      expect(activity.averageDurationPerWeek, equals(const Duration()));
      expect(activity.averageDurationPerMonth, equals(const Duration()));
      expect(activity.longestStreak, equals(0));
      expect(activity.sessionsPerDay, equals(0));
      expect(activity.sessionsPerWeek, equals(0));
      expect(activity.sessionsPerMonth, equals(0));
    });

    test("Normal use case", () {
      List<Session> sessions = [
        buildSession(
          "",
          DateTime(2020, 5, 5, 13),
          DateTime(2020, 5, 5, 20),
        ), // 7 hours
        buildSession(
          "",
          DateTime(2020, 5, 6, 13),
          DateTime(2020, 5, 6, 18),
        ), // 5 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime.fromMillisecondsSinceEpoch(0),
          endDate: DateTime.fromMillisecondsSinceEpoch(
            Duration.millisecondsPerDay * 5,
          ),
        )),
        sessions: sessions,
      );

      expect(activity.totalDuration, equals(const Duration(hours: 12)));
      expect(activity.averageDurationOverall, equals(const Duration(hours: 6)));
      expect(activity.averageDurationPerDay.inMilliseconds, equals(8640000));
      expect(activity.averageDurationPerWeek.inMilliseconds, equals(60480000));
      expect(
          activity.averageDurationPerMonth.inMilliseconds, equals(259200000));
      expect(activity.longestStreak, equals(2));
      expect(activity.sessionsPerDay, equals(2 / 5));
      expect(activity.sessionsPerWeek, equals(2.8));
      expect(activity.sessionsPerMonth, equals(12));
    });

    test("All time averages", () {
      List<Session> sessions = [
        buildSession(
          "",
          DateTime.fromMillisecondsSinceEpoch(35000),
          DateTime.fromMillisecondsSinceEpoch(40000),
        ),
        buildSession(
          "",
          DateTime.fromMillisecondsSinceEpoch(5000),
          DateTime.fromMillisecondsSinceEpoch(10000),
        ),
        buildSession(
          "",
          DateTime.fromMillisecondsSinceEpoch(15000),
          DateTime.fromMillisecondsSinceEpoch(20000),
        ),
        buildSession(
          "",
          DateTime.fromMillisecondsSinceEpoch(45000),
          DateTime.fromMillisecondsSinceEpoch(50000),
        ),
        buildSession(
          "",
          DateTime.fromMillisecondsSinceEpoch(25000),
          DateTime.fromMillisecondsSinceEpoch(30000),
        ),
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        displayDateRange: null,
        sessions: sessions,
      );

      expect(activity.sessionsPerDay, equals(9600));
      expect(activity.sessionsPerWeek, equals(67200));
      expect(activity.sessionsPerMonth, equals(288000));
    });
  });

  group("Boundary sessions are calculated correctly", () {
    List<Session> sessions = [
      buildSession(
        "",
        DateTime(2019, 3, 15, 3),
        DateTime(2019, 3, 15, 10),
      ), // 7 hours
      buildSession(
        "",
        DateTime(2018, 11, 24, 7),
        DateTime(2018, 11, 24, 12),
      ), // 5 hours
      buildSession(
        "",
        DateTime(2019, 1, 10, 15),
        DateTime(2019, 1, 10, 21),
      ), // 6 hours
      buildSession(
        "",
        DateTime(2019, 10, 10, 1),
        DateTime(2019, 10, 10, 20),
      ), // 19 hours
    ];

    SummarizedActivity activity = SummarizedActivity(
      value: ActivityBuilder("").build,
      displayDateRange: stubDateRange(DateRange(
        startDate: DateTime(2018, 11, 15, 7),
        endDate: DateTime(2019, 10, 25, 20),
      )),
      sessions: sessions,
    );

    test("Max", () {
      expect(activity.longestSession!.millisecondsDuration,
          sessions[3].millisecondsDuration);
    });

    test("Min", () {
      expect(activity.shortestSession!.millisecondsDuration,
          sessions[1].millisecondsDuration);
    });
  });

  group("Longest streak is calculated correctly", () {
    test("Longest and current streak", () {
      Activity activity = ActivityBuilder("Activity").build;
      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime(2018, 1, 5, 12),
          endDate: DateTime(2018, 1, 25, 21),
        )),
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
      expect(summarizedActivity.currentStreak, equals(1));
    });

    test("Longest single session streak across months", () {
      Activity activity = ActivityBuilder("Activity").build;

      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime(2018, 1, 1),
          endDate: DateTime(2023, 1, 1),
        )),
        sessions: [
          buildSession(
            activity.id,
            DateTime(2019, 11, 30, 22),
            DateTime(2019, 12, 1, 3),
          ),
        ],
      );

      expect(summarizedActivity.longestStreak, equals(2));
    });

    test("Longest streak single session across years", () {
      Activity activity = ActivityBuilder("Activity").build;

      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime(2018, 1, 1),
          endDate: DateTime(2023, 1, 1),
        )),
        sessions: [
          buildSession(
            activity.id,
            DateTime(2019, 12, 31, 22),
            DateTime(2020, 1, 1, 3),
          ),
        ],
      );

      expect(summarizedActivity.longestStreak, equals(2));
    });

    test("Longest streak across years", () {
      Activity activity = ActivityBuilder("Activity").build;

      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime(2018, 1, 1),
          endDate: DateTime(2023, 1, 1),
        )),
        sessions: [
          buildSession(
            activity.id,
            DateTime(2019, 12, 31, 22),
            DateTime(2019, 12, 31, 23),
          ),
          buildSession(
            activity.id,
            DateTime(2020, 1, 1, 15),
            DateTime(2020, 1, 1, 18),
          ),
        ],
      );

      expect(summarizedActivity.longestStreak, equals(2));
    });

    test("Current streak", () {
      var now = DateTime.now();

      Activity activity = ActivityBuilder("Activity").build;

      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime(2018, 1, 1),
          endDate: DateTime(2023, 1, 1),
        )),
        sessions: [
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay * 8),
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay * 8),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay * 5),
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay * 5),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay * 3),
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay * 3),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay * 2),
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay * 2),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay),
            DateTime.fromMillisecondsSinceEpoch(
                now.millisecondsSinceEpoch - Duration.millisecondsPerDay),
          ),
        ],
      );

      expect(summarizedActivity.longestStreak, equals(3));
    });
  });

  group("Date range pinning", () {
    test("Infinite date range is pinned to earliest/latest sessions", () {
      List<Session> sessions = [
        buildSession(
          "",
          DateTime(2019, 3, 15, 3),
          DateTime(2019, 3, 15, 10),
        ), // 7 hours
        buildSession(
          "",
          DateTime(2018, 11, 24, 7),
          DateTime(2018, 11, 24, 12),
        ), // 5 hours
        buildSession(
          "",
          DateTime(2019, 1, 10, 15),
          DateTime(2019, 1, 10, 21),
        ), // 6 hours
        buildSession(
          "",
          DateTime(2019, 10, 10, 1),
          DateTime(2019, 10, 10, 20),
        ), // 19 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        displayDateRange: null,
        sessions: sessions,
      );

      // Average is only over 12 months.
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(12468019));
    });
  });

  group("Summarized activity list", () {
    test("Longest and most frequent session returns correct result", () async {
      Activity activity1 = ActivityBuilder("Activity1").build;
      Activity activity2 = ActivityBuilder("Activity2").build;
      Activity activity3 = ActivityBuilder("Activity3").build;

      SummarizedActivity summarizedActivity1 = SummarizedActivity(
        value: activity1,
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime(2018, 1, 10, 5),
          endDate: DateTime(2018, 1, 20, 10),
        )),
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
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime(2018, 1, 5, 12),
          endDate: DateTime(2018, 1, 25, 21),
        )),
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
        displayDateRange: stubDateRange(DateRange(
          startDate: DateTime(2018, 1, 20, 1),
          endDate: DateTime(2018, 1, 29, 7),
        )),
        sessions: [longestSession],
      );

      SummarizedActivityList result = SummarizedActivityList([
        summarizedActivity1,
        summarizedActivity2,
        summarizedActivity3,
      ]);

      expect(result.activities, isNotNull);
      expect(result.activities.length, equals(3));

      expect(result.mostFrequentActivity!.first, equals(activity2));
      expect(result.mostFrequentActivity!.second, equals(3));

      expect(result.longestSession!.first, equals(activity3));
      expect(result.longestSession!.second.millisecondsDuration,
          equals(longestSession.millisecondsDuration));
      expect(result.totalDuration, const Duration(hours: 18).inMilliseconds);
    });
  });

  group("In-progress sessions", () {
    test("Single in-progress session", () {
      Clock clock = Clock.fixed(DateTime(2019, 11, 1));

      List<Session> sessions = [
        buildSession(
          "",
          DateTime(2019, 3, 15, 3),
          DateTime(2019, 3, 15, 10),
        ), // 7 hours
        buildSession(
          "",
          DateTime(2018, 11, 24, 7),
          DateTime(2018, 11, 24, 12),
        ), // 5 hours
        buildSession(
          "",
          DateTime(2019, 10, 31, 23),
          null,
          clock: clock,
        ), // 1 hours
        buildSession(
          "",
          DateTime(2019, 10, 10, 1),
          DateTime(2019, 10, 10, 20),
        ), // 19 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        displayDateRange: null,
        sessions: sessions,
        clock: clock,
      );

      // Average is over 13 months.
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(10115122));
    });

    test("Multiple in-progress session", () {
      Clock clock = Clock.fixed(DateTime(2019, 11, 1));

      List<Session> sessions = [
        buildSession(
          "",
          DateTime(2019, 3, 15, 3),
          DateTime(2019, 3, 15, 10),
        ), // 7 hours
        buildSession(
          "",
          DateTime(2018, 11, 24, 7),
          DateTime(2018, 11, 24, 12),
        ), // 5 hours
        buildSession(
          "",
          DateTime(2019, 10, 31, 23),
          null,
          clock: clock,
        ), // 1 hour
        buildSession(
          "",
          DateTime(2019, 10, 10, 1),
          DateTime(2019, 10, 10, 20),
        ), // 19 hours
        buildSession(
          "",
          DateTime(2019, 10, 31, 22),
          null,
          clock: clock,
        ), // 2 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        displayDateRange: null,
        sessions: sessions,
        clock: clock,
      );

      // Average is over 13 months.
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(10747317));
    });
  });
}
