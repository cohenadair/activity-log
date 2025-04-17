import 'package:mobile/http_wrapper.dart';
import 'package:mobile/package_info_wrapper.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/database/data_manager.dart';

import 'device_info_wrapper.dart';

class AppManager {
  DeviceInfoWrapper? _deviceInfoWrapper;
  PackageInfoWrapper? _packageInfoWrapper;
  HttpWrapper? _httpWrapper;

  DataManager get dataManager => DataManager.get;

  PreferencesManager get preferencesManager => PreferencesManager.get;

  DeviceInfoWrapper get deviceInfoWrapper {
    _deviceInfoWrapper ??= DeviceInfoWrapper();
    return _deviceInfoWrapper!;
  }

  PackageInfoWrapper get packageInfoWrapper {
    _packageInfoWrapper ??= PackageInfoWrapper();
    return _packageInfoWrapper!;
  }

  HttpWrapper get httpWrapper {
    _httpWrapper ??= HttpWrapper();
    return _httpWrapper!;
  }
}
