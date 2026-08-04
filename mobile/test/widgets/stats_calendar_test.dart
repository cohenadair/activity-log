import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/pages/edit_session_page.dart';
import 'package:mobile/widgets/stats_calendar.dart';
import 'package:mockito/mockito.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    var today = TimeManager.get.dateTimeFromValues(2022, 10, 15, 9);
    when(managers.timeManager.currentDateTime).thenReturn(today);
    when(
      managers.timeManager.currentTimestamp,
    ).thenReturn(today.millisecondsSinceEpoch);
  });

  Session buildSession(String activityId, {bool inProgress = false}) {
    var builder = SessionBuilder(activityId)
      ..startTimestamp = TimeManager.get
          .dateTimeFromValues(2022, 10, 15, 8)
          .millisecondsSinceEpoch;
    if (!inProgress) {
      builder.endTimestamp = TimeManager.get
          .dateTimeFromValues(2022, 10, 15, 9)
          .millisecondsSinceEpoch;
    }
    return builder.build;
  }

  List<SummarizedActivity> buildSummarized(Activity activity, Session session) {
    return [
      SummarizedActivity(value: activity, dateRange: null, sessions: [session]),
    ];
  }

  testWidgets("Today's month is shown initially", (tester) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // 1 for our header, one for SfCalendar's own hidden header.
    expect(find.text("October 2022"), findsNWidgets(2));
  });

  testWidgets("Backward chevron moves to the previous month", (tester) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left));

    expect(find.text("October 2022"), findsNothing);
    expect(find.text("September 2022"), findsNWidgets(2));
  });

  testWidgets("Forward chevron moves to the next month", (tester) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));

    expect(find.text("October 2022"), findsNothing);
    expect(find.text("November 2022"), findsNWidgets(2));
  });

  testWidgets("Header tap opens the month/year picker and updates state", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("October 2022").first);
    await tapAndSettle(tester, find.text("Sep"));
    await tapAndSettle(tester, find.text("OK"));

    expect(find.text("October 2022"), findsNothing);
    expect(find.text("September 2022"), findsNWidgets(2));
  });

  testWidgets("Header tap cancel leaves the month unchanged", (tester) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("October 2022").first);
    await tapAndSettle(tester, find.text("CANCEL"));

    expect(find.text("October 2022"), findsNWidgets(2));
  });

  testWidgets("Event builder exits early for invalid appointment count", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);

    var context = await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    var sfCalendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
    var event = sfCalendar.appointmentBuilder!(
      context,
      CalendarAppointmentDetails(
        DateTime.now(),
        [],
        const Rect.fromLTWH(0, 0, 10, 10),
      ),
    );

    expect(event, isA<SizedBox>());
  });

  testWidgets("In-progress session shows the in-progress label", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id, inProgress: true);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("In progress"), findsOneWidget);
  });

  testWidgets("Ended session shows a time range instead of in-progress", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("In progress"), findsNothing);
  });

  testWidgets("Tapping an event opens EditSessionPage", (tester) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Reading"));
    expect(find.byType(EditSessionPage), findsOneWidget);
  });

  testWidgets("Updating summarizedActivities refreshes the calendar events", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    var session = buildSession(activity.id);
    var otherActivity = ActivityBuilder("Running").build;
    var otherSession = buildSession(otherActivity.id);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(activity, session),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Reading"), findsOneWidget);

    await pumpContext(
      tester,
      (_) => Scaffold(
        body: StatsCalendar(
          summarizedActivities: buildSummarized(otherActivity, otherSession),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Reading"), findsNothing);
    expect(find.text("Running"), findsOneWidget);
  });

  testWidgets(
    "Reassigning the same summarizedActivities list doesn't rebuild events",
    (tester) async {
      var activity = ActivityBuilder("Reading").build;
      var session = buildSession(activity.id);
      var summarized = buildSummarized(activity, session);

      await pumpContext(
        tester,
        (_) => Scaffold(body: StatsCalendar(summarizedActivities: summarized)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      await pumpContext(
        tester,
        (_) => Scaffold(body: StatsCalendar(summarizedActivities: summarized)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.text("Reading"), findsOneWidget);
    },
  );
}
