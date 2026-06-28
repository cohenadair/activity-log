import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/activities_page.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mobile/widgets/activity_list_tile.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
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

    await pumpContext(tester, (_) => ActivitiesPage());
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

    await pumpContext(tester, (_) => ActivitiesPage());
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

      await pumpContext(tester, (_) => ActivitiesPage());
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

    await pumpContext(tester, (_) => ActivitiesPage());
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

    await pumpContext(tester, (_) => ActivitiesPage());
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

    await pumpContext(tester, (_) => ActivitiesPage());
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

    await pumpContext(tester, (_) => ActivitiesPage());
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

    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(EditActivityPage), findsOneWidget);
  });

  testWidgets("_sort sorts by totalTime descending", (tester) async {
    when(
      managers.preferencesManager.activitySortOption,
    ).thenReturn(ActivitySortOption.totalTime);

    stubActivityListModel([
      ActivityListTileModel(ActivityBuilder("Low").build)
        ..duration = const Duration(minutes: 5),
      ActivityListTileModel(ActivityBuilder("High").build)
        ..duration = const Duration(hours: 2),
    ]);

    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    final tiles = tester
        .widgetList<ActivityListTile>(find.byType(ActivityListTile))
        .toList();
    expect(tiles.first.model.activity.name, "High");
    expect(tiles.last.model.activity.name, "Low");
  });

  testWidgets("_sort sorts by mostRecentSession descending", (tester) async {
    when(
      managers.preferencesManager.activitySortOption,
    ).thenReturn(ActivitySortOption.mostRecentSession);

    stubActivityListModel([
      ActivityListTileModel(ActivityBuilder("Older").build)
        ..mostRecentSessionTimestamp = 100,
      ActivityListTileModel(ActivityBuilder("Newer").build)
        ..mostRecentSessionTimestamp = 999,
    ]);

    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    final tiles = tester
        .widgetList<ActivityListTile>(find.byType(ActivityListTile))
        .toList();
    expect(tiles.first.model.activity.name, "Newer");
    expect(tiles.last.model.activity.name, "Older");
  });

  testWidgets("_sort sorts by creationDate descending", (tester) async {
    when(
      managers.preferencesManager.activitySortOption,
    ).thenReturn(ActivitySortOption.creationDate);

    stubActivityListModel([
      ActivityListTileModel((ActivityBuilder("Older")..createdAt = 50).build),
      ActivityListTileModel((ActivityBuilder("Newer")..createdAt = 200).build),
    ]);

    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    final tiles = tester
        .widgetList<ActivityListTile>(find.byType(ActivityListTile))
        .toList();
    expect(tiles.first.model.activity.name, "Newer");
    expect(tiles.last.model.activity.name, "Older");
  });

  testWidgets("_sort sorts by alphabetical ascending", (tester) async {
    when(
      managers.preferencesManager.activitySortOption,
    ).thenReturn(ActivitySortOption.alphabetical);

    stubActivityListModel([
      ActivityListTileModel(ActivityBuilder("Zebra").build),
      ActivityListTileModel(ActivityBuilder("Apple").build),
    ]);

    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    final tiles = tester
        .widgetList<ActivityListTile>(find.byType(ActivityListTile))
        .toList();
    expect(tiles.first.model.activity.name, "Apple");
    expect(tiles.last.model.activity.name, "Zebra");
  });

  testWidgets("_buildSortButton shows checkmark next to current option", (
    tester,
  ) async {
    when(
      managers.preferencesManager.activitySortOption,
    ).thenReturn(ActivitySortOption.totalTime);

    stubActivityListModel([]);
    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.byIcon(Icons.more_vert));

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets("Selecting sort option calls setActivitySortOption", (
    tester,
  ) async {
    when(
      managers.preferencesManager.activitySortOption,
    ).thenReturn(ActivitySortOption.alphabetical);
    when(
      managers.preferencesManager.setActivitySortOption(any),
    ).thenAnswer((_) => Future.value());

    stubActivityListModel([]);
    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.byIcon(Icons.more_vert));
    await tapAndSettle(
      tester,
      find.text(
        Strings.of(
          tester.element(find.byType(ActivitiesPage)),
        ).activitiesPageSortTotalTime,
      ),
    );

    verify(
      managers.preferencesManager.setActivitySortOption(
        ActivitySortOption.totalTime,
      ),
    ).called(1);
  });

  testWidgets("_startSession starts session in DataManager", (tester) async {
    when(
      managers.preferencesManager.activitySortOption,
    ).thenReturn(ActivitySortOption.mostRecentSession);

    final activity = ActivityBuilder("Run").build;
    stubActivityListModel([ActivityListTileModel(activity)]);
    when(
      managers.dataManager.startSession(any, any),
    ).thenAnswer((_) => Future.value(null));

    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    tester
        .widget<ActivityListTile>(find.byType(ActivityListTile))
        .onTapStartSession();
    await tester.pumpAndSettle();

    verify(managers.dataManager.startSession(any, activity)).called(1);
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

    await pumpContext(tester, (_) => ActivitiesPage());
    await tester.pumpAndSettle();

    final tile = tester.widget<ActivityListTile>(find.byType(ActivityListTile));
    tile.onTap(activity);
    await tester.pumpAndSettle();

    final page = tester.widget<EditActivityPage>(find.byType(EditActivityPage));
    expect(page.editingActivity, activity);
  });
}
