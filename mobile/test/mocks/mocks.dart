import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/live_activities_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/wakelock_wrapper.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([Activity])
@GenerateMocks([DataManager])
@GenerateMocks([PreferencesManager])
@GenerateMocks([PackageInfoWrapper])
@GenerateMocks([HttpWrapper])
@GenerateMocks([Database])
@GenerateMocks([Batch])
@GenerateMocks([AndroidBuildVersion])
@GenerateMocks([AndroidDeviceInfo])
@GenerateMocks([IosDeviceInfo])
@GenerateMocks([Session])
@GenerateMocks([WakelockWrapper])
@GenerateMocks([LiveActivitiesManager])
void main() {}
