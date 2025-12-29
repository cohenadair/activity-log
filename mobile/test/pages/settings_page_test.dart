import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.appConfig.appIcon).thenReturn(Icons.add);
    when(managers.appConfig.appName).thenReturn(() => "Activity Log");

    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.days);
    when(
      managers.preferencesManager.homeDateRange,
    ).thenReturn(DateRange(period: DateRange_Period.allDates));

    when(
      managers.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));
    when(managers.subscriptionManager.isPro).thenReturn(false);

    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.ioWrapper.isAndroid).thenReturn(true);

    when(
      managers.liveActivitiesManager.isSupported(),
    ).thenAnswer((_) => Future.value(true));
  });

  testWidgets("ProPage is shown", (tester) async {
    managers.lib.stubIosDeviceInfo();
    await tester.pumpWidget(Testable((_) => SettingsPage()));

    await tapAndSettle(tester, find.text("Activity Log Pro"));
    expect(find.byType(ProPage), findsOneWidget);
  });
}
