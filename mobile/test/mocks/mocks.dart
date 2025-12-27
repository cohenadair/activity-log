import 'package:live_activities/live_activities.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/live_activities_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:mobile/wrappers/live_activities_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/shared_preference_app_group_wrapper.dart';
import 'package:mobile/wrappers/shared_preferences_wrapper.dart';
import 'package:mobile/wrappers/wakelock_wrapper.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([Activity])
@GenerateMocks([DataManager])
@GenerateMocks([PreferencesManager])
@GenerateMocks([PackageInfoWrapper])
@GenerateMocks([HttpWrapper])
@GenerateMocks([Database])
@GenerateMocks([Batch])
@GenerateMocks([Session])
@GenerateMocks([WakelockWrapper])
@GenerateMocks([LiveActivitiesManager])
@GenerateMocks([LiveActivitiesWrapper])
@GenerateMocks([LiveActivities])
@GenerateMocks([NotificationManager])
@GenerateMocks([SharedPreferencesWrapper])
@GenerateMocks([SharedPreferencesAsync])
@GenerateMocks([SharedPreferenceAppGroupWrapper])
void main() {}
