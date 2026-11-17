import 'dart:io';

import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.appConfig.proLogo).thenReturn("assets/app.svg");
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

  Future<void> scrollToAndTap(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(find.text(text), 100);
    await ensureVisibleAndSettle(tester, find.text(text));
    await tapAndSettle(tester, find.text(text));
  }

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

  testWidgets("Rate launches the Play Store on Android", (tester) async {
    managers.lib.stubAndroidDeviceInfo();
    when(
      managers.lib.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) async => true);
    when(
      managers.lib.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) async => true);

    await pumpContext(tester, (_) => SettingsPage());
    await scrollToAndTap(tester, "Rate Activity Log");

    verify(
      managers.lib.urlLauncherWrapper.launch(
        "market://details?id=com.cohenadair.activitylog",
      ),
    ).called(1);
  });

  testWidgets("Rate launches the App Store on iOS", (tester) async {
    managers.lib.stubIosDeviceInfo();
    when(
      managers.lib.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) async => true);
    when(
      managers.lib.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) async => true);

    await pumpContext(tester, (_) => SettingsPage());
    await scrollToAndTap(tester, "Rate Activity Log");

    verify(
      managers.lib.urlLauncherWrapper.launch(
        "itms-apps://itunes.apple.com/app/id1458926666?action=write-review",
      ),
    ).called(1);
  });

  testWidgets("Rate shows Android error when store can't launch", (
    tester,
  ) async {
    managers.lib.stubAndroidDeviceInfo();
    when(
      managers.lib.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) async => false);

    var context = await pumpContext(tester, (_) => SettingsPage());
    await scrollToAndTap(tester, "Rate Activity Log");

    expect(
      find.text(Strings.of(context).settingsPageAndroidErrorRateMessage),
      findsOneWidget,
    );
    verifyNever(managers.lib.urlLauncherWrapper.launch(any));
  });

  testWidgets("Rate shows iOS error when store can't launch", (tester) async {
    managers.lib.stubIosDeviceInfo();
    when(
      managers.lib.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) async => false);

    var context = await pumpContext(tester, (_) => SettingsPage());
    await scrollToAndTap(tester, "Rate Activity Log");

    expect(
      find.text(Strings.of(context).settingsPageIosErrorRateMessage),
      findsOneWidget,
    );
    verifyNever(managers.lib.urlLauncherWrapper.launch(any));
  });

  testWidgets("Privacy Policy launches in an external app", (tester) async {
    managers.lib.stubIosDeviceInfo();
    when(
      managers.lib.urlLauncherWrapper.launch(any, mode: anyNamed("mode")),
    ).thenAnswer((_) async => true);

    await pumpContext(tester, (_) => SettingsPage());
    await scrollToAndTap(tester, "Privacy Policy");

    verify(
      managers.lib.urlLauncherWrapper.launch(
        "https://activitylog.ca/privacy-policy.html",
        mode: LaunchMode.externalApplication,
      ),
    ).called(1);
  });
}
