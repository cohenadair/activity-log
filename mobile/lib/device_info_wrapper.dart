import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoWrapper {
  static var _instance = DeviceInfoWrapper._();

  static DeviceInfoWrapper get get => _instance;

  @visibleForTesting
  static void set(DeviceInfoWrapper manager) => _instance = manager;

  @visibleForTesting
  static void suicide() => _instance = DeviceInfoWrapper._();

  DeviceInfoWrapper._();

  Future<AndroidDeviceInfo> get androidInfo => DeviceInfoPlugin().androidInfo;

  Future<IosDeviceInfo> get iosInfo => DeviceInfoPlugin().iosInfo;
}
