import 'dart:io';

import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    when(managers.subscriptionManager.isFree).thenReturn(true);
    when(
      managers.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.ioWrapper.isAndroid).thenReturn(true);

    when(
      managers.liveActivitiesManager.isSupported(),
    ).thenAnswer((_) => Future.value(true));

    when(managers.lib.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          appName: "Activity Log",
          packageName: "com.test.activitylog",
          version: "1.0.0",
          buildNumber: "1",
        ),
      ),
    );
  });

  testWidgets("ProPage is shown", (tester) async {
    managers.lib.stubIosDeviceInfo();
    await tester.pumpWidget(Testable((_) => SettingsPage()));

    await tapAndSettle(tester, find.text("Activity Log Pro"));
    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("Export XLSX tap shows pro page when subscription is free", (
    tester,
  ) async {
    managers.lib.stubIosDeviceInfo();
    when(managers.subscriptionManager.isPro).thenReturn(false);
    when(managers.subscriptionManager.isFree).thenReturn(true);

    await tester.pumpWidget(Testable((_) => SettingsPage()));
    await ensureVisibleAndSettle(tester, find.text("Excel Spreadsheet"));
    await tapAndSettle(tester, find.text("Excel Spreadsheet"));

    expect(find.byType(ActivityLogProPage), findsOneWidget);
  });

  testWidgets("Export XLSX tap does not show pro page when subscribed", (
    tester,
  ) async {
    managers.lib.stubIosDeviceInfo();
    when(managers.subscriptionManager.isPro).thenReturn(true);
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(
      managers.lib.pathProviderWrapper.temporaryPath,
    ).thenAnswer((_) async => Directory.systemTemp.path);
    when(managers.dataManager.activities).thenAnswer((_) async => []);

    await tester.pumpWidget(Testable((_) => SettingsPage()));
    await ensureVisibleAndSettle(tester, find.text("Excel Spreadsheet"));
    await tester.tap(find.text("Excel Spreadsheet"));
    await tester.pump();

    expect(find.byType(ActivityLogProPage), findsNothing);
  });
}
