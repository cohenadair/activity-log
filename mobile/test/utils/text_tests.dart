import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/widgets/text.dart';

import '../test_utils.dart';

void main() {
  group("TotalDurationText", () {
    Session _buildSession(int start, int end) {
      return (SessionBuilder("")
        ..startTimestamp = start
        ..endTimestamp = end)
          .build;
    }

    testWidgets("Test total duration empty", (WidgetTester tester) async {
      List<Session> sessions = [];
      await tester.pumpWidget(Testable(TotalDurationText(sessions)));
      expect(find.text("0d 0h 0m 0s"), findsOneWidget);
    });

    testWidgets("Test total duration all", (WidgetTester tester) async {
      List<Session> sessions = [
        _buildSession(0, Duration.millisecondsPerDay * 2),
        _buildSession(0, Duration.millisecondsPerHour * 5),
        _buildSession(0, Duration.millisecondsPerMinute * 45),
        _buildSession(0, Duration.millisecondsPerSecond * 30),
      ];
      await tester.pumpWidget(Testable(TotalDurationText(sessions)));
      expect(find.text("2d 5h 45m 30s"), findsOneWidget);
    });

    testWidgets("Test total duration days only", (WidgetTester tester) async {
      List<Session> sessions = [
        _buildSession(0, Duration.millisecondsPerDay * 2),
      ];
      await tester.pumpWidget(Testable(TotalDurationText(sessions)));
      expect(find.text("2d 0h 0m 0s"), findsOneWidget);
    });

    testWidgets("Test total duration hours only", (WidgetTester tester) async {
      List<Session> sessions = [
        _buildSession(0, Duration.millisecondsPerHour * 10),
      ];
      await tester.pumpWidget(Testable(TotalDurationText(sessions)));
      expect(find.text("0d 10h 0m 0s"), findsOneWidget);
    });

    testWidgets("Test total duration minutes only", (WidgetTester tester) async {
      List<Session> sessions = [
        _buildSession(0, Duration.millisecondsPerMinute * 20),
      ];
      await tester.pumpWidget(Testable(TotalDurationText(sessions)));
      expect(find.text("0d 0h 20m 0s"), findsOneWidget);
    });

    testWidgets("Test total duration seconds only", (WidgetTester tester) async {
      List<Session> sessions = [
        _buildSession(0, Duration.millisecondsPerSecond * 50),
      ];
      await tester.pumpWidget(Testable(TotalDurationText(sessions)));
      expect(find.text("0d 0h 0m 50s"), findsOneWidget);
    });
  });
}