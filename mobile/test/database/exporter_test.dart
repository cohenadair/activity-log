import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/exporter.dart';
import 'package:mobile/database/sqlite_data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/time.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements SQLiteDataManager {}
class MockPreferencesManager extends Mock implements PreferencesManager {}

void main() {
  MockAppManager appManager;
  MockDataManager dataManager;
  MockPreferencesManager preferencesManager;

  setUp(() {
    appManager = MockAppManager();
    dataManager = MockDataManager();
    preferencesManager = MockPreferencesManager();

    when(appManager.dataManager).thenReturn(dataManager);
    when(appManager.preferencesManager).thenReturn(preferencesManager);
  });

  Session _buildSession(String id, int startMs, int endMs) =>
      (SessionBuilder(id)
        ..id = "SID$startMs"
        ..startTimestamp = startMs
        ..endTimestamp = endMs).build;

  Activity _buildActivity(String id, String name, String currentSessionId) =>
      (ActivityBuilder(name)
        ..id = id
        ..currentSessionId = currentSessionId).build;

  void mockActivitiesAndSessions() {
    List<Activity> activityList = [
      _buildActivity("AID1", "Test1", null),
      _buildActivity("AID2", "Test2", null),
      _buildActivity("AID3", "Test3", null),

      // In progress sessions should be ended.
      _buildActivity("AID4", "Test4", "SID1"),
    ];
    when(dataManager.activities).thenAnswer((_) async => activityList);

    List<Session> sessionList = [
      // For the purposes of testing, it doesn't actually matter what the
      // ID values are. They don't need to be associated with an Activity.
      _buildSession("ID0", 5000, 10000),
      _buildSession("ID1", 15000, 20000),
      _buildSession("ID2", 25000, 30000),
      _buildSession("ID3", 35000, 40000),
      _buildSession("ID4", 45000, null),
    ];
    when(dataManager.sessions).thenAnswer((_) async => sessionList);
  }

  group("Export", () {
    test("toJsonString", () async {
      mockActivitiesAndSessions();

      when(preferencesManager.largestDurationUnit)
          .thenReturn(DurationUnit.days);
      when(preferencesManager.homeDateRange)
          .thenReturn(DisplayDateRange.last7Days);

      var clock = Clock.fixed(DateTime(2019, 1, 1));
      Exporter exporter = Exporter(appManager, clock: clock);

      expect((await exporter.toJsonString), equals('{"activities":[{"name":"Test1","current_session_id":null,"id":"AID1"},{"name":"Test2","current_session_id":null,"id":"AID2"},{"name":"Test3","current_session_id":null,"id":"AID3"},{"name":"Test4","current_session_id":null,"id":"AID4"}],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":10000,"id":"SID5000"},{"activity_id":"ID1","start_timestamp":15000,"end_timestamp":20000,"id":"SID15000"},{"activity_id":"ID2","start_timestamp":25000,"end_timestamp":30000,"id":"SID25000"},{"activity_id":"ID3","start_timestamp":35000,"end_timestamp":40000,"id":"SID35000"},{"activity_id":"ID4","start_timestamp":45000,"end_timestamp":1546318800000,"id":"SID45000"}],"preferences":{"largest_duration_unit":0,"home_date_range":"last7Days"}}'));
    });
  });
}