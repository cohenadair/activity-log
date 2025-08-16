import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';

import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  Session buildSession(String activityId, DateTime start, DateTime? end) {
    SessionBuilder builder = SessionBuilder(activityId)
      ..startTimestamp = start.millisecondsSinceEpoch;

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
          startTimestamp: Int64(TimeManager.get.currentTimestamp),
          endTimestamp: Int64(TimeManager.get.currentTimestamp),
        ),
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
        dateRange: DateRange(
          startTimestamp: Int64(TimeManager.get.currentTimestamp),
          endTimestamp: Int64(TimeManager.get.currentTimestamp),
        ),
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
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get.dateTime(0).millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTime(Duration.millisecondsPerDay * 5)
                .millisecondsSinceEpoch,
          ),
        ),
        sessions: sessions,
      );

      expect(activity.totalDuration, equals(const Duration(hours: 12)));
      expect(activity.averageDurationOverall, equals(const Duration(hours: 6)));
      expect(activity.averageDurationPerDay.inMilliseconds, equals(8640000));
      expect(activity.averageDurationPerWeek.inMilliseconds, equals(60480000));
      expect(
        activity.averageDurationPerMonth.inMilliseconds,
        equals(259200000),
      );
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
        dateRange: null,
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

    SummarizedActivity activity() => SummarizedActivity(
      value: ActivityBuilder("").build,
      dateRange: DateRange(
        startTimestamp: Int64(
          TimeManager.get
              .dateTimeFromValues(2018, 11, 15, 7)
              .millisecondsSinceEpoch,
        ),
        endTimestamp: Int64(
          TimeManager.get
              .dateTimeFromValues(2019, 10, 25, 20)
              .millisecondsSinceEpoch,
        ),
      ),
      sessions: sessions,
    );

    test("Max", () {
      expect(
        activity().longestSession!.millisecondsDuration,
        sessions[3].millisecondsDuration,
      );
    });

    test("Min", () {
      expect(
        activity().shortestSession!.millisecondsDuration,
        sessions[1].millisecondsDuration,
      );
    });
  });

  group("Streak is calculated correctly", () {
    test("Longest and current streak", () {
      Activity activity = ActivityBuilder("Activity").build;
      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 5, 12)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2019, 1, 25, 21)
                .millisecondsSinceEpoch,
          ),
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
      expect(summarizedActivity.currentStreak, equals(0));
    });

    test("Longest single session streak across months", () {
      Activity activity = ActivityBuilder("Activity").build;

      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 1)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2019, 1, 1)
                .millisecondsSinceEpoch,
          ),
        ),
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
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 1)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2023, 1, 1)
                .millisecondsSinceEpoch,
          ),
        ),
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
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 1)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2023, 1, 1)
                .millisecondsSinceEpoch,
          ),
        ),
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

    test("User has current streak", () {
      managers.lib.stubCurrentTime(DateTime(2023, 1, 1));

      Activity activity = ActivityBuilder("Activity").build;

      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 1)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2023, 1, 1)
                .millisecondsSinceEpoch,
          ),
        ),
        sessions: [
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 8,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 8,
            ),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 5,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 5,
            ),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 3,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 3,
            ),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 2,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 2,
            ),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay,
            ),
          ),
        ],
      );

      expect(summarizedActivity.currentStreak, equals(3));
    });

    test("User does not have a current streak", () {
      managers.lib.stubCurrentTime(DateTime(2023, 1, 1));

      Activity activity = ActivityBuilder("Activity").build;

      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 1)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2023, 1, 1)
                .millisecondsSinceEpoch,
          ),
        ),
        sessions: [
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 3,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 3,
            ),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 2,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 2,
            ),
          ),
        ],
      );

      expect(summarizedActivity.currentStreak, equals(0));
    });

    test("Current streak with a daylight savings behind change", () {
      // DST happened on Mar. 11, 2023.
      managers.lib.stubCurrentTime(DateTime(2023, 3, 14));

      Activity activity = ActivityBuilder("Activity").build;

      SummarizedActivity summarizedActivity = SummarizedActivity(
        value: activity,
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 1)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(TimeManager.get.currentTimestamp),
        ),
        sessions: [
          // DST causes day rounding to of this to be a day early.
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 4,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 4,
            ),
          ),
          // DST causes day rounding to of this to be a day early.
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 3,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 3,
            ),
          ),
          // DST causes day rounding to of this to be a day early.
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 2,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay * 2,
            ),
          ),
          // Note that due to the rounding (note above), there is actually
          // a day gap in the resulting "allDateTimes" list in
          // SummarizedActivity.
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch -
                  Duration.millisecondsPerDay,
            ),
          ),
          buildSession(
            activity.id,
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              managers.timeManager.now().millisecondsSinceEpoch,
            ),
          ),
        ],
      );

      expect(summarizedActivity.currentStreak, equals(2));
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
        dateRange: null,
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
        dateRange: DateRange(
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 10, 5)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2023, 1, 20, 10)
                .millisecondsSinceEpoch,
          ),
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
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 5, 12)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2023, 1, 25, 21)
                .millisecondsSinceEpoch,
          ),
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
          startTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2018, 1, 20, 1)
                .millisecondsSinceEpoch,
          ),
          endTimestamp: Int64(
            TimeManager.get
                .dateTimeFromValues(2023, 1, 29, 7)
                .millisecondsSinceEpoch,
          ),
        ),
        sessions: [longestSession],
      );

      SummarizedActivityList result = SummarizedActivityList([
        summarizedActivity1,
        summarizedActivity2,
        summarizedActivity3,
      ], null);

      expect(result.activities, isNotNull);
      expect(result.activities.length, equals(3));

      expect(result.mostFrequentActivity!.first, equals(activity2));
      expect(result.mostFrequentActivity!.second, equals(3));

      expect(result.longestSession!.first, equals(activity3));
      expect(
        result.longestSession!.second.millisecondsDuration,
        equals(longestSession.millisecondsDuration),
      );
      expect(result.totalDuration, const Duration(hours: 18).inMilliseconds);

      var averageDurations = result.averageDurations;
      expect(averageDurations.overall, const Duration(milliseconds: 10800000));
      expect(averageDurations.perDay, const Duration(milliseconds: 4380845));
      expect(averageDurations.perWeek, const Duration(milliseconds: 30665915));
      expect(
        averageDurations.perMonth,
        const Duration(milliseconds: 131425352),
      );
    });
  });

  group("In-progress sessions", () {
    test("Single in-progress session", () {
      managers.lib.stubCurrentTime(DateTime(2019, 11, 1));

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
        buildSession("", DateTime(2019, 10, 31, 23), null), // 1 hour
        buildSession(
          "",
          DateTime(2019, 10, 10, 1),
          DateTime(2019, 10, 10, 20),
        ), // 19 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: null,
        sessions: sessions,
      );

      // Average is over 13 months.
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(10115122));
    });

    test("Multiple in-progress session", () {
      managers.lib.stubCurrentTime(DateTime(2019, 11, 1));

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
        buildSession("", DateTime(2019, 10, 31, 23), null), // 1 hour
        buildSession(
          "",
          DateTime(2019, 10, 10, 1),
          DateTime(2019, 10, 10, 20),
        ), // 19 hours
        buildSession("", DateTime(2019, 10, 31, 22), null), // 2 hours
      ];

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        dateRange: null,
        sessions: sessions,
      );

      // Average is over 13 months.
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(10747317));
    });
  });
}
