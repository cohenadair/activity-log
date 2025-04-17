import 'package:mobile/database/data_manager.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';

import '../../../adair-flutter-lib/test/mocks/mocks.mocks.dart';
import '../../../adair-flutter-lib/test/test_utils/stubbed_managers.dart' as s;
import '../../../adair-flutter-lib/test/test_utils/test_time_manager.dart';

class StubbedManagers {
  late final s.StubbedManagers _lib;

  late final MockDataManager dataManager;
  late final MockPreferencesManager preferencesManager;

  static Future<StubbedManagers> create() async =>
      StubbedManagers._(await s.StubbedManagers.create());

  MockAppConfig get appConfig => _lib.appConfig;

  MockIoWrapper get ioWrapper => _lib.ioWrapper;

  MockPropertiesManager get propertiesManager => _lib.propertiesManager;

  MockSubscriptionManager get subscriptionManager => _lib.subscriptionManager;

  TestTimeManager get timeManager => _lib.timeManager;

  StubbedManagers._(this._lib) {
    dataManager = MockDataManager();
    DataManager.set(dataManager);

    preferencesManager = MockPreferencesManager();
    when(preferencesManager.largestDurationUnitStream)
        .thenAnswer((_) => Stream.empty());
    when(preferencesManager.homeDateRangeStream)
        .thenAnswer((_) => Stream.empty());
    PreferencesManager.set(preferencesManager);
  }
}
