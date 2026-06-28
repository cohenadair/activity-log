import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/future_listener.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("Stream error does not propagate to widget tree", (tester) async {
    // Verifies that the onError handler in FutureListener swallows stream
    // errors rather than letting them bubble up to the test framework.
    final controller = StreamController<void>();

    await pumpContext(
      tester,
      (_) => FutureListener.single(
        getFutureCallback: () => Future.value("data"),
        stream: controller.stream,
        builder: (context, value) => Text(value ?? ""),
      ),
    );
    await tester.pumpAndSettle();

    controller.addError(Exception("test error"));
    await tester.pump();

    expect(tester.takeException(), isNull);

    await controller.close();
  });
}
