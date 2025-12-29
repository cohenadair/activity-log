import 'package:mobile/database/data_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/live_activities_manager.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:mobile/wrappers/live_activities_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/shared_preference_app_group_wrapper.dart';
import 'package:mobile/wrappers/shared_preferences_wrapper.dart';
import 'package:mobile/wrappers/wakelock_wrapper.dart';
import 'package:mockito/mockito.dart';

import '../../../adair-flutter-lib/test/mocks/mocks.mocks.dart';
import '../../../adair-flutter-lib/test/test_utils/stubbed_managers.dart' as s;
import '../../../adair-flutter-lib/test/test_utils/testable.dart';
import 'mocks/mocks.mocks.dart';

class StubbedManagers {
  late final s.StubbedManagers lib;

  late final MockDataManager dataManager;
  late final MockPreferencesManager preferencesManager;
  late final MockPackageInfoWrapper packageInfoWrapper;
  late final MockHttpWrapper httpWrapper;
  late final MockWakelockWrapper wakelockWrapper;
  late final MockLiveActivitiesManager liveActivitiesManager;
  late final MockLiveActivitiesWrapper liveActivitiesWrapper;
  late final MockNotificationManager notificationManager;
  late final MockSharedPreferencesWrapper sharedPreferencesWrapper;
  late final MockSharedPreferenceAppGroupWrapper sharedAppGroupWrapper;

  static Future<StubbedManagers> create() async =>
      StubbedManagers._(await s.StubbedManagers.create());

  // TODO: Remove these wrappers and just expose `lib` as a public field.
  MockAppConfig get appConfig => lib.appConfig;

  MockIoWrapper get ioWrapper => lib.ioWrapper;

  MockPropertiesManager get propertiesManager => lib.propertiesManager;

  MockSubscriptionManager get subscriptionManager => lib.subscriptionManager;

  MockTimeManager get timeManager => lib.timeManager;

  StubbedManagers._(this.lib) {
    dataManager = MockDataManager();
    DataManager.set(dataManager);

    preferencesManager = MockPreferencesManager();
    when(
      preferencesManager.largestDurationUnitStream,
    ).thenAnswer((_) => Stream.empty());
    when(
      preferencesManager.homeDateRangeStream,
    ).thenAnswer((_) => Stream.empty());
    PreferencesManager.set(preferencesManager);

    packageInfoWrapper = MockPackageInfoWrapper();
    PackageInfoWrapper.set(packageInfoWrapper);

    httpWrapper = MockHttpWrapper();
    HttpWrapper.set(httpWrapper);

    wakelockWrapper = MockWakelockWrapper();
    WakelockWrapper.set(wakelockWrapper);

    liveActivitiesManager = MockLiveActivitiesManager();
    LiveActivitiesManager.set(liveActivitiesManager);

    liveActivitiesWrapper = MockLiveActivitiesWrapper();
    LiveActivitiesWrapper.set(liveActivitiesWrapper);

    notificationManager = MockNotificationManager();
    NotificationManager.set(notificationManager);

    sharedPreferencesWrapper = MockSharedPreferencesWrapper();
    SharedPreferencesWrapper.set(sharedPreferencesWrapper);

    sharedAppGroupWrapper = MockSharedPreferenceAppGroupWrapper();
    SharedPreferenceAppGroupWrapper.set(sharedAppGroupWrapper);

    Testable.additionalLocalizations = [StringsDelegate()];
  }
}
