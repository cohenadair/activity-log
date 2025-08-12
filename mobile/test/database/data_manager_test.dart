import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  late MockDatabase database;

  setUp(() async {
    managers = await StubbedManagers.create();

    var batch = MockBatch();
    when(batch.commit()).thenAnswer((_) => Future.value([]));

    database = MockDatabase();
    when(database.batch()).thenReturn(batch);

    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.days);
    when(
      managers.preferencesManager.homeDateRange,
    ).thenReturn(DateRange(period: DateRange_Period.allDates));

    DataManager.reset();
    await DataManager.get.init(database);
  });

  void stubActivities(List<Map<String, dynamic>> result) {
    when(
      database.rawQuery("SELECT * FROM activity"),
    ).thenAnswer((_) => Future.value(result));
  }

  void stubOverlappingSessions(
    String activityId,
    DateRange dateRange,
    List<Map<String, dynamic>> result,
  ) {
    var startMs = dateRange.startMs;
    var endMs = dateRange.endMs;
    when(
      database.rawQuery(
        """
          SELECT * FROM session
            WHERE activity_id = ?
            AND start_timestamp < ?
            AND (end_timestamp IS NULL OR end_timestamp > ?)
            AND is_banked = 0
            ORDER BY start_timestamp
          """,
        [activityId, endMs, startMs],
      ),
    ).thenAnswer((_) => Future.value(result));
  }

  Map<String, dynamic> buildSession(
    String activityId,
    DateTime start,
    DateTime end,
  ) {
    return (SessionBuilder(activityId)
          ..startTimestamp = start.millisecondsSinceEpoch
          ..endTimestamp = end.millisecondsSinceEpoch)
        .build
        .toMap();
  }

  Future<void> assertSummarizedActivities({
    required DateTime startDate,
    required DateTime endDate,
    required List<DateRange> sessionRangeList,
    required int expectedLength,
    required Duration expectedDuration,
  }) async {
    var dateRange = DateRange(
      startTimestamp:
          Int64(TimeManager.get.dateTimeToTz(startDate).millisecondsSinceEpoch),
      endTimestamp:
          Int64(TimeManager.get.dateTimeToTz(endDate).millisecondsSinceEpoch),
    );

    Activity activity = ActivityBuilder("").build;

    stubActivities([activity.toMap()]);
    stubOverlappingSessions(
      activity.id,
      dateRange,
      sessionRangeList.map((DateRange dateRange) {
        return buildSession(
          activity.id,
          dateRange.startDate,
          dateRange.endDate,
        );
      }).toList(),
    );

    var result = await DataManager.get.getSummarizedActivities(dateRange);

    expect(result.activities.length, equals(expectedLength));
    if (expectedLength > 0) {
      expect(result.activities[0].totalDuration, equals(expectedDuration));
    }
  }

  test("No activities", () async {
    stubActivities([]);
    var dateRange = DateRange(
      startTimestamp: Int64(TimeManager.get.currentTimestamp),
      endTimestamp: Int64(TimeManager.get.currentTimestamp),
    );
    var result = await DataManager.get.getSummarizedActivities(dateRange);
    expect(result.activities, isEmpty);
    expect(result.longestSession, isNull);
    expect(result.mostFrequentActivity, isNull);
  });

  test("Activities provided as parameter", () async {
    var dateRange = DateRange(
      startTimestamp: Int64(TimeManager.get
          .dateTimeFromValues(2018, 1, 1)
          .millisecondsSinceEpoch),
      endTimestamp: Int64(TimeManager.get
          .dateTimeFromValues(2018, 2, 1)
          .millisecondsSinceEpoch),
    );

    Activity activity = ActivityBuilder("").build;

    stubActivities([activity.toMap()]);
    stubOverlappingSessions(activity.id, dateRange, [
      buildSession(
        activity.id,
        TimeManager.get.dateTimeFromValues(2018, 1, 15, 5),
        TimeManager.get.dateTimeFromValues(2018, 1, 15, 7),
      ),
    ]);

    var result = await DataManager.get.getSummarizedActivities(dateRange, [
      activity,
    ]);

    expect(result.activities, isNotNull);
    expect(result.activities.length, equals(1));
    expect(
      result.activities[0].totalDuration,
      equals(const Duration(hours: 2)),
    );

    // Non-null input, 0 length.
    stubActivities([activity.toMap()]);
    result = await DataManager.get.getSummarizedActivities(dateRange, []);

    expect(result.activities, isNotNull);
    expect(result.activities.length, equals(1));
    expect(
      result.activities[0].totalDuration,
      equals(const Duration(hours: 2)),
    );
  });

  test("Session start outside range, session end inside range", () async {
    await assertSummarizedActivities(
      startDate: TimeManager.get.dateTimeFromValues(2018, 1, 15, 4, 30),
      endDate: TimeManager.get.dateTimeFromValues(2018, 1, 16, 4, 30),
      sessionRangeList: [
        DateRange(
          startTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 15, 2, 30)
              .millisecondsSinceEpoch),
          endTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 15, 7, 30)
              .millisecondsSinceEpoch),
        ),
      ],
      expectedLength: 1,
      expectedDuration: const Duration(hours: 3),
    );
  });

  test("Session start inside range, session end outside range", () async {
    await assertSummarizedActivities(
      startDate: TimeManager.get.dateTimeFromValues(2018, 1, 15, 4, 30),
      endDate: TimeManager.get.dateTimeFromValues(2018, 1, 16, 4, 30),
      sessionRangeList: [
        DateRange(
          startTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 16, 2, 30)
              .millisecondsSinceEpoch),
          endTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 16, 7, 30)
              .millisecondsSinceEpoch),
        ),
      ],
      expectedLength: 1,
      expectedDuration: const Duration(hours: 2),
    );
  });

  test("Session start outside range, session end outside range", () async {
    await assertSummarizedActivities(
      startDate: TimeManager.get.dateTimeFromValues(2018, 1, 15, 4, 30),
      endDate: TimeManager.get.dateTimeFromValues(2018, 1, 16, 4, 30),
      sessionRangeList: [
        DateRange(
          startTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 15, 2, 30)
              .millisecondsSinceEpoch),
          endTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 16, 7, 30)
              .millisecondsSinceEpoch),
        ),
      ],
      expectedLength: 1,
      expectedDuration: const Duration(days: 1),
    );
  });

  test("Session start inside range, session end inside range", () async {
    await assertSummarizedActivities(
      startDate: TimeManager.get.dateTimeFromValues(2018, 1, 15, 4, 30),
      endDate: TimeManager.get.dateTimeFromValues(2018, 1, 16, 4, 30),
      sessionRangeList: [
        DateRange(
          startTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 15, 8, 30)
              .millisecondsSinceEpoch),
          endTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 15, 20, 30)
              .millisecondsSinceEpoch),
        ),
      ],
      expectedLength: 1,
      expectedDuration: const Duration(hours: 12),
    );
  });

  test("Session start outside range, session end == range start", () async {
    await assertSummarizedActivities(
      startDate: TimeManager.get.dateTimeFromValues(2018, 1, 15, 4, 30),
      endDate: TimeManager.get.dateTimeFromValues(2018, 1, 16, 4, 30),
      sessionRangeList: [
        DateRange(
          startTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 14, 8, 30)
              .millisecondsSinceEpoch),
          endTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 15, 4, 30)
              .millisecondsSinceEpoch),
        ),
      ],
      expectedLength: 1,
      expectedDuration: const Duration(),
    );
  });

  test("Session start == range end, session end outside range", () async {
    await assertSummarizedActivities(
      startDate: TimeManager.get.dateTimeFromValues(2018, 1, 15, 4, 30),
      endDate: TimeManager.get.dateTimeFromValues(2018, 1, 16, 4, 30),
      sessionRangeList: [
        DateRange(
          startTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 16, 4, 30)
              .millisecondsSinceEpoch),
          endTimestamp: Int64(TimeManager.get
              .dateTimeFromValues(2018, 1, 18, 4, 30)
              .millisecondsSinceEpoch),
        ),
      ],
      expectedLength: 1,
      expectedDuration: const Duration(),
    );
  });

  test("Combination of all with multiple activities", () async {
    var dateRange = DateRange(
      startTimestamp: Int64(TimeManager.get
          .dateTimeFromValues(2018, 1, 1)
          .millisecondsSinceEpoch),
      endTimestamp: Int64(TimeManager.get
          .dateTimeFromValues(2018, 2, 1)
          .millisecondsSinceEpoch),
    );

    List<Activity> activities = [
      ActivityBuilder("Activity 1").build,
      ActivityBuilder("Activity 3").build,
      ActivityBuilder("Activity 0").build,
      ActivityBuilder("Activity 2").build,
      ActivityBuilder("Activity 4").build,
    ];

    stubActivities(
      activities.map((Activity activity) => activity.toMap()).toList(),
    );

    stubOverlappingSessions(activities[0].id, dateRange, [
      buildSession(
        activities[0].id,
        TimeManager.get.dateTimeFromValues(2017, 12, 31, 22),
        TimeManager.get.dateTimeFromValues(2018, 1, 1, 4),
      ), // Expected 4 hours
      buildSession(
        activities[0].id,
        TimeManager.get.dateTimeFromValues(2018, 1, 14, 12),
        TimeManager.get.dateTimeFromValues(2018, 1, 14, 15),
      ), // Expected 3 hours
      buildSession(
        activities[0].id,
        TimeManager.get.dateTimeFromValues(2018, 1, 31, 15),
        TimeManager.get.dateTimeFromValues(2018, 2, 1, 15),
      ), // Expected 9 hours
    ]);

    stubOverlappingSessions(activities[1].id, dateRange, [
      buildSession(
        activities[1].id,
        TimeManager.get.dateTimeFromValues(2018, 1, 9, 9),
        TimeManager.get.dateTimeFromValues(2018, 1, 9, 17),
      ), // Expected 8 hours
    ]);

    stubOverlappingSessions(activities[2].id, dateRange, [
      buildSession(
        activities[2].id,
        TimeManager.get.dateTimeFromValues(2018, 1, 1),
        TimeManager.get.dateTimeFromValues(2018, 1, 1, 15),
      ), // Expected 15 hours
      buildSession(
        activities[2].id,
        TimeManager.get.dateTimeFromValues(2018, 1, 20, 12),
        TimeManager.get.dateTimeFromValues(2018, 1, 20, 24),
      ), // Expected 12 hours
      buildSession(
        activities[2].id,
        TimeManager.get.dateTimeFromValues(2018, 1, 31, 15),
        TimeManager.get.dateTimeFromValues(2018, 2, 1),
      ), // Expected 9 hours
    ]);

    stubOverlappingSessions(activities[3].id, dateRange, [
      buildSession(
        activities[3].id,
        TimeManager.get.dateTimeFromValues(2018, 1, 1),
        TimeManager.get.dateTimeFromValues(2018, 2, 1),
      ), // Expected 31 days
    ]);

    stubOverlappingSessions(activities[4].id, dateRange, []);

    var result = await DataManager.get.getSummarizedActivities(dateRange);

    expect(result.activities, isNotNull);
    expect(result.activities.length, equals(5));

    // Should be sorted alphabetically and have the correct duration.

    expect(result.activities[0].value.name, equals(activities[2].name));
    expect(
      result.activities[0].totalDuration,
      equals(const Duration(hours: 36)),
    );

    expect(result.activities[1].value.name, equals(activities[0].name));
    expect(
      result.activities[1].totalDuration,
      equals(const Duration(hours: 16)),
    );

    expect(result.activities[2].value.name, equals(activities[3].name));
    expect(
      result.activities[2].totalDuration,
      equals(const Duration(days: 31)),
    );

    expect(result.activities[3].value.name, equals(activities[1].name));
    expect(
      result.activities[3].totalDuration,
      equals(const Duration(hours: 8)),
    );

    expect(result.activities[4].value.name, equals(activities[4].name));
    expect(result.activities[4].totalDuration, equals(const Duration()));

    // Last two activities do not have any overlapping sessions.
  });

  test("getInProgressSession returns null", () async {
    when(
      database.rawQuery(any, any),
    ).thenAnswer((_) => Future.value(List.empty()));
    expect(await DataManager.get.inProgressSession("id"), isNull);
  });

  test("getInProgressSession returns result", () async {
    when(database.rawQuery(any, any)).thenAnswer(
      (_) => Future.value([
        (SessionBuilder("")..startTimestamp = 500).build.toMap(),
      ]),
    );
    expect(await DataManager.get.inProgressSession("id"), isNotNull);
  });
}
