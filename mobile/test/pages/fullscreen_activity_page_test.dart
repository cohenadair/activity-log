import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/pages/fullscreen_activity_page.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/disposable_tester.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(
      managers.dataManager.activitiesUpdatedStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));
    when(
      managers.dataManager.inProgressSession(any),
    ).thenAnswer((_) => Future.value(null));

    when(
      managers.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.subscriptionManager.isFree).thenReturn(true);
    when(managers.subscriptionManager.isPro).thenReturn(false);

    when(managers.wakelockWrapper.enable()).thenAnswer((_) {});
    when(managers.wakelockWrapper.disable()).thenAnswer((_) {});
  });

  IconButton findStartStopButton(WidgetTester tester) {
    return tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.iconSize == 120.0,
      ),
    );
  }

  testWidgets("Page loads with no in-progress session", (tester) async {
    await tester.pumpWidget(Testable((_) => FullscreenActivityPage("")));
    await tester.pumpAndSettle();

    expect(find.text("Test"), findsOneWidget);
    expect(find.text("00:00"), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(findStartStopButton(tester).color, Colors.green);
    expect(find.byIcon(Icons.stop), findsNothing);
  });

  testWidgets("Page updates when session starts", (tester) async {
    var controller = StreamController<void>.broadcast();
    when(
      managers.dataManager.activitiesUpdatedStream,
    ).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(Testable((_) => FullscreenActivityPage("")));
    await tester.pumpAndSettle();

    var activity = MockActivity();
    when(activity.name).thenReturn("Test 2");
    when(activity.isRunning).thenReturn(true);
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(activity));

    var session = MockSession();
    when(session.duration).thenReturn(Duration(seconds: 10));
    when(
      managers.dataManager.inProgressSession(any),
    ).thenAnswer((_) => Future.value(session));

    when(
      managers.dataManager.startSession(any),
    ).thenAnswer((_) => Future.value(""));

    await tapAndSettle(tester, find.byIcon(Icons.play_arrow));
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("00:10"), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(findStartStopButton(tester).color, Colors.red);
    verify(managers.dataManager.startSession(any)).called(1);
    verifyNever(managers.dataManager.endSession(any));
  });

  testWidgets("Page updates when session stops", (tester) async {
    var controller = StreamController<void>.broadcast();
    when(
      managers.dataManager.activitiesUpdatedStream,
    ).thenAnswer((_) => controller.stream);

    var activity = MockActivity();
    when(activity.name).thenReturn("Test 2");
    when(activity.isRunning).thenReturn(true);
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(activity));

    var session = MockSession();
    when(session.duration).thenReturn(Duration(seconds: 10));
    when(
      managers.dataManager.inProgressSession(any),
    ).thenAnswer((_) => Future.value(session));

    when(
      managers.dataManager.startSession(any),
    ).thenAnswer((_) => Future.value(""));

    await tester.pumpWidget(Testable((_) => FullscreenActivityPage("")));
    await tester.pumpAndSettle();

    when(activity.isRunning).thenReturn(false);
    when(session.duration).thenReturn(Duration());

    await tapAndSettle(tester, find.byIcon(Icons.stop));
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("00:00"), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsNothing);
    expect(findStartStopButton(tester).color, Colors.green);
    verify(managers.dataManager.endSession(any)).called(1);
    verifyNever(managers.dataManager.startSession(any));
  });

  testWidgets("Portrait orientation", (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));

    await tester.pumpWidget(Testable((_) => FullscreenActivityPage("")));
    await tester.pumpAndSettle();

    var flex = tester.widget<Flex>(
      find.ancestor(
        of: find.byIcon(Icons.play_arrow),
        matching: find.byType(Flex),
      ),
    );
    expect(flex.direction, Axis.vertical);
  });

  testWidgets("Landscape orientation", (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 400));

    await tester.pumpWidget(Testable((_) => FullscreenActivityPage("")));
    await tester.pumpAndSettle();

    var flex = tester.widget<Flex>(
      find.ancestor(
        of: find.byIcon(Icons.play_arrow),
        matching: find.byType(Flex),
      ),
    );
    expect(flex.direction, Axis.horizontal);
  });

  testWidgets("Timer updates for an in-progress session", (tester) async {
    var activity = MockActivity();
    when(activity.name).thenReturn("Test 2");
    when(activity.isRunning).thenReturn(true);
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(activity));

    var session = MockSession();
    when(session.duration).thenReturn(Duration(seconds: 10));
    when(
      managers.dataManager.inProgressSession(any),
    ).thenAnswer((_) => Future.value(session));

    when(
      managers.dataManager.startSession(any),
    ).thenAnswer((_) => Future.value(""));

    await tester.pumpWidget(Testable((_) => FullscreenActivityPage("")));
    await tester.pumpAndSettle();
    expect(find.text("00:10"), findsOneWidget);

    // Update duration and pump some amount of time passed.
    when(session.duration).thenReturn(Duration(seconds: 20));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text("00:20"), findsOneWidget);
  });

  testWidgets("Wakelock is disabled on dispose", (tester) async {
    await pumpContext(
      tester,
      (_) => DisposableTester(child: FullscreenActivityPage("")),
    );

    var state = tester.firstState<DisposableTesterState>(
      find.byType(DisposableTester),
    );
    state.removeChild();
    await tester.pumpAndSettle();

    verify(managers.wakelockWrapper.disable()).called(1);
  });

  testWidgets("Wakelock is a no-op for free users", (tester) async {
    when(managers.subscriptionManager.isFree).thenReturn(true);
    when(managers.subscriptionManager.isPro).thenReturn(false);

    await pumpContext(tester, (_) => FullscreenActivityPage(""));
    await tester.pump();

    verifyNever(managers.wakelockWrapper.enable());
    verifyNever(managers.wakelockWrapper.disable());
  });

  testWidgets("Wakelock is enabled if activity is in progress", (tester) async {
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(managers.subscriptionManager.isPro).thenReturn(true);
    when(
      managers.dataManager.inProgressSession(any),
    ).thenAnswer((_) => Future.value(SessionBuilder("").build));

    await pumpContext(tester, (_) => FullscreenActivityPage(""));
    await tester.pump();

    verify(managers.wakelockWrapper.enable()).called(1);
    verifyNever(managers.wakelockWrapper.disable());
  });

  testWidgets("Wakelock is disabled if activity is not in progress", (
    tester,
  ) async {
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(managers.subscriptionManager.isPro).thenReturn(true);
    when(
      managers.dataManager.inProgressSession(any),
    ).thenAnswer((_) => Future.value(null));

    await pumpContext(tester, (_) => FullscreenActivityPage(""));
    await tester.pump();

    verifyNever(managers.wakelockWrapper.enable());
    verify(managers.wakelockWrapper.disable()).called(1);
  });
}
