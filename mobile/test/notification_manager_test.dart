import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mockito/mockito.dart';

import '../../../adair-flutter-lib/test/test_utils/testable.dart';
import 'stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.lib.permissionHandlerWrapper.isNotificationDenied,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isNotificationGranted,
    ).thenAnswer((_) => Future.value(true));

    NotificationManager.reset();
  });

  testWidgets("Assertion thrown if permission is requested for non-Android", (
    tester,
  ) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
    expect(
      () async => await NotificationManager.get.requestPermission(
        await buildContext(tester),
      ),
      throwsAssertionError,
    );
  });

  testWidgets("Assertion thrown if permission is requested for non-Android", (
    tester,
  ) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
    expect(
      await NotificationManager.get.requestPermission(
        await buildContext(tester),
      ),
      isTrue,
    );
  });
}
