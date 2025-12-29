import 'dart:async';
import 'dart:convert';

import 'package:adair_flutter_lib/res/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/live_activities_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mockito/mockito.dart';

import '../../../adair-flutter-lib/test/test_utils/async.dart';
import '../../../adair-flutter-lib/test/test_utils/testable.dart';
import 'mocks/mocks.mocks.dart';
import 'stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  late StreamController<SessionEvent> sessionStreamController;

  late MockLiveActivities liveActivities;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.dataManager.sessionStream,
    ).thenAnswer((_) => sessionStreamController.stream);

    liveActivities = MockLiveActivities();
    when(
      liveActivities.init(
        appGroupId: anyNamed("appGroupId"),
        requireNotificationPermission: anyNamed(
          "requireNotificationPermission",
        ),
      ),
    ).thenAnswer((_) => Future.value());
    when(
      managers.liveActivitiesWrapper.newInstance(),
    ).thenReturn(liveActivities);

    when(
      managers.sharedAppGroupWrapper.getStringList(any),
    ).thenAnswer((_) => Future.value());
    when(
      managers.sharedAppGroupWrapper.setStringList(any, any),
    ).thenAnswer((_) => Future.value(null));

    sessionStreamController = StreamController<SessionEvent>.broadcast();
    LiveActivitiesManager.reset();
  });

  Future<void> initManager({bool forIos = true}) async {
    if (forIos) {
      managers.lib.stubIosDeviceInfo();
    } else {
      managers.lib.stubAndroidDeviceInfo();
    }
    await LiveActivitiesManager.get.init();
  }

  Future<void> emitSessionEvent(SessionEventType type) async {
    expect(sessionStreamController.hasListener, isTrue);

    final streamExpectation = expectLater(
      DataManager.get.sessionStream,
      emits(predicate<SessionEvent>((e) => e.type == type)),
    );
    sessionStreamController.add(SessionEvent(type, SessionBuilder("id").build));

    await streamExpectation;
  }

  Future<void> flushPollingTimer() async {
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(liveActivities.endActivity(any)).thenAnswer((_) => Future.value());
    await emitSessionEvent(.ended);
  }

  test("init exits early when live activities aren't supported", () async {
    when(managers.ioWrapper.isAndroid).thenReturn(false);
    managers.lib.stubIosDeviceInfo(iosVersion: "16");

    await LiveActivitiesManager.get.init();
    verifyNever(managers.liveActivitiesWrapper.newInstance());
  });

  test("init for Android", () async {
    final sharedPrefsAsync = MockSharedPreferencesAsync();
    when(sharedPrefsAsync.getString(any)).thenAnswer((_) => Future.value(null));
    when(
      managers.sharedPreferencesWrapper.sharedPreferencesAsync(
        options: anyNamed("options"),
      ),
    ).thenReturn(sharedPrefsAsync);

    managers.lib.stubAndroidDeviceInfo();

    await LiveActivitiesManager.get.init();
    verify(
      managers.sharedPreferencesWrapper.sharedPreferencesAsync(
        options: anyNamed("options"),
      ),
    ).called(1);
    verifyNever(managers.sharedAppGroupWrapper.setAppGroup(any));
  });

  test("init for iOS", () async {
    when(
      managers.sharedAppGroupWrapper.setAppGroup(any),
    ).thenAnswer((_) => Future.value());
    managers.lib.stubIosDeviceInfo();

    await LiveActivitiesManager.get.init();
    verifyNever(
      managers.sharedPreferencesWrapper.sharedPreferencesAsync(
        options: anyNamed("options"),
      ),
    );
    verify(managers.sharedAppGroupWrapper.setAppGroup(any)).called(1);
  });

  test("isSupported on unsupported Android", () async {
    managers.lib.stubAndroidDeviceInfo(sdkInt: 25);
    await LiveActivitiesManager.get.init();
    verifyNever(managers.liveActivitiesWrapper.newInstance());
  });

  test("isSupported on unsupported iOS", () async {
    managers.lib.stubIosDeviceInfo(iosVersion: "16.0.0");
    await LiveActivitiesManager.get.init();
    verifyNever(managers.liveActivitiesWrapper.newInstance());
  });

  test("On session started exits early for free users", () async {
    when(managers.subscriptionManager.isFree).thenReturn(true);

    await initManager();
    await emitSessionEvent(.started);

    verify(managers.subscriptionManager.isFree).called(1);
    verifyNever(managers.dataManager.activity(any));
  });

  test(
    "On session started exits early if the activity doesn't exist",
    () async {
      when(managers.subscriptionManager.isFree).thenReturn(false);
      when(
        managers.dataManager.activity(any),
      ).thenAnswer((_) => Future.value(null));

      await initManager();
      await emitSessionEvent(.started);

      verify(managers.dataManager.activity(any)).called(1);
      verifyNever(liveActivities.createActivity(any, any));
    },
  );

  testWidgets("On session started with dark theme", (tester) async {
    when(
      liveActivities.createActivity(any, any),
    ).thenAnswer((_) => Future.value(null));
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));

    when(managers.lib.appConfig.themeMode).thenReturn(() => ThemeMode.dark);

    await buildContext(tester);
    await initManager();
    await emitSessionEvent(.started);

    final result = verify(liveActivities.createActivity(any, captureAny));
    result.called(1);
    expect(
      result.captured.first["tint_r"],
      AdairFlutterLibTheme.dark().colorScheme.surface.r,
    );
    expect(
      result.captured.first["tint_g"],
      AdairFlutterLibTheme.dark().colorScheme.surface.g,
    );
    expect(
      result.captured.first["tint_b"],
      AdairFlutterLibTheme.dark().colorScheme.surface.b,
    );

    await flushPollingTimer();
  });

  testWidgets("On session started with light theme", (tester) async {
    when(
      liveActivities.createActivity(any, any),
    ).thenAnswer((_) => Future.value(null));
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));

    when(managers.lib.appConfig.themeMode).thenReturn(() => ThemeMode.light);
    when(managers.lib.appConfig.colorAppTheme).thenReturn(Colors.red);

    await buildContext(tester);
    await initManager();
    await emitSessionEvent(.started);

    final result = verify(liveActivities.createActivity(any, captureAny));
    result.called(1);
    expect(result.captured.first["tint_r"], Colors.red.r);
    expect(result.captured.first["tint_g"], Colors.red.g);
    expect(result.captured.first["tint_b"], Colors.red.b);

    await flushPollingTimer();
  });

  testWidgets(
    "On session started handles exception when live activities are disabled by the user",
    (tester) async {
      when(managers.subscriptionManager.isFree).thenReturn(false);

      when(
        managers.dataManager.activity(any),
      ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));

      // Exception is thrown on iOS when a user denies or disables live
      // activities for the app.
      when(liveActivities.createActivity(any, any)).thenAnswer(
        (_) => throw PlatformException(
          code: "Test",
          details: "User has denied activities",
        ),
      );

      final logs = await capturePrintStatements(() async {
        await buildContext(tester);
        await initManager();
        await emitSessionEvent(.started);
      });
      expect(logs.length, 2);
      expect(logs.last.contains("User has disallowed live activities"), isTrue);
      verifyNever(managers.dataManager.updateActivity(any));

      await flushPollingTimer();
    },
  );

  testWidgets(
    "On session started handles unknown exception when creating a live activity",
    (tester) async {
      when(managers.subscriptionManager.isFree).thenReturn(false);

      when(
        managers.dataManager.activity(any),
      ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));

      when(liveActivities.createActivity(any, any)).thenAnswer(
        (_) => throw PlatformException(code: "Test", details: "Test exception"),
      );

      final logs = await capturePrintStatements(() async {
        await buildContext(tester);
        await initManager();
        await emitSessionEvent(.started);
      });
      expect(logs.length, 3);
      expect(logs[1].contains("Live activity creation"), isTrue);
      verifyNever(managers.dataManager.updateActivity(any));

      await flushPollingTimer();
    },
  );

  testWidgets(
    "On session started exits early if the live activity failed to start",
    (tester) async {
      when(
        liveActivities.createActivity(any, any),
      ).thenAnswer((_) => Future.value(null));
      when(managers.subscriptionManager.isFree).thenReturn(false);
      when(
        managers.dataManager.activity(any),
      ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));

      when(managers.lib.appConfig.themeMode).thenReturn(() => ThemeMode.light);
      when(managers.lib.appConfig.colorAppTheme).thenReturn(Colors.red);

      await buildContext(tester);
      await initManager();
      await emitSessionEvent(.started);
      verifyNever(managers.dataManager.updateActivity(any));

      await flushPollingTimer();
    },
  );

  testWidgets("On session started updates database", (tester) async {
    when(
      liveActivities.createActivity(any, any),
    ).thenAnswer((_) => Future.value("live-activity-id"));
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));

    when(managers.lib.appConfig.themeMode).thenReturn(() => ThemeMode.dark);

    await buildContext(tester);
    await initManager();
    await emitSessionEvent(.started);

    final result = verify(managers.dataManager.updateActivity(captureAny));
    result.called(1);
    expect(
      (result.captured.first as Activity).currentLiveActivityId,
      "live-activity-id",
    );

    await flushPollingTimer();
  });

  test("On session updated exits early if the user is free", () async {
    when(managers.subscriptionManager.isFree).thenReturn(true);
    await initManager();
    await emitSessionEvent(.updated);
    verifyNever(managers.dataManager.currentLiveActivityId(any));
  });

  test(
    "On session updated exits early if there's no associated live activity",
    () async {
      when(managers.subscriptionManager.isFree).thenReturn(false);
      when(
        managers.dataManager.currentLiveActivityId(any),
      ).thenAnswer((_) => Future.value(null));

      await initManager();
      await emitSessionEvent(.updated);
      verify(managers.dataManager.currentLiveActivityId(any)).called(1);
      verifyNever(liveActivities.updateActivity(any, any));
    },
  );

  test("On session updated updates the live activity", () async {
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(
      managers.dataManager.currentLiveActivityId(any),
    ).thenAnswer((_) => Future.value("live-activity-id"));
    when(
      liveActivities.updateActivity(any, any),
    ).thenAnswer((_) => Future.value());

    await initManager();
    await emitSessionEvent(.updated);

    final result = verify(liveActivities.updateActivity(captureAny, any));
    result.called(1);
    expect(result.captured.first, "live-activity-id");
  });

  test("On session ended exits early if the user is free", () async {
    when(managers.subscriptionManager.isFree).thenReturn(true);
    await initManager();

    await emitSessionEvent(.ended);
    verifyNever(liveActivities.endActivity(any));

    await emitSessionEvent(.deleted);
    verifyNever(liveActivities.endActivity(any));
  });

  test("On session ended/deleted ends the live activity", () async {
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(liveActivities.endActivity(any)).thenAnswer((_) => Future.value());

    await initManager();

    await emitSessionEvent(.ended);
    verify(liveActivities.endActivity(any)).called(1);

    await emitSessionEvent(.deleted);
    verify(liveActivities.endActivity(any)).called(1);
  });

  test(
    "Ending the live activity via group data exits early if activity doesn't exist",
    () async {
      when(
        managers.sharedAppGroupWrapper.getStringList("ended_activity_ids"),
      ).thenAnswer(
        (_) => Future.value([
          "live-activity-id:${DateTime.now().millisecondsSinceEpoch}",
        ]),
      );
      when(
        managers.dataManager.activity(any),
      ).thenAnswer((_) => Future.value(null));

      final logs = await capturePrintStatements(
        () async => await initManager(),
      );
      expect(
        logs.first.contains("Activity id not found: live-activity-id"),
        isTrue,
      );
      verifyNever(managers.dataManager.endSession(any, any));
    },
  );

  test(
    "Ending the live activity via group data updates the database",
    () async {
      final activity = ActivityBuilder("Test").build;

      when(
        managers.sharedAppGroupWrapper.getStringList("ended_activity_ids"),
      ).thenAnswer(
        (_) => Future.value([
          "${activity.id}:${DateTime.now().millisecondsSinceEpoch}",
        ]),
      );
      when(
        managers.dataManager.activity(any),
      ).thenAnswer((_) => Future.value(activity));

      await initManager();

      final result = verify(managers.dataManager.endSession(captureAny, any));
      result.called(1);
      expect((result.captured.first as Activity).id, activity.id);

      // Data is cleared.
      verify(
        managers.sharedAppGroupWrapper.setStringList(
          "ended_activity_ids",
          null,
        ),
      ).called(1);
    },
  );

  test(
    "Checking group data exits early if the ID-time pairs is null",
    () async {
      when(
        managers.sharedAppGroupWrapper.getStringList("ended_activity_ids"),
      ).thenAnswer((_) => Future.value(null));

      await initManager();

      verifyNever(
        managers.sharedAppGroupWrapper.setStringList(
          "ended_activity_ids",
          null,
        ),
      );
    },
  );

  test(
    "Checking group data exits early if the ID-time pairs is empty",
    () async {
      when(
        managers.sharedAppGroupWrapper.getStringList("ended_activity_ids"),
      ).thenAnswer((_) => Future.value([]));

      await initManager();

      verifyNever(
        managers.sharedAppGroupWrapper.setStringList(
          "ended_activity_ids",
          null,
        ),
      );
    },
  );

  test("Checking group data throws assertion for invalid pair", () async {
    when(
      managers.sharedAppGroupWrapper.getStringList("ended_activity_ids"),
    ).thenAnswer((_) => Future.value(["bad format"]));
    expect(() async => await initManager(), throwsAssertionError);
  });

  test(
    "Checking group data throws assertion for invalid timestamp value",
    () async {
      when(
        managers.sharedAppGroupWrapper.getStringList("ended_activity_ids"),
      ).thenAnswer((_) => Future.value(["id:not-a-timestamp"]));
      expect(() async => await initManager(), throwsAssertionError);
    },
  );

  test("Android group data checking with empty preferences", () async {
    final sharedPrefsAsync = MockSharedPreferencesAsync();
    when(sharedPrefsAsync.getString(any)).thenAnswer((_) => Future.value(null));
    when(
      managers.sharedPreferencesWrapper.sharedPreferencesAsync(
        options: anyNamed("options"),
      ),
    ).thenReturn(sharedPrefsAsync);

    await initManager(forIos: false);
    verifyNever(sharedPrefsAsync.setString("ended_activity_ids", ""));
  });

  test("Android group data checking ends activity and clears data", () async {
    final activity = ActivityBuilder("Test").build;

    final sharedPrefsAsync = MockSharedPreferencesAsync();
    when(sharedPrefsAsync.getString(any)).thenAnswer(
      (_) => Future.value(
        jsonEncode(["${activity.id}:${DateTime.now().millisecondsSinceEpoch}"]),
      ),
    );
    when(
      managers.sharedPreferencesWrapper.sharedPreferencesAsync(
        options: anyNamed("options"),
      ),
    ).thenReturn(sharedPrefsAsync);

    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(activity));
    when(
      managers.dataManager.endSession(any, any),
    ).thenAnswer((_) => Future.value());

    await initManager(forIos: false);
    verify(sharedPrefsAsync.setString("ended_activity_ids", "")).called(1);

    final result = verify(managers.dataManager.endSession(captureAny, any));
    result.called(1);
    expect((result.captured.first as Activity).id, activity.id);
  });

  test("iOS group data checking handles native logs", () async {
    when(
      managers.sharedAppGroupWrapper.getStringList("logs"),
    ).thenAnswer((_) => Future.value(["Log 1", "Log 2"]));

    final logs = await capturePrintStatements(() async => await initManager());
    expect(logs.length, 2);
    expect(logs.first.contains("[iOS] Log 1"), isTrue);
    expect(logs.last.contains("[iOS] Log 2"), isTrue);
  });

  testWidgets("Group data is polled every second", (tester) async {
    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));
    when(
      liveActivities.createActivity(any, any),
    ).thenAnswer((_) => Future.value(null));

    when(managers.lib.appConfig.themeMode).thenReturn(() => ThemeMode.dark);

    // Start polling.
    await buildContext(tester);
    await initManager();
    await emitSessionEvent(.started);
    verify(managers.sharedAppGroupWrapper.getStringList("logs")).called(1);

    // Update group data such that the next poll ends an activity.
    when(
      managers.sharedAppGroupWrapper.getStringList("logs"),
    ).thenAnswer((_) => Future.value(null));

    // Trigger polling.
    await tester.pump(const Duration(seconds: 1));
    verify(managers.sharedAppGroupWrapper.getStringList("logs")).called(1);

    await flushPollingTimer();
  });
}
