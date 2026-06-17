import 'dart:async';

import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:adair_flutter_lib/utils/string.dart';
import 'package:adair_flutter_lib/widgets/app_bar_dropdown.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';
import 'package:mobile/pages/edit_report_page.dart';
import 'package:mobile/pages/report_list_page.dart';
import 'package:mobile/pages/stats_activity_summary_page.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/widgets/activities_bar_chart.dart';
import 'package:mobile/widgets/activity_picker.dart';
import 'package:mobile/widgets/activity_summary.dart';
import 'package:mobile/widgets/average_durations_list_item.dart';
import 'package:mobile/widgets/my_page.dart';
import 'package:mobile/widgets/stats_date_range_picker.dart';
import 'package:mobile/widgets/summary.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../database/data_manager.dart';
import '../utils/duration.dart';

class StatsPage extends StatefulWidget {
  const StatsPage();

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  final scrollController = ScrollController();

  Set<Activity> _currentActivities = {};
  late DateRange _currentDateRange;

  List<Report> _reports = [];
  Report? _selectedReport;

  late Future<SummarizedActivityList> _summarizedActivityListFuture;
  late StreamSubscription<void> _onActivitiesUpdated;
  late StreamSubscription<void> _onReportsUpdated;
  Future<int> _activityCountFuture = Future.value(0);

  bool get _isFilterModified =>
      _currentActivities.isNotEmpty ||
      _currentDateRange.period != DateRange_Period.allDates;

  @override
  void initState() {
    super.initState();

    _currentDateRange = PreferencesManager.get.statsDateRange;

    _onActivitiesUpdated = DataManager.get.activitiesUpdatedStream.listen(
      (_) => _updateFutures(),
    );

    _onReportsUpdated = ReportManager.get.reportsUpdatedStream.listen(
      (_) => _reloadReports(),
    );

    List<String> selectedIds = PreferencesManager.get.statsSelectedActivityIds;
    if (selectedIds.isNotEmpty) {
      DataManager.get.getActivities(selectedIds).then((activities) {
        if (activities.isNotEmpty) {
          _currentActivities = Set.of(activities);
        }
        _updateFutures();
      });
    } else {
      _updateFutures();
    }

    ReportManager.get.reports().then((reports) {
      if (!mounted) {
        return;
      }

      setState(() {
        _reports = reports;

        final savedId = PreferencesManager.get.selectedReportId;
        if (savedId != null) {
          _selectedReport = reports.where((r) => r.id == savedId).firstOrNull;
        }
      });
    });
  }

