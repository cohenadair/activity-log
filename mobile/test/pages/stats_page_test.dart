import 'dart:async';

import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mobile/widgets/activities_bar_chart.dart';
import 'package:mobile/widgets/activity_picker.dart';
import 'package:mobile/widgets/activity_summary.dart';
import 'package:mobile/widgets/stats_calendar.dart';
import 'package:mobile/widgets/stats_date_range_picker.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  late StreamController<void> activitiesUpdatedController;
  late StreamController<SessionEvent> sessionController;

  setUp(() async {
    managers = await StubbedManagers.create();
    activitiesUpdatedController = StreamController<void>.broadcast();
    sessionController = StreamController<SessionEvent>.broadcast();

    when(
      managers.dataManager.activitiesUpdatedStream,
    ).thenAnswer((_) => activitiesUpdatedController.stream);
    when(
      managers.dataManager.sessionStream,
    ).thenAnswer((_) => sessionController.stream);
    when(managers.dataManager.activityCount).thenAnswer((_) async => 1);
    when(managers.dataManager.activities).thenAnswer((_) async => []);

    when(
      managers.preferencesManager.statsDateRange,
    ).thenReturn(DateRange(period: DateRange_Period.allDates));
    when(managers.preferencesManager.statsSelectedActivityIds).thenReturn([]);
    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.hours);
    when(managers.preferencesManager.statsShowsCalendar).thenReturn(true);

    // Pro, so the calendar tab (rather than the chart) is the active tab in
    // the IndexedStack, matching the reported bug's context.
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(managers.subscriptionManager.isPro).thenReturn(true);
    when(
      managers.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    activitiesUpdatedController.close();
    sessionController.close();
  });

  SummarizedActivityList buildList(Activity activity, List<Session> sessions) {
    return SummarizedActivityList([
      SummarizedActivity(value: activity, dateRange: null, sessions: sessions),
    ], null);
  }

  testWidgets("Nothing is shown while the initial load is in flight", (
    tester,
  ) async {
    var completer = Completer<SummarizedActivityList>();
    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) => completer.future);

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pump();

    expect(find.byType(ActivityPicker), findsNothing);

    var activity = ActivityBuilder("Reading").build;
    completer.complete(buildList(activity, []));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPicker), findsOneWidget);
  });

  testWidgets(
    "Refreshing keeps old data visible and shows the floating indicator",
    (tester) async {
      var activity = ActivityBuilder("Reading").build;
      var oldSession = SessionBuilder(activity.id).endNow().build;
      var newSession = SessionBuilder(activity.id).endNow().build;

      when(
        managers.dataManager.getSummarizedActivities(any),
      ).thenAnswer((_) async => buildList(activity, [oldSession]));

      await pumpContext(tester, (_) => const StatsPage());
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        tester
            .widget<StatsCalendar>(find.byType(StatsCalendar))
            .summarizedActivities
            .first
            .sessions,
        equals([oldSession]),
      );

      var refreshCompleter = Completer<SummarizedActivityList>();
      when(
        managers.dataManager.getSummarizedActivities(any),
      ).thenAnswer((_) => refreshCompleter.future);

      activitiesUpdatedController.add(null);
      // One pump to let the stream event's listener microtask run, a second
      // to build the frame reflecting the setState it triggers.
      await tester.pump();
      await tester.pump();

      // The previous data is still shown, with the floating indicator
      // overlaid, instead of being replaced by a loading state.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<StatsCalendar>(find.byType(StatsCalendar))
            .summarizedActivities
            .first
            .sessions,
        equals([oldSession]),
      );

      refreshCompleter.complete(buildList(activity, [newSession]));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        tester
            .widget<StatsCalendar>(find.byType(StatsCalendar))
            .summarizedActivities
            .first
            .sessions,
        equals([newSession]),
      );
    },
  );

  testWidgets("Session deleted event refreshes only the affected activity", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    var session = SessionBuilder(activity.id).endNow().build;

    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) async => buildList(activity, [session]));
    when(managers.dataManager.getSummarizedActivity(any, any)).thenAnswer(
      (_) async =>
          SummarizedActivity(value: activity, dateRange: null, sessions: []),
    );

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    sessionController.add(SessionEvent(SessionEventType.deleted, session));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<StatsCalendar>(find.byType(StatsCalendar))
          .summarizedActivities
          .first
          .sessions,
      isEmpty,
    );
    verify(managers.dataManager.getSummarizedActivities(any)).called(1);
    verify(managers.dataManager.getSummarizedActivity(any, any)).called(1);
  });

  testWidgets(
    "A session event completing during a full refresh doesn't strand the "
    "refreshing indicator",
    (tester) async {
      var activity = ActivityBuilder("Reading").build;
      var session = SessionBuilder(activity.id).endNow().build;

      when(
        managers.dataManager.getSummarizedActivities(any),
      ).thenAnswer((_) async => buildList(activity, [session]));

      await pumpContext(tester, (_) => const StatsPage());
      await tester.pumpAndSettle();

      var refreshCompleter = Completer<SummarizedActivityList>();
      when(
        managers.dataManager.getSummarizedActivities(any),
      ).thenAnswer((_) => refreshCompleter.future);
      when(managers.dataManager.getSummarizedActivity(any, any)).thenAnswer(
        (_) async => SummarizedActivity(
          value: activity,
          dateRange: null,
          sessions: [session],
        ),
      );

      // A full refresh starts and is still in flight...
      activitiesUpdatedController.add(null);
      await tester.pump();
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // ...while an unrelated session event fires and resolves first. This
      // used to share the full refresh's generation counter, so completing
      // it would strand the refreshing indicator once the full refresh's
      // own generation check failed below.
      sessionController.add(SessionEvent(SessionEventType.updated, session));
      await tester.pump();
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      refreshCompleter.complete(buildList(activity, [session]));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );

  testWidgets("A slower, stale refresh is discarded", (tester) async {
    var activity = ActivityBuilder("Reading").build;
    var initialSession = SessionBuilder(activity.id).endNow().build;
    var staleSession = SessionBuilder(activity.id).endNow().build;
    var latestSession = SessionBuilder(activity.id).endNow().build;

    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) async => buildList(activity, [initialSession]));

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    var staleCompleter = Completer<SummarizedActivityList>();
    var latestCompleter = Completer<SummarizedActivityList>();
    var callCount = 0;
    when(managers.dataManager.getSummarizedActivities(any)).thenAnswer((_) {
      callCount++;
      return callCount == 1 ? staleCompleter.future : latestCompleter.future;
    });

    // Two refreshes triggered in quick succession; the second is the
    // most recently started, so its result should win regardless of
    // completion order.
    activitiesUpdatedController.add(null);
    await tester.pump();
    activitiesUpdatedController.add(null);
    await tester.pump();

    // The newer request completes first...
    latestCompleter.complete(buildList(activity, [latestSession]));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<StatsCalendar>(find.byType(StatsCalendar))
          .summarizedActivities
          .first
          .sessions,
      equals([latestSession]),
    );

    // ...and the older, slower request resolving afterwards must not
    // overwrite it.
    staleCompleter.complete(buildList(activity, [staleSession]));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<StatsCalendar>(find.byType(StatsCalendar))
          .summarizedActivities
          .first
          .sessions,
      equals([latestSession]),
    );
  });

  testWidgets("View toggle presents the Pro page when free", (tester) async {
    when(managers.preferencesManager.statsShowsCalendar).thenReturn(false);
    when(managers.subscriptionManager.isFree).thenReturn(true);
    when(managers.subscriptionManager.isPro).thenReturn(false);

    var activity = ActivityBuilder("Reading").build;
    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) async => buildList(activity, []));

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.byIcon(Icons.calendar_month));

    expect(find.byType(ActivityLogProPage), findsOneWidget);
    verifyNever(managers.preferencesManager.setStatsShowsCalendar(any));
  });

  testWidgets("View toggle switches tabs and persists the choice when Pro", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) async => buildList(activity, []));

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);

    await tapAndSettle(tester, find.byIcon(Icons.show_chart));

    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
    verify(managers.preferencesManager.setStatsShowsCalendar(false)).called(1);
  });

  testWidgets(
    "Subscription change recomputes the calendar view for free users",
    (tester) async {
      var subscriptionController = StreamController<void>.broadcast();
      when(
        managers.subscriptionManager.stream,
      ).thenAnswer((_) => subscriptionController.stream);
      addTearDown(subscriptionController.close);

      var activity = ActivityBuilder("Reading").build;
      when(
        managers.dataManager.getSummarizedActivities(any),
      ).thenAnswer((_) async => buildList(activity, []));

      await pumpContext(tester, (_) => const StatsPage());
      await tester.pumpAndSettle();

      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);

      when(managers.subscriptionManager.isFree).thenReturn(true);
      when(managers.subscriptionManager.isPro).thenReturn(false);
      subscriptionController.add(null);
      await tester.pumpAndSettle();

      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
    },
  );

  testWidgets("Picking activities triggers a refresh with the new filter", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    var otherActivity = ActivityBuilder("Running").build;
    when(
      managers.dataManager.getSummarizedActivities(any, any),
    ).thenAnswer((_) async => buildList(activity, []));

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    tester
        .widget<ActivityPicker>(find.byType(ActivityPicker))
        .onPickedActivitiesChanged({otherActivity});
    await tester.pumpAndSettle();

    verify(
      managers.preferencesManager.setStatsSelectedActivityIds([
        otherActivity.id,
      ]),
    ).called(1);
    verify(
      managers.dataManager.getSummarizedActivities(null, [otherActivity]),
    ).called(1);
  });

  testWidgets("Picking a date range triggers a refresh with the new range", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    when(
      managers.dataManager.getSummarizedActivities(any, any),
    ).thenAnswer((_) async => buildList(activity, []));

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    var pickedRange = DateRange(
      period: DateRange_Period.custom,
      startTimestamp: Int64(0),
      endTimestamp: Int64(1000),
    );
    tester
        .widget<StatsDateRangePicker>(find.byType(StatsDateRangePicker))
        .onDurationPicked(pickedRange);
    await tester.pumpAndSettle();

    verify(
      managers.preferencesManager.setStatsDateRange(pickedRange),
    ).called(1);
    verify(
      managers.dataManager.getSummarizedActivities(pickedRange, any),
    ).called(1);
  });

  testWidgets("Chart tab renders the aggregate view for multiple activities", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    var otherActivity = ActivityBuilder("Running").build;
    var session = SessionBuilder(activity.id).endNow().build;
    var otherSession = SessionBuilder(otherActivity.id).endNow().build;

    when(managers.dataManager.getSummarizedActivities(any)).thenAnswer(
      (_) async => SummarizedActivityList([
        SummarizedActivity(
          value: activity,
          dateRange: null,
          sessions: [session],
        ),
        SummarizedActivity(
          value: otherActivity,
          dateRange: null,
          sessions: [otherSession],
        ),
      ], null),
    );

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    expect(
      find.byType(ActivitiesDurationBarChart, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets(
    "Chart tab checks the per-activity date range for a single activity",
    (tester) async {
      var activity = ActivityBuilder("Reading").build;
      var session = SessionBuilder(activity.id).endNow().build;
      var perActivityRange = DateRange(
        period: DateRange_Period.custom,
        startTimestamp: Int64(0),
        endTimestamp: Int64(1000),
      );

      when(managers.dataManager.getSummarizedActivities(any)).thenAnswer(
        (_) async => SummarizedActivityList([
          SummarizedActivity(
            value: activity,
            dateRange: perActivityRange,
            sessions: [session],
          ),
        ], null),
      );

      await pumpContext(tester, (_) => const StatsPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivitySummary, skipOffstage: false), findsOneWidget);
    },
  );

  testWidgets("Loading is shown when the summarized data failed to load", (
    tester,
  ) async {
    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) async => throw Exception("boom"));

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pump();
    await tester.pump();

    expect(find.byType(Loading), findsOneWidget);
  });

  testWidgets("Nothing crashes when the activity count fails to load", (
    tester,
  ) async {
    var activity = ActivityBuilder("Reading").build;
    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) async => buildList(activity, []));
    when(
      managers.dataManager.activityCount,
    ).thenAnswer((_) async => throw Exception("boom"));

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    expect(find.byType(StatsPage), findsOneWidget);
    expect(find.byType(ActivityPicker), findsNothing);
  });

  testWidgets("No-data message is shown when the filter matches nothing", (
    tester,
  ) async {
    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) async => SummarizedActivityList([], null));

    await pumpContext(tester, (_) => const StatsPage());
    await tester.pumpAndSettle();

    expect(find.byType(ErrorText), findsOneWidget);
  });

  testWidgets(
    "getSummarizedActivity error during a session update is logged and "
    "doesn't crash",
    (tester) async {
      var activity = ActivityBuilder("Reading").build;
      var session = SessionBuilder(activity.id).endNow().build;

      when(
        managers.dataManager.getSummarizedActivities(any),
      ).thenAnswer((_) async => buildList(activity, [session]));
      when(
        managers.dataManager.getSummarizedActivity(any, any),
      ).thenAnswer((_) async => throw Exception("boom"));

      await pumpContext(tester, (_) => const StatsPage());
      await tester.pumpAndSettle();

      sessionController.add(SessionEvent(SessionEventType.updated, session));
      await tester.pumpAndSettle();

      // The stale data remains displayed since the refresh failed.
      expect(
        tester
            .widget<StatsCalendar>(find.byType(StatsCalendar))
            .summarizedActivities
            .first
            .sessions,
        equals([session]),
      );
    },
  );
}
