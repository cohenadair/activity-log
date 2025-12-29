import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.subscriptionManager.isPro).thenReturn(true);
    when(
      managers.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));
  });

  testWidgets("Android live activities supported", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(true);
    when(
      managers.liveActivitiesManager.isSupported(),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable((_) => ActivityLogProPage()));
    await tester.pumpAndSettle();

    expect(
      find.text("Ongoing notifications of in-progress sessions"),
      findsOneWidget,
    );
    expect(findFirst<ProPage>(tester).features.last.subtext, isNull);
  });

  testWidgets("Android live activities not supported", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(true);
    when(
      managers.liveActivitiesManager.isSupported(),
    ).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(Testable((_) => ActivityLogProPage()));
    await tester.pumpAndSettle();

    expect(find.text("Requires Android 8+"), findsOneWidget);
  });

  testWidgets("iOS live activities Dynamic Island supported", (tester) async {
    managers.lib.stubIosDeviceInfo(machine: "iPhone18,3");
    when(managers.ioWrapper.isAndroid).thenReturn(false);
    when(
      managers.liveActivitiesManager.isSupported(),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable((_) => ActivityLogProPage()));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Live Activity and Dynamic Island support for in-progress sessions",
      ),
      findsOneWidget,
    );
    expect(findFirst<ProPage>(tester).features.last.subtext, isNull);
  });

  testWidgets("iOS live activities Dynamic Island not supported", (
    tester,
  ) async {
    managers.lib.stubIosDeviceInfo(machine: "No Dynamic Island");
    when(managers.ioWrapper.isAndroid).thenReturn(false);
    when(
      managers.liveActivitiesManager.isSupported(),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable((_) => ActivityLogProPage()));
    await tester.pumpAndSettle();

    expect(
      find.text("Live Activities for in-progress sessions"),
      findsOneWidget,
    );
    expect(findFirst<ProPage>(tester).features.last.subtext, isNull);
  });

  testWidgets("iOS live activities not supported", (tester) async {
    managers.lib.stubIosDeviceInfo();
    when(managers.ioWrapper.isAndroid).thenReturn(false);
    when(
      managers.liveActivitiesManager.isSupported(),
    ).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(Testable((_) => ActivityLogProPage()));
    await tester.pumpAndSettle();

    expect(find.text("Requires iOS 17+"), findsOneWidget);
  });
}
