import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/backup.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mockito/mockito.dart';

import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.days);
    when(
      managers.preferencesManager.homeDateRange,
    ).thenReturn(DateRange(period: DateRange_Period.last7Days));
  });

  Session buildSession(String id, int startMs, int? endMs) =>
      (SessionBuilder(id)
            ..id = "SID$startMs"
            ..startTimestamp = startMs
            ..endTimestamp = endMs)
          .build;

  Activity buildActivity(String id, String name, String? currentSessionId) =>
      (ActivityBuilder(name)
            ..id = id
            ..currentSessionId = currentSessionId)
          .build;

  group("Export", () {
    test("toJsonString with empty database", () async {
      when(managers.dataManager.activities).thenAnswer((_) async => []);
      when(managers.dataManager.sessions).thenAnswer((_) async => []);

      when(
        managers.preferencesManager.largestDurationUnit,
      ).thenReturn(AppDurationUnit.days);
      when(
        managers.preferencesManager.homeDateRange,
      ).thenReturn(DateRange(period: DateRange_Period.last7Days));

      String json = await export();
      expect(
        json,
        equals(
          '{"activities":[],"sessions":[],"preferences":{"largest_duration_unit":0,"home_date_range":"{\\"1\\":9}"}}',
        ),
      );
    });

    test("toJsonString with non-empty database", () async {
      List<Activity> activityList = [
        buildActivity("AID1", "Test1", null),
        buildActivity("AID2", "Test2", null),
        buildActivity("AID3", "Test3", null),

        // In progress sessions should be ended.
        buildActivity("AID4", "Test4", "SID1"),
      ];
      when(
        managers.dataManager.activities,
      ).thenAnswer((_) async => activityList);

      List<Session> sessionList = [
        // For the purposes of testing, it doesn't actually matter what the
        // ID values are. They don't need to be associated with an Activity.
        buildSession("ID0", 5000, 10000),
        buildSession("ID1", 15000, 20000),
        buildSession("ID2", 25000, 30000),
        buildSession("ID3", 35000, 40000),
        buildSession("ID4", 45000, null),
      ];
      when(managers.dataManager.sessions).thenAnswer((_) async => sessionList);

      when(
        managers.preferencesManager.largestDurationUnit,
      ).thenReturn(AppDurationUnit.days);
      when(
        managers.preferencesManager.homeDateRange,
      ).thenReturn(DateRange(period: DateRange_Period.last7Days));

      managers.lib.stubCurrentTime(DateTime(2019, 1, 1));
      String json = await export();

      expect(
        json,
        equals(
          '{"activities":[{"name":"Test1","current_session_id":null,"id":"AID1"},{"name":"Test2","current_session_id":null,"id":"AID2"},{"name":"Test3","current_session_id":null,"id":"AID3"},{"name":"Test4","current_session_id":null,"id":"AID4"}],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":10000,"is_banked":0,"id":"SID5000"},{"activity_id":"ID1","start_timestamp":15000,"end_timestamp":20000,"is_banked":0,"id":"SID15000"},{"activity_id":"ID2","start_timestamp":25000,"end_timestamp":30000,"is_banked":0,"id":"SID25000"},{"activity_id":"ID3","start_timestamp":35000,"end_timestamp":40000,"is_banked":0,"id":"SID35000"},{"activity_id":"ID4","start_timestamp":45000,"end_timestamp":1546318800000,"is_banked":0,"id":"SID45000"}],"preferences":{"largest_duration_unit":0,"home_date_range":"{\\"1\\":9}"}}',
        ),
      );
    });
  });

  group("Import", () {
    test("errorNullInput", () async {
      ImportResult result = await import(json: "");
      expect(result, equals(ImportResult.errorNullInput));

      result = await import(json: null);
      expect(result, equals(ImportResult.errorNullInput));
    });

    test("errorDecodingJson", () async {
      String json = "Some invalid JSON";
      ImportResult result = await import(json: json);
      expect(result, equals(ImportResult.errorDecodingJson));
    });

    test("errorActivitiesNotList", () async {
      String json = "{}";
      ImportResult result = await import(json: json);
      expect(result, equals(ImportResult.errorActivitiesNotList));

      json = '{"activities" : {}}';
      result = await import(json: json);
      expect(result, equals(ImportResult.errorActivitiesNotList));
    });

    test("errorActivityNotMap", () async {
      String json = '{"activities":[5]}';
      ImportResult result = await import(json: json);
      expect(result, equals(ImportResult.errorActivityNotMap));
    });

    test("errorActivityInvalid", () async {
      String json =
          '{"activities":[{"name":"","current_session_id":null,"id":"AID1"}]}';
      ImportResult result = await import(json: json);
      expect(result, equals(ImportResult.errorActivityInvalid));

      json =
          '{"activities":[{"name":"Test1","current_session_id":null,"id":""}]}';
      result = await import(json: json);
      expect(result, equals(ImportResult.errorActivityInvalid));

      json =
          '{"activities":[{"name":"Test1","current_session_id":"ID","id":"AID1"}]}';
      result = await import(json: json);
      expect(result, equals(ImportResult.errorActivityInvalid));
    });

    test("errorSessionsNotList", () async {
      String json = '{"activities":[]}';
      ImportResult result = await import(json: json);
      expect(result, equals(ImportResult.errorSessionsNotList));

      json = '{"activities":[],"sessions":{}}';
      result = await import(json: json);
      expect(result, equals(ImportResult.errorSessionsNotList));
    });

    test("errorSessionNotMap", () async {
      String json = '{"activities":[],"sessions":[5]}';
      ImportResult result = await import(json: json);
      expect(result, equals(ImportResult.errorSessionNotMap));
    });

    test("errorSessionInvalid", () async {
      String json =
          '{"activities":[],"sessions":[{"activity_id":"","start_timestamp":5000,"end_timestamp":10000,"id":"SID5000"}]}';
      ImportResult result = await import(json: json);
      expect(result, equals(ImportResult.errorSessionInvalid));

      json =
          '{"activities":[],"sessions":[{"activity_id":"ID0","start_timestamp":null,"end_timestamp":10000,"id":"SID5000"}]}';
      result = await import(json: json);
      expect(result, equals(ImportResult.errorSessionInvalid));

      json =
          '{"activities":[],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":null,"id":"SID5000"}]}';
      result = await import(json: json);
      expect(result, equals(ImportResult.errorSessionInvalid));

      json =
          '{"activities":[],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":10000,"id":""}]}';
      result = await import(json: json);
      expect(result, equals(ImportResult.errorSessionInvalid));
    });

    test("errorClearingDatabase", () async {
      when(managers.dataManager.clearDatabase()).thenAnswer((_) async => false);
      String json = '{"activities":[],"sessions":[]}';
      ImportResult result = await import(json: json);
      expect(result, equals(ImportResult.errorClearingDatabase));
    });

    test("Preferences key doesn't exist", () async {
      when(managers.dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[],"sessions":[]}';
      await import(json: json);
      verifyNever(
        managers.preferencesManager.setHomeDateRange(argThat(anything)),
      );
      verifyNever(
        managers.preferencesManager.setLargestDurationUnit(argThat(anything)),
      );
    });

    test("Preferences not a map", () async {
      when(managers.dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[],"sessions":[],"preferences":[]}';
      await import(json: json);
      verifyNever(
        managers.preferencesManager.setHomeDateRange(argThat(anything)),
      );
      verifyNever(
        managers.preferencesManager.setLargestDurationUnit(argThat(anything)),
      );
    });

    test("Preferences map is empty", () async {
      when(managers.dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json = '{"activities":[],"sessions":[],"preferences":{}}';
      await import(json: json);
      verifyNever(
        managers.preferencesManager.setHomeDateRange(argThat(anything)),
      );
      verifyNever(
        managers.preferencesManager.setLargestDurationUnit(argThat(anything)),
      );
    });

    test("Preferences values have wrong type", () async {
      when(managers.dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json =
          '{"activities":[],"sessions":[],"preferences":{"largest_duration_unit":"non-int","home_date_range":0}}';
      await import(json: json);
      verifyNever(
        managers.preferencesManager.setHomeDateRange(argThat(anything)),
      );
      verifyNever(
        managers.preferencesManager.setLargestDurationUnit(argThat(anything)),
      );
    });

    test("Preferences are correctly set", () async {
      when(managers.dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json =
          '{"activities":[],"sessions":[],"preferences":{"largest_duration_unit":0,"home_date_range":"last7Days"}}';
      await import(json: json);
      verify(
        managers.preferencesManager.setHomeDateRange(
          argThat(equals(DateRange(period: DateRange_Period.last7Days))),
        ),
      );
      verify(
        managers.preferencesManager.setLargestDurationUnit(
          argThat(equals(AppDurationUnit.days)),
        ),
      );
    });

    test("success", () async {
      when(managers.dataManager.clearDatabase()).thenAnswer((_) async => true);

      String json =
          '{"activities":[{"name":"Test1","current_session_id":null,"id":"AID1"},{"name":"Test2","current_session_id":null,"id":"AID2"},{"name":"Test3","current_session_id":null,"id":"AID3"},{"name":"Test4","current_session_id":null,"id":"AID4"}],"sessions":[{"activity_id":"ID0","start_timestamp":5000,"end_timestamp":10000,"id":"SID5000"},{"activity_id":"ID1","start_timestamp":15000,"end_timestamp":20000,"id":"SID15000"},{"activity_id":"ID2","start_timestamp":25000,"end_timestamp":30000,"id":"SID25000"},{"activity_id":"ID3","start_timestamp":35000,"end_timestamp":40000,"id":"SID35000"},{"activity_id":"ID4","start_timestamp":45000,"end_timestamp":1546318800000,"id":"SID45000"}],"preferences":{"largest_duration_unit":1,"home_date_range":"last14Days"}}';
      expect(await import(json: json), equals(ImportResult.success));

      List<Activity> activityList = verify(
        managers.dataManager.addActivities(
          captureThat(isInstanceOf<List<Activity>>()),
          notify: false,
        ),
      ).captured.single;

      List<Session> sessionList = verify(
        managers.dataManager.addSessions(
          captureThat(isInstanceOf<List<Session>>()),
          notify: true,
        ),
      ).captured.single;

      expect(activityList.length, equals(4));
      expect(sessionList.length, equals(5));

      for (var activity in activityList) {
        expect(activity.id, isNotEmpty);
        expect(activity.name, isNotEmpty);
        expect(activity.isRunning, isFalse);
      }

      for (var session in sessionList) {
        expect(session.id, isNotEmpty);
        expect(session.activityId, isNotEmpty);
        expect(session.startTimestamp, isNotNull);
        expect(session.endTimestamp, isNotNull);
      }

      verify(
        managers.preferencesManager.setHomeDateRange(
          argThat(equals(DateRange(period: DateRange_Period.last14Days))),
        ),
      );
      verify(
        managers.preferencesManager.setLargestDurationUnit(
          argThat(equals(AppDurationUnit.hours)),
        ),
      );
    });
  });
}
