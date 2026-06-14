import 'dart:async';

import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/mocks.mocks.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  late StreamController<SessionEvent> sessionController;

  setUp(() async {
    managers = await StubbedManagers.create();
    sessionController = StreamController<SessionEvent>.broadcast();

    when(
      managers.dataManager.sessionStream,
    ).thenAnswer((_) => sessionController.stream);
    when(
      managers.dataManager.activitiesUpdatedStream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.dataManager.initialActivityListTileModels).thenReturn([]);
    when(
      managers.dataManager.getActivityListModel(
        dateRange: anyNamed("dateRange"),
      ),
    ).thenAnswer((_) => Future.value([]));
    when(
      managers.dataManager.getSummarizedActivities(any),
    ).thenAnswer((_) => Future.value(SummarizedActivityList([], null)));
    when(managers.dataManager.activityCount).thenAnswer((_) async => 0);

    when(
      managers.preferencesManager.homeDateRange,
    ).thenReturn(DateRange(period: DateRange_Period.allDates));
    when(
      managers.preferencesManager.statsDateRange,
    ).thenReturn(DateRange(period: DateRange_Period.allDates));
    when(managers.preferencesManager.statsSelectedActivityIds).thenReturn([]);
    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.hours);

    when(managers.subscriptionManager.isFree).thenReturn(true);
    when(managers.subscriptionManager.isPro).thenReturn(false);
    when(
      managers.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));
    when(
      managers.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(managers.appConfig.appIcon).thenReturn(Icons.add);
    when(managers.appConfig.appName).thenReturn(() => "Activity Log");
    when(managers.ioWrapper.isAndroid).thenReturn(true);
    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(
      managers.liveActivitiesManager.isSupported(),
    ).thenAnswer((_) => Future.value(false));
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

  tearDown(() => sessionController.close());

  testWidgets("Non-ended session event does not show pro page", (tester) async {
    await pumpContext(tester, (_) => const MainPage());
    await tester.pumpAndSettle();

    sessionController.add(
      SessionEvent(SessionEventType.started, MockSession()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ActivityLogProPage), findsNothing);
    verifyNever(managers.dataManager.sessionCount);
  });

  testWidgets(
    "Ended session event for subscribed user does not show pro page",
    (tester) async {
      when(managers.subscriptionManager.isFree).thenReturn(false);

      await pumpContext(tester, (_) => const MainPage());
      await tester.pumpAndSettle();

      sessionController.add(
        SessionEvent(SessionEventType.ended, MockSession()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ActivityLogProPage), findsNothing);
      verifyNever(managers.dataManager.sessionCount);
    },
  );

  testWidgets(
    "Ended session event at non-threshold count does not show pro page",
    (tester) async {
      when(managers.dataManager.sessionCount).thenAnswer((_) async => 7);

      await pumpContext(tester, (_) => const MainPage());
      await tester.pumpAndSettle();

      sessionController.add(
        SessionEvent(SessionEventType.ended, MockSession()),
      );
      await tester.pumpAndSettle();

      verify(managers.dataManager.sessionCount).called(1);
      expect(find.byType(ActivityLogProPage), findsNothing);
    },
  );

  testWidgets("Ended session event at threshold count shows pro page", (
    tester,
  ) async {
    when(managers.dataManager.sessionCount).thenAnswer((_) async => 10);

    await pumpContext(tester, (_) => const MainPage());
    await tester.pumpAndSettle();

    sessionController.add(SessionEvent(SessionEventType.ended, MockSession()));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityLogProPage), findsOneWidget);
  });
}
