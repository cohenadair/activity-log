import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mobile/widgets/activity_summary.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.hours);
  });

  Session buildSession(DateTime start, DateTime? end) {
    final builder = SessionBuilder("activity_id")
      ..startTimestamp = start.millisecondsSinceEpoch;
    if (end != null) {
      builder.endTimestamp = end.millisecondsSinceEpoch;
    }
    return builder.build;
  }

  Future<void> pump(WidgetTester tester, SummarizedActivity activity) async {
    final controller = ScrollController();
    await pumpContext(
      tester,
      (_) => SingleChildScrollView(
        controller: controller,
        child: ActivitySummary(
          activity: activity,
          scrollController: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    "Session count shows 0 days and 0 percent when sessions are empty",
    (tester) async {
      final activity = SummarizedActivity(
        value: ActivityBuilder("Test").build,
        dateRange: null,
        sessions: [],
      );

      await pump(tester, activity);

      // totalDaysForSessions is 0 → percent branch returns 0.
      expect(find.text("0 in 0 days (0%)"), findsOneWidget);
    },
  );

  testWidgets("Session count shows singular day string when totalDays is 1", (
    tester,
  ) async {
    final activity = SummarizedActivity(
      value: ActivityBuilder("Test").build,
      dateRange: DateRange(
        period: DateRange_Period.custom,
        startTimestamp: Int64(DateTime(2024, 1, 1).millisecondsSinceEpoch),
        endTimestamp: Int64(DateTime(2024, 1, 2).millisecondsSinceEpoch),
      ),
      sessions: [],
    );

    await pump(tester, activity);

    // totalDaysForSessions = 1 (empty sessions + dateRange = 1 day) → singular
    expect(find.text("0 in 1 day (0%)"), findsOneWidget);
  });

  testWidgets("Session count shows plural day string when totalDays is > 1", (
    tester,
  ) async {
    final activity = SummarizedActivity(
      value: ActivityBuilder("Test").build,
      dateRange: DateRange(
        period: DateRange_Period.custom,
        startTimestamp: Int64(DateTime(2024, 1, 1).millisecondsSinceEpoch),
        endTimestamp: Int64(DateTime(2024, 1, 2, 15).millisecondsSinceEpoch),
      ),
      sessions: [],
    );

    await pump(tester, activity);

    // totalDaysForSessions = 1 (empty sessions + dateRange = 1 day) → singular
    expect(find.text("0 in 2 days (0%)"), findsOneWidget);
  });

  testWidgets(
    "Session count shows correct days and percent when sessions exist",
    (tester) async {
      final activity = SummarizedActivity(
        value: ActivityBuilder("Test").build,
        dateRange: DateRange(
          period: DateRange_Period.custom,
          startTimestamp: Int64(DateTime(2024, 1, 1).millisecondsSinceEpoch),
          endTimestamp: Int64(DateTime(2024, 1, 5).millisecondsSinceEpoch),
        ),
        sessions: [
          buildSession(DateTime(2024, 1, 1, 10), DateTime(2024, 1, 1, 11)),
          buildSession(DateTime(2024, 1, 3, 10), DateTime(2024, 1, 3, 11)),
        ],
      );

      await pump(tester, activity);

      // 2 sessions in 4 days → 50%.
      expect(find.text("2 in 4 days (50%)"), findsOneWidget);
    },
  );
}
