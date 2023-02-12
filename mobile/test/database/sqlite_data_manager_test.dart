import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/sqlite_data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../test_utils.dart';

void main() {
  late MockAppManager appManager;
  late MockDatabase database;
  late MockPreferencesManager preferencesManager;
  late SQLiteDataManager dataManager;

  setUp(() async {
    appManager = MockAppManager();

    var batch = MockBatch();
    when(batch.commit()).thenAnswer((_) => Future.value([]));

    database = MockDatabase();
    when(database.batch()).thenReturn(batch);

    dataManager = SQLiteDataManager();

    preferencesManager = MockPreferencesManager();
    when(appManager.preferencesManager).thenReturn(preferencesManager);
    when(preferencesManager.largestDurationUnit).thenReturn(DurationUnit.days);
    when(preferencesManager.homeDateRange)
        .thenReturn(DisplayDateRange.allDates);

    await dataManager.initialize(appManager, database);
  });

  stubActivities(List<Map<String, dynamic>> result) {
    when(database.rawQuery("SELECT * FROM activity"))
        .thenAnswer((_) async => result);
  }

  group("getSummarizedActivities", () {
    stubOverlappingSessions(String activityId, DateRange dateRange,
        List<Map<String, dynamic>> result) {
      when(database.rawQuery("""
          SELECT * FROM session
            WHERE activity_id = ?
            AND start_timestamp < ?
            AND (end_timestamp IS NULL OR end_timestamp > ?)
            AND is_banked = 0
            ORDER BY start_timestamp
          """, [activityId, dateRange.endMs, dateRange.startMs]))
          .thenAnswer((_) async => result);
    }

    Map<String, dynamic> buildSession(
        String activityId, DateTime start, DateTime end) {
      return (SessionBuilder(activityId)
            ..startTimestamp = start.millisecondsSinceEpoch
            ..endTimestamp = end.millisecondsSinceEpoch)
          .build
          .toMap();
    }

    assertSummarizedActivities({
      required DateTime startDate,
      required DateTime endDate,
      required List<DateRange> sessionRangeList,
      required int expectedLength,
      required Duration expectedDuration,
    }) async {
      DisplayDateRange dateRange = stubDateRange(DateRange(
        startDate: startDate,
        endDate: endDate,
      ));

      Activity activity = ActivityBuilder("").build;

      stubActivities([activity.toMap()]);
      stubOverlappingSessions(
          activity.id,
          dateRange.value,
          sessionRangeList.map((DateRange dateRange) {
            return buildSession(
              activity.id,
              dateRange.startDate,
              dateRange.endDate,
            );
          }).toList());

      var result = await dataManager.getSummarizedActivities(dateRange);

      expect(result.activities.length, equals(expectedLength));
      if (expectedLength > 0) {
        expect(result.activities[0].totalDuration, equals(expectedDuration));
      }
    }

    test("No activities", () async {
      stubActivities([]);
      DisplayDateRange dateRange = stubDateRange(DateRange(
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ));
      var result = await dataManager.getSummarizedActivities(dateRange);
      expect(result.activities, isEmpty);
      expect(result.longestSession, isNull);
      expect(result.mostFrequentActivity, isNull);
    });

    test("Activities provided as parameter", () async {
      DisplayDateRange dateRange = stubDateRange(DateRange(
        startDate: DateTime(2018, 1, 1),
        endDate: DateTime(2018, 2, 1),
      ));

      Activity activity = ActivityBuilder("").build;

      stubActivities([activity.toMap()]);
      stubOverlappingSessions(activity.id, dateRange.value, [
        buildSession(
          activity.id,
          DateTime(2018, 1, 15, 5),
          DateTime(2018, 1, 15, 7),
        ),
      ]);

      var result = await dataManager.getSummarizedActivities(dateRange, [
        activity,
      ]);

      expect(result.activities, isNotNull);
      expect(result.activities.length, equals(1));
      expect(result.activities[0].totalDuration, equals(Duration(hours: 2)));

      // Non-null input, 0 length.
      stubActivities([activity.toMap()]);
      result = await dataManager.getSummarizedActivities(dateRange, []);

      expect(result.activities, isNotNull);
      expect(result.activities.length, equals(1));
      expect(result.activities[0].totalDuration, equals(Duration(hours: 2)));
    });

    test("Session start outside range, session end inside range", () async {
      await assertSummarizedActivities(
        startDate: DateTime(2018, 1, 15, 4, 30),
        endDate: DateTime(2018, 1, 16, 4, 30),
        sessionRangeList: [
          DateRange(
            startDate: DateTime(2018, 1, 15, 2, 30),
            endDate: DateTime(2018, 1, 15, 7, 30),
          ),
        ],
        expectedLength: 1,
        expectedDuration: Duration(hours: 3),
      );
    });

    test("Session start inside range, session end outside range", () async {
      await assertSummarizedActivities(
        startDate: DateTime(2018, 1, 15, 4, 30),
        endDate: DateTime(2018, 1, 16, 4, 30),
        sessionRangeList: [
          DateRange(
            startDate: DateTime(2018, 1, 16, 2, 30),
            endDate: DateTime(2018, 1, 16, 7, 30),
          ),
        ],
        expectedLength: 1,
        expectedDuration: Duration(hours: 2),
      );
    });

    test("Session start outside range, session end outside range", () async {
      await assertSummarizedActivities(
        startDate: DateTime(2018, 1, 15, 4, 30),
        endDate: DateTime(2018, 1, 16, 4, 30),
        sessionRangeList: [
          DateRange(
            startDate: DateTime(2018, 1, 15, 2, 30),
            endDate: DateTime(2018, 1, 16, 7, 30),
          ),
        ],
        expectedLength: 1,
        expectedDuration: Duration(days: 1),
      );
    });

    test("Session start inside range, session end inside range", () async {
      await assertSummarizedActivities(
        startDate: DateTime(2018, 1, 15, 4, 30),
        endDate: DateTime(2018, 1, 16, 4, 30),
        sessionRangeList: [
          DateRange(
            startDate: DateTime(2018, 1, 15, 8, 30),
            endDate: DateTime(2018, 1, 15, 20, 30),
          ),
        ],
        expectedLength: 1,
        expectedDuration: Duration(hours: 12),
      );
    });

    test("Session start outside range, session end == range start", () async {
      await assertSummarizedActivities(
        startDate: DateTime(2018, 1, 15, 4, 30),
        endDate: DateTime(2018, 1, 16, 4, 30),
        sessionRangeList: [
          DateRange(
            startDate: DateTime(2018, 1, 14, 8, 30),
            endDate: DateTime(2018, 1, 15, 4, 30),
          ),
        ],
        expectedLength: 1,
        expectedDuration: Duration(),
      );
    });

    test("Session start == range end, session end outside range", () async {
      await assertSummarizedActivities(
        startDate: DateTime(2018, 1, 15, 4, 30),
        endDate: DateTime(2018, 1, 16, 4, 30),
        sessionRangeList: [
          DateRange(
            startDate: DateTime(2018, 1, 16, 4, 30),
            endDate: DateTime(2018, 1, 18, 4, 30),
          ),
        ],
        expectedLength: 1,
        expectedDuration: Duration(),
      );
    });

    test("Combination of all with multiple activities", () async {
      DisplayDateRange dateRange = stubDateRange(DateRange(
        startDate: DateTime(2018, 1, 1),
        endDate: DateTime(2018, 2, 1),
      ));

      List<Activity> activities = [
        ActivityBuilder("Activity 1").build,
        ActivityBuilder("Activity 3").build,
        ActivityBuilder("Activity 0").build,
        ActivityBuilder("Activity 2").build,
        ActivityBuilder("Activity 4").build,
      ];

      stubActivities(
          activities.map((Activity activity) => activity.toMap()).toList());

      stubOverlappingSessions(activities[0].id, dateRange.value, [
        buildSession(
          activities[0].id,
          DateTime(2017, 12, 31, 22),
          DateTime(2018, 1, 1, 4),
        ), // Expected 4 hours
        buildSession(
          activities[0].id,
          DateTime(2018, 1, 14, 12),
          DateTime(2018, 1, 14, 15),
        ), // Expected 3 hours
        buildSession(
          activities[0].id,
          DateTime(2018, 1, 31, 15),
          DateTime(2018, 2, 1, 15),
        ), // Expected 9 hours
      ]);

      stubOverlappingSessions(activities[1].id, dateRange.value, [
        buildSession(
          activities[1].id,
          DateTime(2018, 1, 9, 9),
          DateTime(2018, 1, 9, 17),
        ), // Expected 8 hours
      ]);

      stubOverlappingSessions(activities[2].id, dateRange.value, [
        buildSession(
          activities[2].id,
          DateTime(2018, 1, 1),
          DateTime(2018, 1, 1, 15),
        ), // Expected 15 hours
        buildSession(
          activities[2].id,
          DateTime(2018, 1, 20, 12),
          DateTime(2018, 1, 20, 24),
        ), // Expected 12 hours
        buildSession(
          activities[2].id,
          DateTime(2018, 1, 31, 15),
          DateTime(2018, 2, 1),
        ), // Expected 9 hours
      ]);

      stubOverlappingSessions(activities[3].id, dateRange.value, [
        buildSession(
          activities[3].id,
          DateTime(2018, 1, 1),
          DateTime(2018, 2, 1),
        ), // Expected 31 days
      ]);

      stubOverlappingSessions(activities[4].id, dateRange.value, []);

      var result = await dataManager.getSummarizedActivities(dateRange);

      expect(result.activities, isNotNull);
      expect(result.activities.length, equals(5));

      // Should be sorted alphabetically and have the correct duration.

      expect(result.activities[0].value.name, equals(activities[2].name));
      expect(result.activities[0].totalDuration, equals(Duration(hours: 36)));

      expect(result.activities[1].value.name, equals(activities[0].name));
      expect(result.activities[1].totalDuration, equals(Duration(hours: 16)));

      expect(result.activities[2].value.name, equals(activities[3].name));
      expect(result.activities[2].totalDuration, equals(Duration(days: 31)));

      expect(result.activities[3].value.name, equals(activities[1].name));
      expect(result.activities[3].totalDuration, equals(Duration(hours: 8)));

      expect(result.activities[4].value.name, equals(activities[4].name));
      expect(result.activities[4].totalDuration, equals(Duration()));

      // Last two activities do not have any overlapping sessions.
    });
  });
}
