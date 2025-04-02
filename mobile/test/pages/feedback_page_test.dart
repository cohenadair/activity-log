import 'dart:io';

import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../mocks/mocks.mocks.dart';
import '../stubbed_managers.dart';
import '../test_utils.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';

void main() {
  late StubbedManagers managers;

  late MockAppManager appManager;

  late MockPreferencesManager preferencesManager;
  late MockDeviceInfoWrapper deviceInfoWrapper;
  late MockPackageInfoWrapper packageInfoWrapper;
  late MockHttpWrapper httpWrapper;

  setUp(() async {
    managers = await StubbedManagers.create();

    preferencesManager = MockPreferencesManager();
    when(preferencesManager.userName).thenReturn("Cohen");
    when(preferencesManager.userEmail).thenReturn("test@test.com");
    when(preferencesManager.setUserInfo(any, any)).thenAnswer((_) {});

    when(managers.propertiesManager.supportEmail)
        .thenReturn("support@test.com");
    when(managers.propertiesManager.clientSenderEmail)
        .thenReturn("sender@test.com");
    when(managers.propertiesManager.feedbackTemplate).thenReturn("""
      App version: %s
      OS version: %s
      Device: %s
      Device ID: %s
      
      Name: %s
      Email: %s
      Message: %s
    """);
    when(managers.propertiesManager.sendGridApiKey).thenReturn("API KEY");

    deviceInfoWrapper = MockDeviceInfoWrapper();

    when(
      managers.ioWrapper.lookup(any),
    ).thenAnswer((_) => Future.value([InternetAddress("192.168.2.211")]));
    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.ioWrapper.isAndroid).thenReturn(false);

    packageInfoWrapper = MockPackageInfoWrapper();
    when(packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          appName: "Test App",
          packageName: "app.test.com",
          version: "1",
          buildNumber: "1000",
        ),
      ),
    );

    httpWrapper = MockHttpWrapper();
    when(
      httpWrapper.post(
        any,
        headers: anyNamed("headers"),
        body: anyNamed("body"),
      ),
    ).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 50),
        () => Response("", HttpStatus.accepted),
      ),
    );

    appManager = MockAppManager();
    when(appManager.preferencesManager).thenReturn(preferencesManager);
    when(appManager.deviceInfoWrapper).thenReturn(deviceInfoWrapper);
    when(appManager.packageInfoWrapper).thenReturn(packageInfoWrapper);
    when(appManager.httpWrapper).thenReturn(httpWrapper);
  });

  testWidgets("Text fields are initially empty", (tester) async {
    when(preferencesManager.userName).thenReturn(null);
    when(preferencesManager.userEmail).thenReturn(null);

    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));

    expect(findFirstWithText<TextField>(tester, "Name").controller?.text, "");
    expect(findFirstWithText<TextField>(tester, "Name").autofocus, isTrue);
    expect(
      findFirstWithText<TextFormField>(tester, "Email").controller?.text,
      "",
    );
    expect(findFirstWithText<TextField>(tester, "Message").autofocus, isFalse);
  });

  testWidgets("Text fields are initially set from preferences", (tester) async {
    when(preferencesManager.userName).thenReturn("User Name");
    when(preferencesManager.userEmail).thenReturn("useremail@test.com");

    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));

    expect(
      findFirstWithText<TextFormField>(tester, "Name").controller?.text,
      "User Name",
    );
    expect(
      findFirstWithText<TextFormField>(tester, "Email").controller?.text,
      "useremail@test.com",
    );
    expect(findFirstWithText<TextField>(tester, "Message").autofocus, isTrue);
  });

  testWidgets("Email field is validated", (tester) async {
    when(preferencesManager.userName).thenReturn(null);
    when(preferencesManager.userEmail).thenReturn(null);

    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));

    // Email and message fields are both required.
    expect(find.text("Required"), findsNWidgets(2));

    await enterTextFieldAndSettle(tester, "Email", "not-a-real-email");
    expect(find.text("Invalid email format"), findsOneWidget);

    await enterTextFieldAndSettle(tester, "Email", "not-a-real-email@test.com");
    expect(find.text("Invalid email format"), findsNothing);
    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("Send button is shown when not sending", (tester) async {
    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));
    expect(find.text("SEND"), findsOneWidget);
  });

  testWidgets("Send button shows validation error SnackBar", (tester) async {
    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));
    await tapAndSettle(tester, find.text("SEND"));
    expect(
      find.text("Please fix all form errors before sending your feedback."),
      findsOneWidget,
    );
  });

  testWidgets("No network shows connection error SnackBar", (tester) async {
    when(managers.ioWrapper.lookup(any)).thenAnswer((_) => Future.value([]));

    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));
    await enterTextFieldAndSettle(tester, "Message", "Test");
    await tapAndSettle(tester, find.text("SEND"));

    expect(
      find.text(
        "No internet connection. Please check your connection and try again.",
      ),
      findsOneWidget,
    );
  });

  testWidgets("iOS data is valid", (tester) async {
    when(managers.ioWrapper.isIOS).thenReturn(true);
    when(deviceInfoWrapper.iosInfo).thenAnswer(
      (_) => Future.value(
        IosDeviceInfo.fromMap({
          "name": "iOS Device Info",
          "systemName": "iOS System",
          "systemVersion": "1234",
          "model": "iPhone",
          "modelName": "14 Pro",
          "localizedModel": "iPhone",
          "identifierForVendor": "Vendor ID",
          "isPhysicalDevice": true,
          "isiOSAppOnMac": false,
          "utsname": {
            "sysname": "Sys name",
            "nodename": "Node name",
            "release": "Release",
            "version": "Version",
            "machine": "iPhone Name",
          },
        }),
      ),
    );

    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));
    await enterTextFieldAndSettle(tester, "Message", "Test");
    await tapAndSettle(tester, find.text("SEND"));

    var result = verify(
      httpWrapper.post(
        any,
        headers: anyNamed("headers"),
        body: captureAnyNamed("body"),
      ),
    );
    result.called(1);

    String content = result.captured.first;
    expect(content.contains("iOS System"), isTrue);
    expect(content.contains("1234"), isTrue);
    expect(content.contains("iPhone Name"), isTrue);
    expect(content.contains("Vendor ID"), isTrue);
  });

  testWidgets("Android data is valid", (tester) async {
    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.ioWrapper.isAndroid).thenReturn(true);

    var buildVersion = MockAndroidBuildVersion();
    when(buildVersion.sdkInt).thenReturn(33);

    var deviceInfo = MockAndroidDeviceInfo();
    when(deviceInfo.version).thenReturn(buildVersion);
    when(deviceInfo.model).thenReturn("Pixel XL");
    when(deviceInfo.id).thenReturn("ABCD1234");

    when(
      deviceInfoWrapper.androidInfo,
    ).thenAnswer((_) => Future.value(deviceInfo));

    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));
    await enterTextFieldAndSettle(tester, "Message", "Test");
    await tapAndSettle(tester, find.text("SEND"));

    var result = verify(
      httpWrapper.post(
        any,
        headers: anyNamed("headers"),
        body: captureAnyNamed("body"),
      ),
    );
    result.called(1);

    String content = result.captured.first;
    expect(content.contains("ABCD1234"), isTrue);
    expect(content.contains("Pixel XL"), isTrue);
    expect(content.contains("Android (33)"), isTrue);
  });

  testWidgets("HTTP error shows error text", (tester) async {
    when(
      httpWrapper.post(
        any,
        headers: anyNamed("headers"),
        body: anyNamed("body"),
      ),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.badGateway)));

    when(managers.ioWrapper.isIOS).thenReturn(true);
    when(deviceInfoWrapper.iosInfo).thenAnswer(
      (_) => Future.value(
        IosDeviceInfo.fromMap({
          "name": "iOS Device Info",
          "systemName": "iOS System",
          "systemVersion": "1234",
          "model": "iPhone",
          "modelName": "14 Pro",
          "localizedModel": "iPhone",
          "identifierForVendor": "Vendor ID",
          "isPhysicalDevice": true,
          "isiOSAppOnMac": false,
          "utsname": {
            "sysname": "Sys name",
            "nodename": "Node name",
            "release": "Release",
            "version": "Version",
            "machine": "iPhone Name",
          },
        }),
      ),
    );

    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));
    await enterTextFieldAndSettle(tester, "Message", "Test");
    await tapAndSettle(tester, find.text("SEND"));

    expect(
      find.text(
        "Error sending feedback. Please try again later, or email support@test.com directly.",
      ),
      findsOneWidget,
    );
  });

  testWidgets("Successful send", (tester) async {
    when(preferencesManager.userName).thenReturn("User Name");
    when(preferencesManager.userEmail).thenReturn("useremail@test.com");
    when(
      managers.ioWrapper.lookup(any),
    ).thenAnswer((_) => Future.value([InternetAddress("192.168.2.211")]));
    when(managers.ioWrapper.isIOS).thenReturn(true);
    when(packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          appName: "Test App",
          packageName: "app.test.com",
          version: "1",
          buildNumber: "1000",
        ),
      ),
    );
    when(deviceInfoWrapper.iosInfo).thenAnswer(
      (_) => Future.value(
        IosDeviceInfo.fromMap({
          "name": "iOS Device Info",
          "systemName": "iOS System",
          "systemVersion": "1234",
          "model": "iPhone",
          "modelName": "14 Pro",
          "localizedModel": "iPhone",
          "identifierForVendor": "Vendor ID",
          "isPhysicalDevice": true,
          "isiOSAppOnMac": false,
          "utsname": {
            "sysname": "Sys name",
            "nodename": "Node name",
            "release": "Release",
            "version": "Version",
            "machine": "iPhone Name",
          },
        }),
      ),
    );

    await tester.pumpWidget(Testable((_) => FeedbackPage(appManager)));
    await enterTextFieldAndSettle(tester, "Message", "Test");

    // Send the message and verify loading indicator.
    await tester.tap(find.text("SEND"));
    await tester.pump();
    expect(find.byType(Loading), findsOneWidget);
    expect(find.text("SEND"), findsNothing);

    // Finish sending, verify ending state.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.byType(Loading), findsNothing);
    expect(find.text("SEND"), findsOneWidget);
    verify(
      preferencesManager.setUserInfo("User Name", "useremail@test.com"),
    ).called(1);

    expect(
      find.text(
        "Message successfully sent. Please allow 1-2 business days for a reply.",
      ),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text("OK"));
    expect(find.byType(FeedbackPage), findsNothing);
  });
}
