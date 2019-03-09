import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/text.dart';
import 'package:quiver/time.dart';

import '../test_utils.dart';

void main() {
  group("CombinedText", () {
    testWidgets("Normal case", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(CombinedText([
        "Test", "Test1", "Test2", "Test3",
      ], separator: ", ")));
      expect(find.text("Test, Test1, Test2, Test3"), findsOneWidget);
    });

    testWidgets("Only one entry", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(CombinedText(["Test"], separator: ",")));
      expect(find.text("Test"), findsOneWidget);
    });

    testWidgets("No separator", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(CombinedText([
        "Test", "Test1", "Test2", "Test3",
      ])));
      expect(find.text("TestTest1Test2Test3"), findsOneWidget);
    });
  });

  group("TotalDurationText", () {
    testWidgets("Empty", (WidgetTester tester) async {
      List<Duration> durations = [];

      await tester.pumpWidget(Testable(TotalDurationText(durations)));
      expect(find.text("0d 0h 0m 0s"), findsOneWidget);

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
      )));
      expect(find.text(""), findsOneWidget);
    });

    testWidgets("All", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(days: 2),
        Duration(hours: 5),
        Duration(minutes: 45),
        Duration(seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(durations)));
      expect(find.text("2d 5h 45m 30s"), findsOneWidget);

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
      )));
      expect(find.text("2d 5h 45m 30s"), findsOneWidget);
    });

    testWidgets("Days only", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(days: 2),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(durations)));
      expect(find.text("2d 0h 0m 0s"), findsOneWidget);

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
      )));
      expect(find.text("2d"), findsOneWidget);
    });

    testWidgets("Hours only", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(hours: 10),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(durations)));
      expect(find.text("0d 10h 0m 0s"), findsOneWidget);

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
      )));
      expect(find.text("10h"), findsOneWidget);
    });

    testWidgets("Minutes only", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(minutes: 20),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(durations)));
      expect(find.text("0d 0h 20m 0s"), findsOneWidget);

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
      )));
      expect(find.text("20m"), findsOneWidget);
    });

    testWidgets("Seconds only", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(seconds: 50),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(durations)));
      expect(find.text("0d 0h 0m 50s"), findsOneWidget);

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
      )));
      expect(find.text("50s"), findsOneWidget);
    });

    testWidgets("Excluding days", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(days: 2),
        Duration(hours: 5),
        Duration(minutes: 45),
        Duration(seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        includesDays: false,
      )));
      expect(find.text("53h 45m 30s"), findsOneWidget);
    });

    testWidgets("Excluding hours", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(days: 2),
        Duration(hours: 5),
        Duration(minutes: 45),
        Duration(seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        includesDays: false,
        includesHours: false,
      )));
      expect(find.text("3225m 30s"), findsOneWidget);
    });

    testWidgets("Excluding minutes", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(days: 2),
        Duration(hours: 5),
        Duration(minutes: 45),
        Duration(seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        includesDays: false,
        includesHours: false,
        includesMinutes: false,
      )));
      expect(find.text("193530s"), findsOneWidget);
    });

    testWidgets("Excluding all", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(days: 2),
        Duration(hours: 5),
        Duration(minutes: 45),
        Duration(seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        includesDays: false,
        includesHours: false,
        includesMinutes: false,
        includesSeconds: false,
      )));
      expect(find.text(""), findsOneWidget);
    });

    testWidgets("Show highest two only", (WidgetTester tester) async {
      List<Duration> durations = [
        Duration(days: 2, hours: 5, minutes: 45, seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        showHighestTwoOnly: true,
      )));
      expect(find.text("2d 5h"), findsOneWidget);

      durations = [
        Duration(hours: 5, minutes: 45, seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
        showHighestTwoOnly: true,
      )));
      expect(find.text("5h 45m"), findsOneWidget);

      durations = [
        Duration(minutes: 45, seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
        showHighestTwoOnly: true,
      )));
      expect(find.text("45m 30s"), findsOneWidget);

      durations = [
        Duration(seconds: 30),
      ];

      await tester.pumpWidget(Testable(TotalDurationText(
        durations,
        condensed: true,
        showHighestTwoOnly: true,
      )));
      expect(find.text("30s"), findsOneWidget);
    });
  });
  
  group("DateDurationText", () {
    final DateTime today = DateTime(2019, 1, 15, 10, 5, 0);
    final Clock clock = Clock.fixed(today);

    testWidgets("Today", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        DateDurationText(today.add(anHour), Duration(), clock: clock)
      ));
      expect(find.text("Today (0m)"), findsOneWidget);
    });

    testWidgets("Yesterday", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        DateDurationText(today.subtract(aDay), Duration(), clock: clock)
      ));
      expect(find.text("Yesterday (0m)"), findsOneWidget);
    });

    testWidgets("Within a week", (WidgetTester tester) async {
      // 2 days
      await tester.pumpWidget(Testable(
        DateDurationText(today.subtract(aDay * 2), Duration(), clock: clock)
      ));
      expect(find.text("Sunday (0m)"), findsOneWidget);

      // 7 days
      await tester.pumpWidget(Testable(
        DateDurationText(today.subtract(aDay * 7), Duration(), clock: clock)
      ));
      expect(find.text("Tuesday (0m)"), findsOneWidget);
    });

    testWidgets("Same year", (WidgetTester tester) async {
      // 8 days
      await tester.pumpWidget(Testable(
        DateDurationText(today.subtract(aDay * 8), Duration(), clock: clock)
      ));
      expect(find.text("Jan. 7 (0m)"), findsOneWidget);

      // 10 days
      await tester.pumpWidget(Testable(
        DateDurationText(today.subtract(aDay * 10), Duration(), clock: clock)
      ));
      expect(find.text("Jan. 5 (0m)"), findsOneWidget);
    });

    testWidgets("Different year", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        DateDurationText(today.subtract(aDay * 30), Duration(), clock: clock)
      ));
      expect(find.text("Dec. 16, 2018 (0m)"), findsOneWidget);
    });

    testWidgets("No days", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        DateDurationText(today, Duration(days: 1, hours: 3), clock: clock)
      ));
      expect(find.text("Today (27h 0m)"), findsOneWidget);
    });

    testWidgets("No seconds", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        DateDurationText(today, Duration(hours: 5, seconds: 10), clock: clock)
      ));
      expect(find.text("Today (5h 0m)"), findsOneWidget);
    });

    testWidgets("Only minutes", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        DateDurationText(today, Duration(minutes: 30), clock: clock)
      ));
      expect(find.text("Today (30m)"), findsOneWidget);
    });

    testWidgets("Hours and minutes", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        DateDurationText(today, Duration(hours: 1, minutes: 3), clock: clock)
      ));
      expect(find.text("Today (1h 3m)"), findsOneWidget);
    });
  });

  group("RunningDurationText", () {
    testWidgets("All", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        RunningDurationText(Duration(hours: 5, minutes: 6, seconds: 7))
      ));
      expect(find.text("05:06:07"), findsOneWidget);
    });

    testWidgets("Hours only", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        RunningDurationText(Duration(hours: 5))
      ));
      expect(find.text("05:00:00"), findsOneWidget);
    });

    testWidgets("Minutes only", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        RunningDurationText(Duration(minutes: 30))
      ));
      expect(find.text("00:30:00"), findsOneWidget);
    });

    testWidgets("Seconds only", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        RunningDurationText(Duration(seconds: 7))
      ));
      expect(find.text("00:00:07"), findsOneWidget);
    });
  });

  group("TimeText", () {
    testWidgets("12 hour", (WidgetTester tester) async {
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: false),
        child: Testable(TimeText(TimeOfDay(hour: 15, minute: 30))),
      ));
      expect(find.text("3:30 PM"), findsOneWidget);

      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: false),
        child: Testable(TimeText(TimeOfDay(hour: 4, minute: 30))),
      ));
      expect(find.text("4:30 AM"), findsOneWidget);
    });

    testWidgets("24 hour", (WidgetTester tester) async {
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: true),
        child: Testable(TimeText(TimeOfDay(hour: 15, minute: 30))),
      ));
      expect(find.text("15:30"), findsOneWidget);

      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: true),
        child: Testable(TimeText(TimeOfDay(hour: 4, minute: 30))),
      ));
      expect(find.text("04:30"), findsOneWidget);
    });
  });
}