import 'package:mobile/database/data_manager.dart';
import 'package:mobile/device_info_wrapper.dart';
import 'package:mobile/http_wrapper.dart';
import 'package:mobile/package_info_wrapper.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mockito/mockito.dart';

import '../../../adair-flutter-lib/test/mocks/mocks.mocks.dart';
import '../../../adair-flutter-lib/test/test_utils/stubbed_managers.dart' as s;
import 'mocks/mocks.mocks.dart';

class StubbedManagers {
  late final s.StubbedManagers lib;

  late final MockDataManager dataManager;
  late final MockPreferencesManager preferencesManager;
  late final MockDeviceInfoWrapper deviceInfoWrapper;
  late final MockPackageInfoWrapper packageInfoWrapper;
  late final MockHttpWrapper httpWrapper;

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

    deviceInfoWrapper = MockDeviceInfoWrapper();
    DeviceInfoWrapper.set(deviceInfoWrapper);

    packageInfoWrapper = MockPackageInfoWrapper();
    PackageInfoWrapper.set(packageInfoWrapper);

    httpWrapper = MockHttpWrapper();
    HttpWrapper.set(httpWrapper);
  }
}
