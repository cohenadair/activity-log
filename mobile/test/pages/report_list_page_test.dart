import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/pages/edit_report_page.dart';
import 'package:mobile/pages/report_list_page.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  final dateRange = DateRange(period: DateRange_Period.allDates);

  Report makeReport(String id, String name) => (ReportBuilder(
    name: name,
    activityIds: [],
    dateRange: dateRange,
  )..id = id).build;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Report? selectedReport,
    void Function(Report)? onReportPicked,
  }) async {
    await pumpContext(
      tester,
      (_) => ReportListPage(
        selectedReport: selectedReport,
        currentActivities: const {},
        currentDateRange: dateRange,
        onReportPicked: onReportPicked ?? (_) {},
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("Renders reports from stream", (tester) async {
    final reports = [makeReport("r1", "Alpha"), makeReport("r2", "Beta")];
    when(
      managers.reportManager.reportsStream,
    ).thenAnswer((_) => Stream.value(reports));

    await pumpPage(tester);
    expect(find.text("Alpha"), findsOneWidget);
    expect(find.text("Beta"), findsOneWidget);
  });

  testWidgets("Edit button navigates to EditReportPage", (tester) async {
    final report = makeReport("r1", "Alpha");
    when(
      managers.reportManager.reportsStream,
    ).thenAnswer((_) => Stream.value([report]));

    await pumpPage(tester);
    await tapAndSettle(tester, find.byIcon(Icons.edit));

    expect(find.byType(EditReportPage), findsOneWidget);
  });

  testWidgets("Tapping a report calls onReportPicked", (tester) async {
    final report = makeReport("r1", "Alpha");
    Report? picked;
    when(
      managers.reportManager.reportsStream,
    ).thenAnswer((_) => Stream.value([report]));

    await pumpPage(tester, onReportPicked: (r) => picked = r);
    await tapAndSettle(tester, find.text("Alpha"));

    expect(picked, isNotNull);
    expect(picked!.id, "r1");
  });
}
