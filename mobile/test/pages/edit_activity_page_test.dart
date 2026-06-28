import 'package:adair_flutter_lib/widgets/checkbox_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/pages/edit_session_page.dart';
import 'package:mobile/pages/sessions_page.dart';
import 'package:mobile/widgets/session_list_tile.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.subscriptionManager.isPro).thenReturn(true);
    when(
      managers.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));
    when(
      managers.dataManager.activityNameExists(any),
    ).thenAnswer((_) => Future.value(false));
  });

  void stubEditingStubs() {
    when(
      managers.dataManager.getRecentSessions(any, any),
    ).thenAnswer((_) => Future.value([]));
    when(
      managers.dataManager.getSessionCount(any),
    ).thenAnswer((_) => Future.value(0));
    when(
      managers.dataManager.getSessionsUpdatedStream(any),
    ).thenAnswer((_) => const Stream.empty());
  }

  testWidgets("onDelete calls removeActivity after confirmation", (
    tester,
  ) async {
    final existing = ActivityBuilder("Run").build;
    stubEditingStubs();

    await tester.pumpWidget(Testable((_) => EditActivityPage(existing)));
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text("DELETE"));
    await tapAndSettle(tester, find.text("DELETE").last);

    verify(managers.dataManager.removeActivity(existing.id)).called(1);
  });

  testWidgets(
    "onProRequired for archived checkbox presents ActivityLogProPage",
    (tester) async {
      when(managers.subscriptionManager.isPro).thenReturn(false);

      await tester.pumpWidget(Testable((_) => const EditActivityPage()));
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      await tapAndSettle(tester, checkboxes.first);

      expect(find.byType(ActivityLogProPage), findsOneWidget);
    },
  );

  testWidgets(
    "onProRequired for hidden-from-stats checkbox presents ActivityLogProPage",
    (tester) async {
      when(managers.subscriptionManager.isPro).thenReturn(false);

      await tester.pumpWidget(Testable((_) => const EditActivityPage()));
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      await tapAndSettle(tester, checkboxes.last);

      expect(find.byType(ActivityLogProPage), findsOneWidget);
    },
  );

  testWidgets("SessionListTile is rendered for each recent session", (
    tester,
  ) async {
    final existing = ActivityBuilder("Run").build;
    final session = (SessionBuilder(existing.id)..startTimestamp = 1000).build;
    when(
      managers.dataManager.getRecentSessions(any, any),
    ).thenAnswer((_) => Future.value([session]));
    when(
      managers.dataManager.getSessionCount(any),
    ).thenAnswer((_) => Future.value(1));
    when(
      managers.dataManager.getSessionsUpdatedStream(any),
    ).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(Testable((_) => EditActivityPage(existing)));
    await tester.pumpAndSettle();

    expect(find.byType(SessionListTile), findsOneWidget);
  });

  testWidgets("Tapping SessionListTile opens EditSessionPage with session", (
    tester,
  ) async {
    final existing = ActivityBuilder("Run").build;
    final session = (SessionBuilder(existing.id)..startTimestamp = 1000).build;
    when(
      managers.dataManager.getRecentSessions(any, any),
    ).thenAnswer((_) => Future.value([session]));
    when(
      managers.dataManager.getSessionCount(any),
    ).thenAnswer((_) => Future.value(1));
    when(
      managers.dataManager.getSessionsUpdatedStream(any),
    ).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(Testable((_) => EditActivityPage(existing)));
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.byType(SessionListTile));

    expect(find.byType(EditSessionPage), findsOneWidget);
  });

  testWidgets(
    "Add session button opens EditSessionPage with activity pre-filled",
    (tester) async {
      final existing = ActivityBuilder("Run").build;
      stubEditingStubs();

      await tester.pumpWidget(Testable((_) => EditActivityPage(existing)));
      await tester.pumpAndSettle();

      await tapAndSettle(tester, find.byIcon(Icons.add));

      expect(find.byType(EditSessionPage), findsOneWidget);
      expect(find.text("New Run Session"), findsOneWidget);
    },
  );

  testWidgets(
    "View all button is hidden when session count does not exceed limit",
    (tester) async {
      final existing = ActivityBuilder("Run").build;
      when(
        managers.dataManager.getRecentSessions(any, any),
      ).thenAnswer((_) => Future.value([]));
      when(
        managers.dataManager.getSessionCount(any),
      ).thenAnswer((_) => Future.value(3));
      when(
        managers.dataManager.getSessionsUpdatedStream(any),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(Testable((_) => EditActivityPage(existing)));
      await tester.pumpAndSettle();

      expect(find.text("VIEW ALL"), findsNothing);
    },
  );

  testWidgets("View all button is shown when session count exceeds limit", (
    tester,
  ) async {
    final existing = ActivityBuilder("Run").build;
    final session = (SessionBuilder(existing.id)..startTimestamp = 1000).build;
    when(
      managers.dataManager.getRecentSessions(any, any),
    ).thenAnswer((_) => Future.value([session]));
    when(
      managers.dataManager.getSessionCount(any),
    ).thenAnswer((_) => Future.value(4));
    when(
      managers.dataManager.getSessionsUpdatedStream(any),
    ).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(Testable((_) => EditActivityPage(existing)));
    await tester.pumpAndSettle();

    expect(find.text("VIEW ALL"), findsOneWidget);
  });

  testWidgets("Tapping view all button opens SessionsPage", (tester) async {
    final existing = ActivityBuilder("Run").build;
    final session = (SessionBuilder(existing.id)..startTimestamp = 1000).build;
    when(
      managers.dataManager.getRecentSessions(any, any),
    ).thenAnswer((_) => Future.value([session]));
    when(
      managers.dataManager.getSessionCount(any),
    ).thenAnswer((_) => Future.value(4));
    when(
      managers.dataManager.getSessionsUpdatedStream(any),
    ).thenAnswer((_) => const Stream.empty());
    when(
      managers.dataManager.getSessions(any),
    ).thenAnswer((_) => Future.value([]));

    await tester.pumpWidget(Testable((_) => EditActivityPage(existing)));
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text("VIEW ALL"));

    expect(find.byType(SessionsPage), findsOneWidget);
  });

  testWidgets("Save with empty name shows missing name validation error", (
    tester,
  ) async {
    await tester.pumpWidget(Testable((_) => const EditActivityPage()));
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text("SAVE"));

    expect(find.text("Enter a name for your activity"), findsOneWidget);
  });

  testWidgets("_buildArchived shows ProCheckboxInput with archived label", (
    tester,
  ) async {
    await tester.pumpWidget(Testable((_) => const EditActivityPage()));
    await tester.pumpAndSettle();

    final checkboxes = tester.widgetList<ProCheckboxInput>(
      find.byType(ProCheckboxInput),
    );
    expect(checkboxes.any((c) => c.label == "Archived"), isTrue);
  });

  testWidgets(
    "_buildIsHiddenFromStats shows ProCheckboxInput with hide-from-stats label",
    (tester) async {
      await tester.pumpWidget(Testable((_) => const EditActivityPage()));
      await tester.pumpAndSettle();

      final checkboxes = tester.widgetList<ProCheckboxInput>(
        find.byType(ProCheckboxInput),
      );
      expect(checkboxes.any((c) => c.label == "Hidden From Stats"), isTrue);
    },
  );

  testWidgets("Checking archived auto-sets isHiddenFromStats to true", (
    tester,
  ) async {
    await tester.pumpWidget(Testable((_) => const EditActivityPage()));
    await tester.pumpAndSettle();

    final checkboxes = find.byType(Checkbox);
    // First checkbox is Archived, second is Hidden From Stats.
    await tapAndSettle(tester, checkboxes.first);

    final checkboxWidgets = tester
        .widgetList<Checkbox>(find.byType(Checkbox))
        .toList();
    expect(checkboxWidgets[0].value, isTrue);
    expect(checkboxWidgets[1].value, isTrue);
  });

  testWidgets(
    "Save when creating calls addActivity with isArchived and isHiddenFromStats",
    (tester) async {
      Activity? savedActivity;
      when(managers.dataManager.addActivity(any)).thenAnswer((inv) async {
        savedActivity = inv.positionalArguments.first as Activity;
      });

      await tester.pumpWidget(Testable((_) => const EditActivityPage()));
      await tester.pumpAndSettle();

      await enterTextAndSettle(tester, find.byType(TextFormField), "Yoga");

      final checkboxes = find.byType(Checkbox);
      await tapAndSettle(tester, checkboxes.first);

      await tapAndSettle(tester, find.text("SAVE"));

      expect(savedActivity, isNotNull);
      expect(savedActivity!.name, "Yoga");
      expect(savedActivity!.isArchived, isTrue);
      expect(savedActivity!.isHiddenFromStats, isTrue);
    },
  );

  testWidgets(
    "Save when editing calls updateActivity with isArchived and isHiddenFromStats",
    (tester) async {
      final existing = ActivityBuilder("Run").build;
      Activity? updatedActivity;
      when(managers.dataManager.updateActivity(any)).thenAnswer((inv) async {
        updatedActivity = inv.positionalArguments.first as Activity;
      });
      when(
        managers.dataManager.getRecentSessions(any, any),
      ).thenAnswer((_) => Future.value([]));
      when(
        managers.dataManager.getSessionCount(any),
      ).thenAnswer((_) => Future.value(0));
      when(
        managers.dataManager.getSessionsUpdatedStream(any),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(Testable((_) => EditActivityPage(existing)));
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      // Tap "Hidden From Stats" (second checkbox) independently.
      await tapAndSettle(tester, checkboxes.last);

      await tapAndSettle(tester, find.text("SAVE"));

      expect(updatedActivity, isNotNull);
      expect(updatedActivity!.isHiddenFromStats, isTrue);
      expect(updatedActivity!.isArchived, isFalse);
    },
  );
}
