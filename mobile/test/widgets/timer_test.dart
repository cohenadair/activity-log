import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/timer.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("updatesWidget null always calls setState", (tester) async {
    var buildCount = 0;

    await pumpContext(
      tester,
      (_) => Timer(
        durationMillis: 100,
        childBuilder: () {
          buildCount++;
          return const Text("tick");
        },
      ),
    );

    final initialCount = buildCount;
    await tester.pump(const Duration(milliseconds: 150));
    expect(buildCount, greaterThan(initialCount));
  });

  testWidgets("updatesWidget returning true calls setState", (tester) async {
    var buildCount = 0;

    await pumpContext(
      tester,
      (_) => Timer(
        durationMillis: 100,
        updatesWidget: () => true,
        childBuilder: () {
          buildCount++;
          return const Text("tick");
        },
      ),
    );

    final initialCount = buildCount;
    await tester.pump(const Duration(milliseconds: 150));
    expect(buildCount, greaterThan(initialCount));
  });

  testWidgets("updatesWidget returning false does not call setState", (
    tester,
  ) async {
    var buildCount = 0;

    await pumpContext(
      tester,
      (_) => Timer(
        durationMillis: 100,
        updatesWidget: () => false,
        childBuilder: () {
          buildCount++;
          return const Text("tick");
        },
      ),
    );

    final initialCount = buildCount;
    await tester.pump(const Duration(milliseconds: 150));
    expect(buildCount, initialCount);
  });
}