  @override
  void dispose() {
    _onActivitiesUpdated.cancel();
    _onReportsUpdated.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyPage(
      appBarStyle: MyPageAppBarStyle(
        titleWidget: _buildAppBarTitle(),
        actions: [_buildSaveReportButton(), _buildSaveAsButton()],
      ),
      child: FutureBuilder<int>(
        future: _activityCountFuture,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          int activityCount = snapshot.data!;
          if (activityCount <= 0) {
            return EmptyPageHelp(
              icon: Icons.show_chart,
              message: Strings.of(context).statsPageNoActivitiesMessage,
            );
          }

          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityPicker(
                  initialActivities: _currentActivities,
                  onPickedActivitiesChanged: (Set<Activity> pickedActivities) {
                    setState(() {
                      _currentActivities = pickedActivities;
                      _updateFutures();
                    });
                  },
                ),
                StatsDateRangePicker(
                  initialValue: _currentDateRange,
                  onDurationPicked: (pickedDateRange) {
                    setState(() {
                      _currentDateRange = pickedDateRange;
                      _updateFutures();
                    });
                  },
                ),
                MinDivider(),
                FutureBuilder<SummarizedActivityList>(
                  future: _summarizedActivityListFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Loading(isCentered: true);
                    }

                    List<SummarizedActivity> activities =
                        snapshot.data!.activities;
                    if (activities.isEmpty) {
                      return Padding(
                        padding: insetsDefault,
                        child: ErrorText(
                          Strings.of(context).statsPageNoDataMessage,
                        ),
                      );
                    }

                    if (activities.length == 1 &&
                        (activities.first.dateRange == null ||
                            activities.first.dateRange!.period !=
                                DateRange_Period.allDates)) {
                      return _buildForSingleActivity(activities.first);
                    } else {
                      return _buildForMultipleActivities(snapshot.data!);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarTitle() {
    if (_reports.isEmpty || SubscriptionManager.get.isFree) {
      return Text(Strings.of(context).statsPageTitle);
    }

    return AppBarDropdown(
      title: _selectedReport?.name ?? Strings.of(context).statsPageTitle,
      onTap: _openReportList,
    );
  }

  Widget _buildSaveReportButton() {
    if (_selectedReport == null || SubscriptionManager.get.isFree) {
      return const SizedBox();
    }

    return IconButton(
      icon: const Icon(Icons.save_outlined),
      tooltip: Strings.of(context).statsPageSaveReportTooltip,
      onPressed: _isSelectedReportModified ? _saveReport : null,
    );
  }

  Widget _buildSaveAsButton() {
    return IconButton(
      icon: const Icon(Icons.bookmark_add_outlined),
      tooltip: Strings.of(context).statsPageSaveAsReportTooltip,
      onPressed: _isFilterModified ? _openSaveReport : null,
    );
  }

  bool get _isSelectedReportModified {
    if (_selectedReport == null) {
      return false;
    }

    final sameActivities = const SetEquality<String>().equals(
      _currentActivities.map((a) => a.id).toSet(),
      _selectedReport!.activityIds.toSet(),
    );
    return !sameActivities || _currentDateRange != _selectedReport!.dateRange;
  }

  Future<void> _saveReport() async {
    if (SubscriptionManager.get.isFree) {
      present(context, ActivityLogProPage());
      return;
    }

    final updated = ReportBuilder.fromReport(_selectedReport!)
      ..activityIds = _currentActivities.map((a) => a.id).toList()
      ..dateRange = _currentDateRange;
    final report = updated.build;

    await ReportManager.get.updateReport(report);

    if (!mounted) {
      return;
    }

    setState(() => _selectedReport = report);

    showSuccessSnackBar(
      context,
      Strings.of(context).statsPageSaveReportSuccess,
    );
  }

  Widget _buildForMultipleActivities(SummarizedActivityList summary) {
    if (summary.activitiesSortedByDuration == null ||
        summary.activitiesSortedByNumberOfSessions == null) {
      return const SizedBox();
    }

    return Column(
      children: <Widget>[
        _buildSummary(summary),
        MinDivider(),
        ActivitiesDurationBarChart(
          activities: summary.activitiesSortedByDuration!,
          padding: insetsHorizontalSmallVerticalDefault,
          onSelect: _onSelectChartActivity,
        ),
        MinDivider(),
        ActivitiesNumberOfSessionsBarChart(
          summary.activitiesSortedByNumberOfSessions!,
          padding: insetsHorizontalSmallVerticalDefault,
          onSelect: _onSelectChartActivity,
        ),
      ],
    );
  }

  void _onSelectChartActivity(SummarizedActivity activity) {
    push(context, StatsActivitySummaryPage(activity: activity));
  }

  Widget _buildSummary(SummarizedActivityList summary) {
    if (summary.mostFrequentActivity == null ||
        summary.longestSession == null) {
      return const SizedBox();
    }

    return LargestDurationBuilder(
      builder: (BuildContext context, AppDurationUnit largestDurationUnit) {
        return Column(
          children: [
            Summary(
              title: Strings.of(context).summaryDefaultTitle,
              padding: insetsTopDefault,
            ),
            AverageDurationsListItem(
              largestDurationUnit: largestDurationUnit,
              averageDurations: summary.averageDurations,
            ),
            Summary(
              items: [
                SummaryItem(
                  title: Strings.of(context).statsPageTotalDuration,
                  value: formatDurations(
                    context: context,
                    durations: [Duration(milliseconds: summary.totalDuration)],
                    includesSeconds: false,
                    condensed: true,
                    numberOfQuantities: 2,
                    largestDurationUnit: toLibDurationUnit(largestDurationUnit),
                  ),
                ),
                SummaryItem(
                  title: Strings.of(context).statsPageMostFrequentActivityLabel,
                  subtitle: summary.mostFrequentActivity!.first.name,
                  value: format(
                    Strings.of(context).statsPageMostFrequentActivityValue,
                    [summary.mostFrequentActivity!.second],
                  ),
                ),
                SummaryItem(
                  title: Strings.of(context).statsPageLongestSessionLabel,
                  subtitle: summary.longestSession!.first.name,
                  value: formatDurations(
                    context: context,
                    durations: [summary.longestSession!.second.duration],
                    includesSeconds: false,
                    condensed: true,
                    numberOfQuantities: 2,
                    largestDurationUnit: toLibDurationUnit(largestDurationUnit),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildForSingleActivity(SummarizedActivity activity) {
    return ActivitySummary(
      activity: activity,
      scrollController: scrollController,
    );
  }

  void _openSaveReport() {
    if (SubscriptionManager.get.isFree) {
      present(context, ActivityLogProPage());
      return;
    }

    present(
      context,
      EditReportPage(
        activities: _currentActivities,
        dateRange: _currentDateRange,
        onSaved: _applyReport,
      ),
    );
  }

  void _openReportList() {
    present(
      context,
      ReportListPage(
        selectedReport: _selectedReport,
        currentActivities: _currentActivities,
        currentDateRange: _currentDateRange,
        onReportPicked: _applyReport,
      ),
    );
  }

  Future<void> _applyReport(Report report) async {
    final activities = await DataManager.get.getActivities(report.activityIds);

    if (!mounted) {
      return;
    }

    setState(() {
      _currentActivities = Set.of(activities);
      _currentDateRange = report.dateRange;
      _selectedReport = report;
      PreferencesManager.get.setSelectedReportId(report.id);

      _updateFutures();
    });
  }

  Future<void> _reloadReports() async {
    final reports = await ReportManager.get.reports();

    if (!mounted) {
      return;
    }

    setState(() {
      _reports = reports;

      if (_selectedReport != null) {
        final updated = reports.where((r) => r.id == _selectedReport!.id);

        if (updated.isEmpty) {
          _clearSelectedReport();
          _currentActivities = {};
          _currentDateRange = DateRange(period: DateRange_Period.allDates);
          _updateFutures();
        } else {
          _selectedReport = updated.first;
        }
      }
    });
  }

  void _clearSelectedReport() {
    _selectedReport = null;
    PreferencesManager.get.setSelectedReportId(null);
  }

  void _updateFutures() {
    PreferencesManager.get.setStatsDateRange(_currentDateRange);
    PreferencesManager.get.setStatsSelectedActivityIds(
      _currentActivities.map((activity) => activity.id).toList(),
    );

    List<Activity> activities = List.of(_currentActivities);

    var dateRange = _currentDateRange.period == DateRange_Period.allDates
        ? null
        : _currentDateRange;
    _summarizedActivityListFuture = DataManager.get.getSummarizedActivities(
      dateRange,
      activities,
    );

    _activityCountFuture = DataManager.get.activityCount;
  }
}
