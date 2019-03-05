import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/sqlite_data_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  MockDatabase database;
  SQLiteDataManager dataManager;

  setUp(() {
    database = MockDatabase();
    dataManager = SQLiteDataManager();
    dataManager.initialize(database);
  });

  tearDown(() {
    database = null;
    dataManager = null;
  });

  stubActivities(List<Map<String, dynamic>> result) {
    when(database.rawQuery("SELECT * FROM activity"))
        .thenAnswer((_) async => result);
  }

  group("getSummarizedActivities", () {
    test("Null input", () async {
      var result = await dataManager.getSummarizedActivities(null);
      expect(result.length, equals(0));
    });

    test("No activities", () async {
      stubActivities([]);
      var result = await dataManager.getSummarizedActivities(
          DateRange(startDate: DateTime.now(), endDate: DateTime.now()));
      expect(result.length, equals(0));
    });
  });
}