import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/device_info_wrapper.dart';
import 'package:mobile/http_wrapper.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/package_info_wrapper.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([Activity])
@GenerateMocks([DataManager])
@GenerateMocks([PreferencesManager])
@GenerateMocks([DeviceInfoWrapper])
@GenerateMocks([PackageInfoWrapper])
@GenerateMocks([HttpWrapper])
@GenerateMocks([Database])
@GenerateMocks([Batch])
@GenerateMocks([AndroidBuildVersion])
@GenerateMocks([AndroidDeviceInfo])
@GenerateMocks([IosDeviceInfo])
@GenerateMocks([Session])
void main() {}
