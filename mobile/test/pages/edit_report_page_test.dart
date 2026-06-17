import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/pages/edit_report_page.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  final dateRange = DateRange(period: DateRange_Period.allDates);

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  Report makeReport(String id, String name) => (ReportBuilder(
    name: name,
    activityIds: [],
    dateRange: dateRange,
  )..id = id).build;

  Future<void> pumpPage(
    WidgetTester tester, {
    Report? editingReport,
    void Function(Report)? onSaved,
  }) async {
    await pumpContext(
      tester,
      (_) => EditReportPage(
        editingReport: editingReport,
        activities: const {},
        dateRange: dateRange,
        onSaved: onSaved,
      ),
    );
  }

  testWidgets("New mode shows new title", (tester) async {
    await pumpPage(tester);
    expect(find.text("New Report"), findsOneWidget);
  });

  testWidgets("Edit mode shows edit title", (tester) async {
    await pumpPage(tester, editingReport: makeReport("r1", "Old Name"));
    expect(find.text("Edit Report"), findsOneWidget);
  });

  testWidgets("Edit mode pre-fills name field", (tester) async {
    await pumpPage(tester, editingReport: makeReport("r1", "Old Name"));
    expect(find.text("Old Name"), findsOneWidget);
  });

  testWidgets("Edit mode shows delete button", (tester) async {
    await pumpPage(tester, editingReport: makeReport("r1", "Old Name"));
    // Button renders uppercased in Material2
    expect(find.text("DELETE"), findsOneWidget);
  });

  testWidgets("New mode does not show delete button", (tester) async {
    await pumpPage(tester);
    expect(find.text("DELETE"), findsNothing);
  });

  testWidgets("Save with empty name shows validation error", (tester) async {
    when(
      managers.reportManager.reportNameExists(any),
    ).thenAnswer((_) => Future.value(false));

    await pumpPage(tester);
    await tapAndSettle(tester, find.text("SAVE"));
    expect(find.text("Enter a name for your report."), findsOneWidget);
  });

  testWidgets("Save with duplicate name shows validation error", (
    tester,
  ) async {
    when(
      managers.reportManager.reportNameExists(any),
    ).thenAnswer((_) => Future.value(true));

    await pumpPage(tester);
    await enterTextAndSettle(tester, find.byType(TextFormField), "Existing");
    await tapAndSettle(tester, find.text("SAVE"));
    expect(find.text("Report name already exists."), findsOneWidget);
  });

  testWidgets("Save with valid new name calls addReport and onSaved", (
    tester,
  ) async {
    Report? savedReport;
    when(
      managers.reportManager.reportNameExists(any),
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.reportManager.addReport(any),
    ).thenAnswer((_) => Future.value());

    await pumpPage(tester, onSaved: (r) => savedReport = r);
    await enterTextAndSettle(tester, find.byType(TextFormField), "New Name");
    await tapAndSettle(tester, find.text("SAVE"));

    verify(managers.reportManager.addReport(any)).called(1);
    expect(savedReport, isNotNull);
    expect(savedReport!.name, "New Name");
  });

  testWidgets("Save in edit mode calls updateReport not addReport", (
    tester,
  ) async {
    when(
      managers.reportManager.updateReport(any),
    ).thenAnswer((_) => Future.value());

    await pumpPage(tester, editingReport: makeReport("r1", "Old Name"));
    await tapAndSettle(tester, find.text("SAVE"));

    verify(managers.reportManager.updateReport(any)).called(1);
    verifyNever(managers.reportManager.addReport(any));
  });

  testWidgets(
    "Save in edit mode with same name skips name-exists check and saves",
    (tester) async {
      when(
        managers.reportManager.updateReport(any),
      ).thenAnswer((_) => Future.value());

      await pumpPage(tester, editingReport: makeReport("r1", "Same Name"));
      await tapAndSettle(tester, find.text("SAVE"));

      verifyNever(managers.reportManager.reportNameExists(any));
      verify(managers.reportManager.updateReport(any)).called(1);
    },
  );

  testWidgets("Delete calls removeReport", (tester) async {
    when(
      managers.reportManager.removeReport(any),
    ).thenAnswer((_) => Future.value());

    await pumpPage(tester, editingReport: makeReport("r1", "Old Name"));
    await tapAndSettle(tester, find.text("DELETE"));
    // Confirm deletion in dialog
    await tapAndSettle(tester, find.text("DELETE").last);

    verify(managers.reportManager.removeReport("r1")).called(1);
  });
}
