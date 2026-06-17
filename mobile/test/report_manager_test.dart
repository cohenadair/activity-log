import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/report_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'stubbed_managers.dart';

void main() {
  late MockDatabase database;

  final dateRange = DateRange(period: DateRange_Period.allDates);

  Map<String, dynamic> reportMap(String id, String name) => {
    "id": id,
    "name": name,
    "activity_ids": "",
    "date_range": dateRange.writeToJson(),
  };

  setUp(() async {
    await StubbedManagers.create();

    database = MockDatabase();

    ReportManager.reset();
    await ReportManager.get.init(database);
  });

  test("reports returns list ordered by name from database", () async {
    when(
      database.rawQuery("SELECT * FROM report ORDER BY name"),
    ).thenAnswer((_) => Future.value([reportMap("r1", "Alpha")]));

    final result = await ReportManager.get.reports();
    expect(result.length, 1);
    expect(result.first.name, "Alpha");
  });

  test("reportNameExists returns true when name exists", () async {
    when(
      database.rawQuery(
        "SELECT COUNT(*) FROM report WHERE name = ? COLLATE NOCASE",
        ["Alpha"],
      ),
    ).thenAnswer(
      (_) => Future.value([
        {"COUNT(*)": 1},
      ]),
    );

    final exists = await ReportManager.get.reportNameExists("Alpha");
    expect(exists, isTrue);
  });

  test("reportNameExists returns false when name does not exist", () async {
    when(
      database.rawQuery(
        "SELECT COUNT(*) FROM report WHERE name = ? COLLATE NOCASE",
        ["Missing"],
      ),
    ).thenAnswer(
      (_) => Future.value([
        {"COUNT(*)": 0},
      ]),
    );

    final exists = await ReportManager.get.reportNameExists("Missing");
    expect(exists, isFalse);
  });

  test("addReport inserts into database and notifies stream", () async {
    final report = ReportBuilder(
      name: "Test",
      activityIds: [],
      dateRange: dateRange,
    ).build;
    when(database.insert("report", any)).thenAnswer((_) => Future.value(1));

    var notified = false;
    ReportManager.get.reportsUpdatedStream.listen((_) => notified = true);

    await ReportManager.get.addReport(report);

    verify(database.insert("report", any)).called(1);
    await Future.delayed(Duration.zero);
    expect(notified, isTrue);
  });

  test(
    "updateReport updates database and notifies when rows affected > 0",
    () async {
      final report = ReportBuilder(
        name: "Test",
        activityIds: [],
        dateRange: dateRange,
      ).build;

      when(
        database.update(
          "report",
          any,
          where: anyNamed("where"),
          whereArgs: anyNamed("whereArgs"),
        ),
      ).thenAnswer((_) => Future.value(1));

      var notified = false;
      ReportManager.get.reportsUpdatedStream.listen((_) => notified = true);

      await ReportManager.get.updateReport(report);

      verify(
        database.update(
          "report",
          any,
          where: anyNamed("where"),
          whereArgs: anyNamed("whereArgs"),
        ),
      ).called(1);

      await Future.delayed(Duration.zero);
      expect(notified, isTrue);
    },
  );

  test("updateReport does not notify when no rows affected", () async {
    final report = ReportBuilder(
      name: "Test",
      activityIds: [],
      dateRange: dateRange,
    ).build;
    when(
      database.update(
        "report",
        any,
        where: anyNamed("where"),
        whereArgs: anyNamed("whereArgs"),
      ),
    ).thenAnswer((_) => Future.value(0));

    var notified = false;
    ReportManager.get.reportsUpdatedStream.listen((_) => notified = true);

    await ReportManager.get.updateReport(report);

    await Future.delayed(Duration.zero);
    expect(notified, isFalse);
  });

  test("removeReport deletes from database and notifies", () async {
    when(
      database.rawDelete("DELETE FROM report WHERE id = ?", ["r1"]),
    ).thenAnswer((_) => Future.value(1));

    var notified = false;
    ReportManager.get.reportsUpdatedStream.listen((_) => notified = true);

    await ReportManager.get.removeReport("r1");

    verify(
      database.rawDelete("DELETE FROM report WHERE id = ?", ["r1"]),
    ).called(1);
    await Future.delayed(Duration.zero);

    expect(notified, isTrue);
  });
}
