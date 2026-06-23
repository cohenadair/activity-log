import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/activities_page.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mobile/widgets/activity_list_tile.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  void stubActivityListModel(List<ActivityListTileModel> models) {
    when(managers.dataManager.initialActivityListTileModels).thenReturn([]);

    when(
      managers.dataManager.getActivityListModel(
        dateRange: anyNamed("dateRange"),
      ),
    ).thenAnswer((_) => Future.value(models));

    when(
      managers.dataManager.activitiesUpdatedStream,
    ).thenAnswer((_) => const Stream.empty());
  }

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.preferencesManager.homeDateRange,
    ).thenReturn(DateRange(period: DateRange_Period.allDates));
    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.hours);

    when(managers.subscriptionManager.isPro).thenReturn(false);
    when(managers.subscriptionManager.isFree).thenReturn(true);
    when(
      managers.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));
    when(
      managers.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      managers.dataManager.sessionStream,
    ).thenAnswer((_) => const Stream.empty());

    when(managers.appConfig.appIcon).thenReturn(Icons.home);
    when(managers.appConfig.appName).thenReturn(() => "Activity Log");
  });

  testWidgets("Shows empty state when no activities", (tester) async {
    stubActivityListModel([]);

    await tester.pumpWidget(Testable((_) => ActivitiesPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityListTile), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(EmptyPageHelp), findsOneWidget);
  });

  testWidgets("Shows active tiles when only active activities exist", (
    tester,
  ) async {
    final activity = ActivityBuilder("Run").build;
    stubActivityListModel([ActivityListTileModel(activity)]);

    await tester.pumpWidget(Testable((_) => ActivitiesPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityListTile), findsOneWidget);
    expect(find.text("Archived"), findsNothing);
  });

  testWidgets(
    "Shows archived section header and tiles when archived activities exist",
    (tester) async {
      final archivedActivity = (ActivityBuilder(
        "Old",
      )..isArchived = true).build;
      stubActivityListModel([ActivityListTileModel(archivedActivity)]);

      await tester.pumpWidget(Testable((_) => ActivitiesPage()));
      await tester.pumpAndSettle();

      expect(find.text("Archived"), findsOneWidget);
      expect(find.byType(ActivityListTile), findsOneWidget);
    },
  );

  testWidgets("Does not show archived section when no archived activities", (
    tester,
  ) async {
    final active = ActivityBuilder("Run").build;
    stubActivityListModel([ActivityListTileModel(active)]);

    await tester.pumpWidget(Testable((_) => ActivitiesPage()));
    await tester.pumpAndSettle();

    expect(find.text("Archived"), findsNothing);
  });

  testWidgets("Shows both active and archived tiles with section header", (
    tester,
  ) async {
    final active = ActivityBuilder("Run").build;
    final archived = (ActivityBuilder("Old")..isArchived = true).build;
    stubActivityListModel([
      ActivityListTileModel(active),
      ActivityListTileModel(archived),
    ]);

    await tester.pumpWidget(Testable((_) => ActivitiesPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityListTile), findsNWidgets(2));
    expect(find.text("Archived"), findsOneWidget);
  });

  testWidgets("_startSession calls DataManager.startSession", (tester) async {
    final activity = ActivityBuilder("Run").build;
    stubActivityListModel([ActivityListTileModel(activity)]);
    when(
      managers.dataManager.startSession(any, any),
    ).thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable((_) => ActivitiesPage()));
    await tester.pumpAndSettle();

    final tile = tester.widget<ActivityListTile>(find.byType(ActivityListTile));
    tile.onTapStartSession();
    await tester.pumpAndSettle();

    verify(managers.dataManager.startSession(any, activity)).called(1);
  });

  testWidgets("_endSession calls DataManager.endSession", (tester) async {
    final activity = ActivityBuilder("Run").build;
    stubActivityListModel([ActivityListTileModel(activity)]);
    when(
      managers.dataManager.endSession(any),
    ).thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable((_) => ActivitiesPage()));
    await tester.pumpAndSettle();

    final tile = tester.widget<ActivityListTile>(find.byType(ActivityListTile));
    tile.onTapEndSession();
    await tester.pumpAndSettle();

    verify(managers.dataManager.endSession(activity)).called(1);
  });

  testWidgets("Add button opens EditActivityPage for new activity", (
    tester,
  ) async {
    stubActivityListModel([]);
    when(
      managers.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));
    when(
      managers.dataManager.activityNameExists(any),
    ).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(Testable((_) => ActivitiesPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(EditActivityPage), findsOneWidget);
  });

  testWidgets("Tapping activity tile opens EditActivityPage with activity", (
    tester,
  ) async {
    final activity = ActivityBuilder("Run").build;
    stubActivityListModel([ActivityListTileModel(activity)]);
    when(
      managers.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));
    when(
      managers.dataManager.activityNameExists(any),
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.dataManager.getRecentSessions(any, any),
    ).thenAnswer((_) => Future.value([]));
    when(
      managers.dataManager.getSessionCount(any),
    ).thenAnswer((_) => Future.value(0));
    when(
      managers.dataManager.getSessionsUpdatedStream(any),
    ).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(Testable((_) => ActivitiesPage()));
    await tester.pumpAndSettle();

    final tile = tester.widget<ActivityListTile>(find.byType(ActivityListTile));
    tile.onTap(activity);
    await tester.pumpAndSettle();

    final page = tester.widget<EditActivityPage>(find.byType(EditActivityPage));
    expect(page.editingActivity, activity);
  });
}
