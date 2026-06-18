import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
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

  /// Called when the user picks a report from the list. A null value indicates
  /// the "Default" item was picked, which should reset all filters.
  final void Function(Report?) onReportPicked;

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
        return ListPickerPage<Report?>(
          pageTitle: Strings.of(context).reportListPageTitle,
          contentPadding: EdgeInsets.only(left: paddingDefault),
          selectedValues: {selectedReport},
          allItem: ListPickerItem<Report?>(
            title: Strings.of(context).reportListPageDefaultItem,
            subtitle:
                "${Strings.of(context).activityDropdownAllActivities} · ${DateRange(period: DateRange_Period.allDates).displayName}",
            onTap: () async {
              onReportPicked(null);
              Navigator.pop(context);
              return null;
            },
          ),
          items: [
            ...reports.map(
              (r) => ListPickerItem<Report?>(title: r.name, value: r),
            ),
          ],
          onItemPicked: (report) {
            onReportPicked(report);
            Navigator.pop(context);
          },
          trailingBuilder: (item, isSelected) {
            if (item.value == null) {
              return const SizedBox();
            }
            return _buildTrailing(context, item.value!);
          },
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
