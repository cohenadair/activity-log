import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/backup.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/time.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockAppManager app;
  late MockSQLiteDataManager dataManager;
  late MockPreferencesManager preferencesManager;

  setUp(() {
    app = MockAppManager();
    dataManager = MockSQLiteDataManager();
    preferencesManager = MockPreferencesManager();

    when(app.dataManager).thenReturn(dataManager);
    when(app.preferencesManager).thenReturn(preferencesManager);

    when(preferencesManager.largestDurationUnit)
        .thenReturn(DurationUnit.days);
    when(preferencesManager.homeDateRange)
        .thenReturn(DisplayDateRange.last7Days);
  });

  Session _buildSession(String id, int startMs, int? endMs) =>
      (SessionBuilder(id)
        ..id = "SID$startMs"
        ..startTimestamp = startMs
        ..endTimestamp = endMs).build;

  Activity _buildActivity(String id, String name, String? currentSessionId) =>
      (ActivityBuilder(name)
        ..id = id
        ..currentSessionId = currentSessionId).build;

  group("Export", () {
    test("toJsonString with empty database", () async {
      when(dataManager.activities).thenAnswer((_) async => []);
      when(dataManager.sessions).thenAnswer((_) async => []);

      when(preferencesManager.largestDurationUnit)
          .thenReturn(DurationUnit.days);
      when(preferencesManager.homeDateRange)
          .thenReturn(DisplayDateRange.last7Days);

      String json = await export(app);
      expect(json, equals('{"activities":[],"sessions":[],"preferences":{"largest_duration_unit":0,"home_date_range":"last7Days"}}'));
    });

    test("toJsonString with non-empty database", () async {
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

      when(preferencesManager.largestDurationUnit)
          .thenReturn(DurationUnit.days);
      when(preferencesManager.homeDateRange)
          .thenReturn(DisplayDateRange.last7Days);

      var clock = Clock.fixed(DateTime(2019, 1, 1));
      String json = await export(app, clock: clock);

      expect(json, equals('{"activities":[{"name":"Test1","current_session_id":null,"id":"AID1"},{"name":"Test2","current_session_id":null,"id":"AID2"},{"name":"Test3","current_session_id":null,"id":"AID3"},{"name":"Test4","current_session_id":null,"id":"AID4"}],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":10000,"is_banked":0,"id":"SID5000"},{"activity_id":"ID1","start_timestamp":15000,"end_timestamp":20000,"is_banked":0,"id":"SID15000"},{"activity_id":"ID2","start_timestamp":25000,"end_timestamp":30000,"is_banked":0,"id":"SID25000"},{"activity_id":"ID3","start_timestamp":35000,"end_timestamp":40000,"is_banked":0,"id":"SID35000"},{"activity_id":"ID4","start_timestamp":45000,"end_timestamp":1546322400000,"is_banked":0,"id":"SID45000"}],"preferences":{"largest_duration_unit":0,"home_date_range":"last7Days"}}'));
    });
  });

  group("Import", () {
    test("errorNullInput", () async {
      ImportResult result = await import(app, json: "");
      expect(result, equals(ImportResult.errorNullInput));

      result = await import(app, json: null);
      expect(result, equals(ImportResult.errorNullInput));
    });

    test("errorDecodingJson", () async {
      String json = "Some invalid JSON";
      ImportResult result = await import(app, json: json);
      expect(result, equals(ImportResult.errorDecodingJson));
    });

    test("errorActivitiesNotList", () async {
      String json = "{}";
      ImportResult result = await import(app, json: json);
      expect(result, equals(ImportResult.errorActivitiesNotList));

      json = '{"activities" : {}}';
      result = await import(app, json: json);
      expect(result, equals(ImportResult.errorActivitiesNotList));
    });

    test("errorActivityNotMap", () async {
      String json = '{"activities":[5]}';
      ImportResult result = await import(app, json: json);
      expect(result, equals(ImportResult.errorActivityNotMap));
    });

    test("errorActivityInvalid", () async {
      String json = '{"activities":[{"name":"","current_session_id":null,"id":"AID1"}]}';
      ImportResult result = await import(app, json: json);
      expect(result, equals(ImportResult.errorActivityInvalid));

      json = '{"activities":[{"name":"Test1","current_session_id":null,"id":""}]}';
      result = await import(app, json: json);
      expect(result, equals(ImportResult.errorActivityInvalid));

      json = '{"activities":[{"name":"Test1","current_session_id":"ID","id":"AID1"}]}';
      result = await import(app, json: json);
      expect(result, equals(ImportResult.errorActivityInvalid));
    });

    test("errorSessionsNotList", () async {
      String json = '{"activities":[]}';
      ImportResult result = await import(app, json: json);
      expect(result, equals(ImportResult.errorSessionsNotList));

      json = '{"activities":[],"sessions":{}}';
      result = await import(app, json: json);
      expect(result, equals(ImportResult.errorSessionsNotList));
    });

    test("errorSessionNotMap", () async {
      String json = '{"activities":[],"sessions":[5]}';
      ImportResult result = await import(app, json: json);
      expect(result, equals(ImportResult.errorSessionNotMap));
    });

    test("errorSessionInvalid", () async {
      String json = '{"activities":[],"sessions":[{"activity_id":"","start_timestamp":5000,"end_timestamp":10000,"id":"SID5000"}]}';
      ImportResult result = await import(app, json: json);
      expect(result, equals(ImportResult.errorSessionInvalid));

      json = '{"activities":[],"sessions":[{"activity_id":"ID0","start_timestamp":null,"end_timestamp":10000,"id":"SID5000"}]}';
      result = await import(app, json: json);
      expect(result, equals(ImportResult.errorSessionInvalid));

      json = '{"activities":[],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":null,"id":"SID5000"}]}';
      result = await import(app, json: json);
      expect(result, equals(ImportResult.errorSessionInvalid));

      json = '{"activities":[],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":10000,"id":""}]}';
      result = await import(app, json: json);
      expect(result, equals(ImportResult.errorSessionInvalid));
    });

    test("errorClearingDatabase", () async {
      when(dataManager.clearDatabase()).thenAnswer((_) async => false);
      String json = '{"activities":[],"sessions":[]}';
      ImportResult result = await import(app, json: json);
      expect(result, equals(ImportResult.errorClearingDatabase));
    });

    test("Preferences key doesn't exist", () async {
      when(dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[],"sessions":[]}';
      await import(app, json: json);
      verifyNever(preferencesManager.setHomeDateRange(argThat(anything)));
      verifyNever(preferencesManager.setLargestDurationUnit(argThat(anything)));
    });
    
    test("Preferences not a map", () async {
      when(dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[],"sessions":[],"preferences":[]}';
      await import(app, json: json);
      verifyNever(preferencesManager.setHomeDateRange(argThat(anything)));
      verifyNever(preferencesManager.setLargestDurationUnit(argThat(anything)));
    });
    
    test("Preferences map is empty", () async {
      when(dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[],"sessions":[],"preferences":{}}';
      await import(app, json: json);
      verifyNever(preferencesManager.setHomeDateRange(argThat(anything)));
      verifyNever(preferencesManager.setLargestDurationUnit(argThat(anything)));
    });
    
    test("Preferences values have wrong type", () async {
      when(dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[],"sessions":[],"preferences":{"largest_duration_unit":"non-int","home_date_range":0}}';
      await import(app, json: json);
      verifyNever(preferencesManager.setHomeDateRange(argThat(anything)));
      verifyNever(preferencesManager.setLargestDurationUnit(argThat(anything)));
    });
    
    test("Preferences are correctly set", () async {
      when(dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[],"sessions":[],"preferences":{"largest_duration_unit":0,"home_date_range":"last7Days"}}';
      await import(app, json: json);
      verify(preferencesManager
          .setHomeDateRange(argThat(equals(DisplayDateRange.last7Days))));
      verify(preferencesManager
          .setLargestDurationUnit(argThat(equals(DurationUnit.days))));
    });

    test("success", () async {
      when(dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[{"name":"Test1","current_session_id":null,"id":"AID1"},{"name":"Test2","current_session_id":null,"id":"AID2"},{"name":"Test3","current_session_id":null,"id":"AID3"},{"name":"Test4","current_session_id":null,"id":"AID4"}],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":10000,"id":"SID5000"},{"activity_id":"ID1","start_timestamp":15000,"end_timestamp":20000,"id":"SID15000"},{"activity_id":"ID2","start_timestamp":25000,"end_timestamp":30000,"id":"SID25000"},{"activity_id":"ID3","start_timestamp":35000,"end_timestamp":40000,"id":"SID35000"},{"activity_id":"ID4","start_timestamp":45000,"end_timestamp":1546318800000,"id":"SID45000"}],"preferences":{"largest_duration_unit":1,"home_date_range":"last14Days"}}';
      expect(await import(app, json: json), equals(ImportResult.success));
      
      List<Activity> activityList = verify(dataManager.addActivities(
        captureThat(isInstanceOf<List<Activity>>()),
        notify: false,
      )).captured.single;

      List<Session> sessionList = verify(dataManager.addSessions(
          captureThat(isInstanceOf<List<Session>>()),
          notify: true,
      )).captured.single;

      expect(activityList.length, equals(4));
      expect(sessionList.length, equals(5));

      activityList.forEach((Activity activity) {
        expect(activity.id, isNotEmpty);
        expect(activity.name, isNotEmpty);
        expect(activity.isRunning, isFalse);
      });

      sessionList.forEach((Session session) {
        expect(session.id, isNotEmpty);
        expect(session.activityId, isNotEmpty);
        expect(session.startTimestamp, isNotNull);
        expect(session.endTimestamp, isNotNull);
      });

      verify(preferencesManager
          .setHomeDateRange(argThat(equals(DisplayDateRange.last14Days))));
      verify(preferencesManager
          .setLargestDurationUnit(argThat(equals(DurationUnit.hours))));
    });
  });
}