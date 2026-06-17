import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/widgets/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/pages/edit_report_page.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/widgets/list_picker.dart';

class ReportListPage extends StatelessWidget {
  final Report? selectedReport;
  final Set<Activity> currentActivities;
  final DateRange currentDateRange;

  /// Called when the user picks a report from the list.
  final void Function(Report) onReportPicked;

  const ReportListPage({
    required this.selectedReport,
    required this.currentActivities,
    required this.currentDateRange,
    required this.onReportPicked,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<Report>>.stream(
      stream: ReportManager.get.reportsStream,
      errorReason: "Loading reports",
      builder: (context, reports) {
        return ListPickerPage<Report>(
          pageTitle: Strings.of(context).reportListPageTitle,
          contentPadding: EdgeInsets.only(left: paddingDefault),
          selectedValues: selectedReport == null ? {} : {selectedReport!},
          items: reports
              .map((r) => ListPickerItem(title: r.name, value: r))
              .toList(),
          onItemPicked: (report) {
            onReportPicked(report);
            Navigator.pop(context);
          },
          trailingBuilder: (item, isSelected) =>
              _buildTrailing(context, item.value!),
        );
      },
    );
  }

  Widget _buildTrailing(BuildContext context, Report report) {
    return IconButton(
      icon: const Icon(Icons.edit),
      color: context.colorApp,
      onPressed: () => present(
        context,
        EditReportPage(
          editingReport: report,
          activities: currentActivities,
          dateRange: currentDateRange,
        ),
      ),
    );
  }
}
