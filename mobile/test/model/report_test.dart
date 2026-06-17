import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/report.dart';

void main() {
  final dateRange = DateRange(period: DateRange_Period.allDates);

  Map<String, dynamic> reportMap({String activityIds = ""}) => {
    "id": "report-id",
    "name": "My Report",
    "activity_ids": activityIds,
    "date_range": dateRange.writeToJson(),
  };

  test("fromMap parses name", () {
    final report = Report.fromMap(reportMap());
    expect(report.name, "My Report");
  });

  test("fromMap parses empty activityIds as empty list", () {
    final report = Report.fromMap(reportMap(activityIds: ""));
    expect(report.activityIds, isEmpty);
  });

  test("fromMap parses comma-separated activityIds", () {
    final report = Report.fromMap(reportMap(activityIds: "a1,a2,a3"));
    expect(report.activityIds, ["a1", "a2", "a3"]);
  });

  test("fromMap parses dateRange", () {
    final report = Report.fromMap(reportMap());
    expect(report.dateRange.period, DateRange_Period.allDates);
  });

  test("toMap serializes name", () {
    final report = ReportBuilder(
      name: "My Report",
      activityIds: [],
      dateRange: dateRange,
    ).build;
    expect(report.toMap()["name"], "My Report");
  });

  test("toMap serializes empty activityIds as empty string", () {
    final report = ReportBuilder(
      name: "My Report",
      activityIds: [],
      dateRange: dateRange,
    ).build;
    expect(report.toMap()["activity_ids"], "");
  });

  test("toMap serializes activityIds as comma-separated string", () {
    final report = ReportBuilder(
      name: "My Report",
      activityIds: ["a1", "a2"],
      dateRange: dateRange,
    ).build;
    expect(report.toMap()["activity_ids"], "a1,a2");
  });

  test("toMap serializes dateRange", () {
    final report = ReportBuilder(
      name: "My Report",
      activityIds: [],
      dateRange: dateRange,
    ).build;
    expect(report.toMap()["date_range"], dateRange.writeToJson());
  });

  test("Equality is based on id", () {
    final map = reportMap();
    final a = Report.fromMap(map);
    final b = Report.fromMap(map);
    expect(a, b);
  });

  test("Reports with different ids are not equal", () {
    final a = Report.fromMap(reportMap()..["id"] = "id-a");
    final b = Report.fromMap(reportMap()..["id"] = "id-b");
    expect(a, isNot(b));
  });

  test("fromBuilder copies fields from builder", () {
    final builder = ReportBuilder(
      name: "Test",
      activityIds: ["x"],
      dateRange: dateRange,
    );
    final report = builder.build;
    expect(report.name, "Test");
    expect(report.activityIds, ["x"]);
    expect(report.dateRange.period, DateRange_Period.allDates);
  });

  test("ReportBuilder.fromReport copies all fields", () {
    final original = Report.fromMap(reportMap(activityIds: "a1,a2"));
    final builder = ReportBuilder.fromReport(original);
    expect(builder.name, original.name);
    expect(builder.activityIds, original.activityIds);
    expect(builder.id, original.id);
  });
}
