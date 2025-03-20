import 'package:mobile/http_wrapper.dart';
import 'package:mobile/io_wrapper.dart';
import 'package:mobile/package_info_wrapper.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/properties_manager.dart';

import 'device_info_wrapper.dart';

class AppManager {
  PropertiesManager? _propertiesManager;

  DeviceInfoWrapper? _deviceInfoWrapper;
  IoWrapper? _ioWrapper;
  PackageInfoWrapper? _packageInfoWrapper;
  HttpWrapper? _httpWrapper;

  DataManager get dataManager => DataManager.get;

  PreferencesManager get preferencesManager => PreferencesManager.get;

  PropertiesManager get propertiesManager {
    _propertiesManager ??= PropertiesManager();
    return _propertiesManager!;
  }

  DeviceInfoWrapper get deviceInfoWrapper {
    _deviceInfoWrapper ??= DeviceInfoWrapper();
    return _deviceInfoWrapper!;
  }

  IoWrapper get ioWrapper {
    _ioWrapper ??= IoWrapper();
    return _ioWrapper!;
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
