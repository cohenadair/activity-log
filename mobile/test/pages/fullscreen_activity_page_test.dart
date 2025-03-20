import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/fullscreen_activity_page.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() {
    managers = StubbedManagers();
    when(managers.dataManager.activitiesUpdatedStream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.dataManager.activity(any))
        .thenAnswer((_) => Future.value(ActivityBuilder("Test").build));
    when(managers.dataManager.inProgressSession(any))
        .thenAnswer((_) => Future.value(null));
  });

  IconButton findStartStopButton(WidgetTester tester) {
    return tester.widget<IconButton>(find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.iconSize == 120.0));
  }

  testWidgets("Page loads with no in-progress session", (tester) async {
    await pumpContext(tester, (context) => FullscreenActivityPage(""));
    await tester.pumpAndSettle();

    expect(find.text("Test"), findsOneWidget);
    expect(find.text("00:00"), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(findStartStopButton(tester).color, Colors.green);
    expect(find.byIcon(Icons.stop), findsNothing);
  });

  testWidgets("Page updates when session starts", (tester) async {
    var controller = StreamController<void>.broadcast();
    when(managers.dataManager.activitiesUpdatedStream)
        .thenAnswer((_) => controller.stream);

    await pumpContext(tester, (context) => FullscreenActivityPage(""));
    await tester.pumpAndSettle();

    var activity = MockActivity();
    when(activity.name).thenReturn("Test 2");
    when(activity.isRunning).thenReturn(true);
    when(managers.dataManager.activity(any))
        .thenAnswer((_) => Future.value(activity));

    var session = MockSession();
    when(session.duration).thenReturn(Duration(seconds: 10));
    when(managers.dataManager.inProgressSession(any))
        .thenAnswer((_) => Future.value(session));

    when(managers.dataManager.startSession(any))
        .thenAnswer((_) => Future.value(""));

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
    when(managers.dataManager.activitiesUpdatedStream)
        .thenAnswer((_) => controller.stream);

    var activity = MockActivity();
    when(activity.name).thenReturn("Test 2");
    when(activity.isRunning).thenReturn(true);
    when(managers.dataManager.activity(any))
        .thenAnswer((_) => Future.value(activity));

    var session = MockSession();
    when(session.duration).thenReturn(Duration(seconds: 10));
    when(managers.dataManager.inProgressSession(any))
        .thenAnswer((_) => Future.value(session));

    when(managers.dataManager.startSession(any))
        .thenAnswer((_) => Future.value(""));

    await pumpContext(tester, (context) => FullscreenActivityPage(""));
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

    await pumpContext(tester, (context) => FullscreenActivityPage(""));
    await tester.pumpAndSettle();

    var flex = tester.widget<Flex>(find.ancestor(
      of: find.byIcon(Icons.play_arrow),
      matching: find.byType(Flex),
    ));
    expect(flex.direction, Axis.vertical);
  });

  testWidgets("Landscape orientation", (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 400));

    await pumpContext(tester, (context) => FullscreenActivityPage(""));
    await tester.pumpAndSettle();

    var flex = tester.widget<Flex>(find.ancestor(
      of: find.byIcon(Icons.play_arrow),
      matching: find.byType(Flex),
    ));
    expect(flex.direction, Axis.horizontal);
  });

  testWidgets("Timer updates for an in-progress session", (tester) async {
    var activity = MockActivity();
    when(activity.name).thenReturn("Test 2");
    when(activity.isRunning).thenReturn(true);
    when(managers.dataManager.activity(any))
        .thenAnswer((_) => Future.value(activity));

    var session = MockSession();
    when(session.duration).thenReturn(Duration(seconds: 10));
    when(managers.dataManager.inProgressSession(any))
        .thenAnswer((_) => Future.value(session));

    when(managers.dataManager.startSession(any))
        .thenAnswer((_) => Future.value(""));

    await pumpContext(tester, (context) => FullscreenActivityPage(""));
    await tester.pumpAndSettle();
    expect(find.text("00:10"), findsOneWidget);

    // Update duration and pump some amount of time passed.
    when(session.duration).thenReturn(Duration(seconds: 20));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text("00:20"), findsOneWidget);
  });
}
