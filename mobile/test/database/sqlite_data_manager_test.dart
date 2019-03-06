import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/sqlite_data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  MockDatabase database;
  SQLiteDataManager dataManager;

  setUp(() {
    database = MockDatabase();
    dataManager = SQLiteDataManager();
    dataManager.initialize(database);
  });

  tearDown(() {
    database = null;
    dataManager = null;
  });

  stubActivities(List<Map<String, dynamic>> result) {
    when(database.rawQuery("SELECT * FROM activity"))
        .thenAnswer((_) async => result);
  }

  group("getSummarizedActivities", () {
    stubOverlappingSessions(String activityId, DateRange dateRange,
        List<Map<String, dynamic>> result)
    {
      when(database.rawQuery("""
        SELECT * FROM session
          WHERE activity_id = ?
          AND start_timestamp < ?
          AND (end_timestamp IS NULL OR end_timestamp > ?)
        """, [activityId, dateRange.endMs, dateRange.startMs]
      )).thenAnswer((_) async => result);
    }

    Map<String, dynamic> buildSession(String activityId, DateTime start,
        DateTime end)
    {
      return (SessionBuilder(activityId)
        ..startTimestamp = start.millisecondsSinceEpoch
        ..endTimestamp = end.millisecondsSinceEpoch)
          .build.toMap();
    }

    assertSummarizedActivities({
      @required DateTime startDate,
      @required DateTime endDate,
      @required List<DateRange> sessionRangeList,
      @required int expectedLength,
      @required Duration expectedDuration,
    }) async {
      DateRange dateRange = DateRange(
        startDate: startDate,
        endDate: endDate,
      );
      Activity activity = ActivityBuilder("").build;

      stubActivities([activity.toMap()]);
      stubOverlappingSessions(activity.id, dateRange,
          sessionRangeList.map((DateRange dateRange) {
            return buildSession(
              activity.id,
              dateRange.startDate,
              dateRange.endDate,
            );
          }).toList());

      var result = await dataManager.getSummarizedActivities(dateRange);

      expect(result.length, equals(expectedLength));
      if (expectedLength > 0) {
        expect(result[0].totalDuration, equals(expectedDuration));
      }
    }

    test("Null input", () async {
      var result = await dataManager.getSummarizedActivities(null);
      expect(result.length, equals(0));
    });

    test("No activities", () async {
      stubActivities([]);
      var result = await dataManager.getSummarizedActivities(
          DateRange(startDate: DateTime.now(), endDate: DateTime.now()));
      expect(result.length, equals(0));
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
        expectedLength: 0,
        expectedDuration: null,
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
        expectedLength: 0,
        expectedDuration: null,
      );
    });

    test("Combination of all with multiple activities", () async {
      DateRange dateRange = DateRange(
        startDate: DateTime(2018, 1, 1),
        endDate: DateTime(2018, 2, 1),
      );

      List<Activity> activities = [
        ActivityBuilder("Activity 1").build,
        ActivityBuilder("Activity 3").build,
        ActivityBuilder("Activity 0").build,
        ActivityBuilder("Activity 2").build,
      ];

      stubActivities(activities.map((Activity activity) => activity.toMap())
          .toList());

      stubOverlappingSessions(activities[0].id, dateRange, [
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

      stubOverlappingSessions(activities[1].id, dateRange, [
        buildSession(
          activities[1].id,
          DateTime(2018, 1, 9, 9),
          DateTime(2018, 1, 9, 17),
        ), // Expected 8 hours
      ]);

      stubOverlappingSessions(activities[2].id, dateRange, [
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

      stubOverlappingSessions(activities[3].id, dateRange, [
        buildSession(
          activities[3].id,
          DateTime(2018, 1, 1),
          DateTime(2018, 2, 1),
        ), // Expected 31 days
      ]);

      var result = await dataManager.getSummarizedActivities(dateRange);

      expect(result.length, equals(4));

      // Should be sorted alphabetically and have the correct duration.

      expect(result[0].value.name, equals(activities[2].name));
      expect(result[0].totalDuration, equals(Duration(hours: 36)));

      expect(result[1].value.name, equals(activities[0].name));
      expect(result[1].totalDuration, equals(Duration(hours: 16)));

      expect(result[2].value.name, equals(activities[3].name));
      expect(result[2].totalDuration, equals(Duration(days: 31)));

      expect(result[3].value.name, equals(activities[1].name));
      expect(result[3].totalDuration, equals(Duration(hours: 8)));

      // Last two activities do not have any overlapping sessions.
    });
  });
}