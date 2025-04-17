import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../stubbed_managers.dart';
import '../test_utils.dart';

import '../../../../adair-flutter-lib/test/test_utils/widget.dart';

void main() {
  late StubbedManagers managers;

  late MockAppManager appManager;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.appConfig.appIcon).thenReturn(Icons.add);
    when(managers.appConfig.appName).thenReturn((_) => "Activity Log");

    when(managers.preferencesManager.largestDurationUnit)
        .thenReturn(AppDurationUnit.days);
    when(managers.preferencesManager.homeDateRange)
        .thenReturn(DisplayDateRange.allDates);

    when(managers.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
    when(managers.subscriptionManager.isPro).thenReturn(false);

    appManager = MockAppManager();
    when(appManager.preferencesManager).thenReturn(managers.preferencesManager);
  });

  testWidgets("ProPage is shown", (tester) async {
    await tester.pumpWidget(Testable((_) => SettingsPage(appManager)));

    await tapAndSettle(tester, find.text("Activity Log Pro"));
    expect(find.byType(ProPage), findsOneWidget);
  });
}
