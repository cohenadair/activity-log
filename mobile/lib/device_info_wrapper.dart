import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoWrapper {
  Future<AndroidDeviceInfo> get androidInfo => DeviceInfoPlugin().androidInfo;

  Future<IosDeviceInfo> get iosInfo => DeviceInfoPlugin().iosInfo;
}
