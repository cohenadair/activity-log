import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/sqlite_data_manager.dart';
import 'package:mobile/device_info_wrapper.dart';
import 'package:mobile/http_wrapper.dart';
import 'package:mobile/io_wrapper.dart';
import 'package:mobile/package_info_wrapper.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([AppManager])
@GenerateMocks([SQLiteDataManager])
@GenerateMocks([PreferencesManager])
@GenerateMocks([PropertiesManager])
@GenerateMocks([DeviceInfoWrapper])
@GenerateMocks([IoWrapper])
@GenerateMocks([PackageInfoWrapper])
@GenerateMocks([HttpWrapper])
@GenerateMocks([Database])
@GenerateMocks([Batch])
@GenerateMocks([AndroidBuildVersion])
@GenerateMocks([AndroidDeviceInfo])
@GenerateMocks([IosDeviceInfo])
void main() {}
