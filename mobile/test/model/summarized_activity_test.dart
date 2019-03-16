import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';

void main() {
  Session buildSession(String activityId, DateTime start, DateTime end) {
    return (SessionBuilder(activityId)
        ..startTimestamp = start.millisecondsSinceEpoch
        ..endTimestamp = end.millisecondsSinceEpoch)
        .build;
  }

  group("Averages are calculated correctly", () {
    test("Empty sessions", () {
      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        sessions: [],
      );

      expect(activity.totalDuration, equals(Duration()));
      expect(activity.averageDurationOverall, equals(Duration()));
      expect(activity.averageDurationPerDay, equals(Duration()));
      expect(activity.averageDurationPerWeek, equals(Duration()));
      expect(activity.averageDurationPerMonth, equals(Duration()));
    });

    test("Null sessions", () {
      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        sessions: null,
      );

      expect(activity.totalDuration, equals(Duration()));
      expect(activity.averageDurationOverall, equals(Duration()));
      expect(activity.averageDurationPerDay, equals(Duration()));
      expect(activity.averageDurationPerWeek, equals(Duration()));
      expect(activity.averageDurationPerMonth, equals(Duration()));
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
        sessions: sessions,
      );

      expect(activity.totalDuration, equals(Duration(hours: 12)));
      expect(activity.averageDurationOverall, equals(Duration(hours: 6)));
      expect(activity.averageDurationPerDay.inMilliseconds, equals(4320000));
      expect(activity.averageDurationPerWeek, equals(Duration(hours: 6)));
      expect(activity.averageDurationPerMonth, equals(Duration(hours: 12)));
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
      ]; // 5 months, 17 weeks, 112 days

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        sessions: sessions,
      );

      expect(activity.totalDuration, equals(Duration(hours: 18)));
      expect(activity.averageDurationOverall, equals(Duration(hours: 6)));
      expect(activity.averageDurationPerDay.inMilliseconds, equals(578571));
      expect(activity.averageDurationPerWeek.inMilliseconds, equals(3811765));
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(12960000));
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
      ]; // 5 months, 17 weeks, 112 days

      SummarizedActivity activity = SummarizedActivity(
        value: ActivityBuilder("").build,
        sessions: sessions,
      );

      expect(activity.totalDuration, equals(Duration(hours: 18)));
      expect(activity.averageDurationOverall, equals(Duration(hours: 6)));
      expect(activity.averageDurationPerDay.inMilliseconds, equals(578571));
      expect(activity.averageDurationPerWeek.inMilliseconds, equals(3811765));
      expect(activity.averageDurationPerMonth.inMilliseconds, equals(12960000));
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
      ), // 20 hours
    ];

    SummarizedActivity activity = SummarizedActivity(
      value: ActivityBuilder("").build,
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

  group("Summarized activity list", () {
    test("Longest and most frequent session returns correct result", () async {
      Activity activity1 = ActivityBuilder("Activity1").build;
      Activity activity2 = ActivityBuilder("Activity2").build;
      Activity activity3 = ActivityBuilder("Activity3").build;

      SummarizedActivity summarizedActivity1 = SummarizedActivity(
        value: activity1,
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
}