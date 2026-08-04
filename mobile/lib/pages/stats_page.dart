import 'dart:async';

import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:adair_flutter_lib/utils/log.dart';
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
import 'package:mobile/widgets/stats_calendar.dart';
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
  // The app bar's actions can show up to 2 icon buttons (save report, save
  // as report), but leading only ever shows 1 (the view toggle). Reserving
  // matching invisible space on each side keeps the title centered on the
  // screen instead of centered within the unequal leading/actions gap.
  static const _iconButtonWidth = kMinInteractiveDimension;

  final _log = Log("StatsPage");

  final scrollController = ScrollController();

  Set<Activity> _currentActivities = {};
  late DateRange _currentDateRange;

  List<Report> _reports = [];
  Report? _selectedReport;

  late bool _showsCalendar;

  // The last successfully loaded data. Kept on screen (rather than reset to
  // null/Loading) across refreshes so the calendar and chart update in place
  // instead of being torn down and rebuilt.
  SummarizedActivityList? _summarizedActivityList;
  int? _activityCount;
  bool _isRefreshing = false;

  // Guards against a slower, earlier full refresh overwriting a newer one.
  // Kept separate from [_sessionUpdateGeneration] so a targeted
  // single-activity refresh can't strand [_isRefreshing] by advancing a
  // generation counter that _updateFutures is still waiting on.
  int _refreshGeneration = 0;

  // Guards against a slower, earlier single-activity refresh overwriting a
  // newer one. See [_refreshGeneration].
  int _sessionUpdateGeneration = 0;

  late StreamSubscription<void> _onActivitiesUpdated;
  late StreamSubscription<SessionEvent> _onSessionEvent;
  late StreamSubscription<void> _onReportsUpdated;
  late StreamSubscription<void> _onSubscriptionUpdated;

  bool get _isFilterModified =>
      _currentActivities.isNotEmpty ||
      _currentDateRange.period != DateRange_Period.allDates;

  DateRange? get _effectiveDateRange =>
      _currentDateRange.period == DateRange_Period.allDates
      ? null
      : _currentDateRange;

  @override
  void initState() {
    super.initState();

    _currentDateRange = PreferencesManager.get.statsDateRange;
    // A persisted calendar preference doesn't apply if the user is no
    // longer Pro; fall back to the chart view in that case.
    _showsCalendar =
        PreferencesManager.get.statsShowsCalendar &&
        !SubscriptionManager.get.isFree;

    _onActivitiesUpdated = DataManager.get.activitiesUpdatedStream.listen(
      (_) => _updateFutures(),
    );

    _onSessionEvent = DataManager.get.sessionStream.listen(_onSessionUpdated);

    _onReportsUpdated = ReportManager.get.reportsUpdatedStream.listen(
      (_) => _reloadReports(),
    );

    _onSubscriptionUpdated = SubscriptionManager.get.stream.listen((_) {
      setState(() {
        _showsCalendar =
            PreferencesManager.get.statsShowsCalendar &&
            !SubscriptionManager.get.isFree;
      });
    });

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
    _onSessionEvent.cancel();
    _onReportsUpdated.cancel();
    _onSubscriptionUpdated.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyPage(
      appBarStyle: MyPageAppBarStyle(
        titleWidget: _buildAppBarTitle(),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildViewToggleButton(),
            const SizedBox(width: _iconButtonWidth),
          ],
        ),
        leadingWidth: _iconButtonWidth * 2,
        actions: [_buildSaveReportButton(), _buildSaveAsButton()],
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_activityCount == null) {
      return const SizedBox();
    }

    if (_activityCount! <= 0) {
      return EmptyPageHelp(
        icon: Icons.show_chart,
        message: Strings.of(context).statsPageNoActivitiesMessage,
      );
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActivityPicker(
              initialActivities: _currentActivities,
              onPickedActivitiesChanged: (Set<Activity> pickedActivities) {
                setState(() => _currentActivities = pickedActivities);
                _updateFutures();
              },
            ),
            StatsDateRangePicker(
              initialValue: _currentDateRange,
              onDurationPicked: (pickedDateRange) {
                setState(() => _currentDateRange = pickedDateRange);
                _updateFutures();
              },
            ),
            MinDivider(),
            Expanded(
              child: IndexedStack(
                index: _showsCalendar ? 1 : 0,
                children: [_buildChartTab(), _buildCalendarTab()],
              ),
            ),
          ],
        ),
        _buildRefreshingIndicator(),
      ],
    );
  }

  Widget _buildRefreshingIndicator() {
    if (!_isRefreshing) {
      return const SizedBox();
    }
    return const Align(
      alignment: Alignment.topCenter,
      child: LinearProgressIndicator(),
    );
  }

  Widget _buildViewToggleButton() {
    return IconButton(
      icon: Icon(_showsCalendar ? Icons.show_chart : Icons.calendar_month),
      tooltip: _showsCalendar
          ? Strings.of(context).statsPageChartTab
          : Strings.of(context).statsPageCalendarTab,
      onPressed: () {
        if (!_showsCalendar && SubscriptionManager.get.isFree) {
          ActivityLogProPage.present(context);
          return;
        }
        setState(() => _showsCalendar = !_showsCalendar);
        PreferencesManager.get.setStatsShowsCalendar(_showsCalendar);
      },
    );
  }

  Widget _buildChartTab() {
    return SingleChildScrollView(
      controller: scrollController,
      child: _buildSummarizedActivities((data, activities) {
        if (activities.length == 1 &&
            (activities.first.dateRange == null ||
                activities.first.dateRange!.period !=
                    DateRange_Period.allDates)) {
          return _buildForSingleActivity(activities.first);
        } else {
          return _buildForMultipleActivities(data);
        }
      }),
    );
  }

  Widget _buildCalendarTab() {
    return _buildSummarizedActivities(
      (data, activities) => StatsCalendar(summarizedActivities: activities),
    );
  }

  Widget _buildSummarizedActivities(
    Widget Function(
      SummarizedActivityList data,
      List<SummarizedActivity> activities,
    )
    builder,
  ) {
    var data = _summarizedActivityList;
    if (data == null) {
      return Loading(isCentered: true);
    }

    if (data.activities.isEmpty) {
      return Padding(
        padding: insetsDefault,
        child: ErrorText(Strings.of(context).statsPageNoDataMessage),
      );
    }

    return builder(data, data.activities);
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
      return const SizedBox(width: _iconButtonWidth, height: _iconButtonWidth);
    }

    return IconButton(
      icon: const Icon(Icons.save_outlined),
      tooltip: Strings.of(context).statsPageSaveReportTooltip,
      onPressed: _isSelectedReportModified ? _saveReport : null,
      disabledColor: context.colorOnAppBarDisabled,
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
      ActivityLogProPage.present(context);
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
      ActivityLogProPage.present(context);
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
        onReportPicked: (report) {
          if (report == null) {
            setState(() => _clearFiltersAndReport());
          } else {
            _applyReport(report);
          }
        },
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
          _clearFiltersAndReport();
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

  void _clearFiltersAndReport() {
    _currentActivities = {};
    _currentDateRange = DateRange(period: DateRange_Period.allDates);
    _clearSelectedReport();
    _updateFutures();
  }

  Future<void> _updateFutures() async {
    PreferencesManager.get.setStatsDateRange(_currentDateRange);
    PreferencesManager.get.setStatsSelectedActivityIds(
      _currentActivities.map((activity) => activity.id).toList(),
    );

    var generation = ++_refreshGeneration;
    setState(() => _isRefreshing = true);

    List<Activity> activities = List.of(_currentActivities);

    // Kick both queries off together rather than awaiting one before
    // starting the other. Each future's error handling is attached
    // immediately, rather than after awaiting the other future first, so an
    // early rejection is never briefly left without a listener (which Dart
    // reports as an unhandled Zone error even though it's caught below).
    Future<SummarizedActivityList?> loadSummarizedActivities() async {
      try {
        return await DataManager.get.getSummarizedActivities(
          _effectiveDateRange,
          activities,
        );
      } catch (e) {
        _log.e(
          e,
          reason: "Failed to load summarized activities for Stats page",
        );
        return null;
      }
    }

    Future<int?> loadActivityCount() async {
      try {
        return await DataManager.get.activityCount;
      } catch (e) {
        _log.e(e, reason: "Failed to load activity count for Stats page");
        return null;
      }
    }

    var summarizedActivityListFuture = loadSummarizedActivities();
    var activityCountFuture = loadActivityCount();

    var summarizedActivityList = await summarizedActivityListFuture;
    var activityCount = await activityCountFuture;

    if (!mounted || generation != _refreshGeneration) {
      return;
    }

    setState(() {
      _isRefreshing = false;
      if (summarizedActivityList != null) {
        _summarizedActivityList = summarizedActivityList;
      }
      if (activityCount != null) {
        _activityCount = activityCount;
      }
    });
  }

  /// Refreshes only the single [Activity] affected by [event], instead of
  /// re-querying and recalculating every currently displayed activity. Falls
  /// back to doing nothing if the affected activity isn't currently
  /// displayed, or if the cached data doesn't match the current filter (a
  /// full refresh is already in flight via [_onActivitiesUpdated] in that
  /// case).
  Future<void> _onSessionUpdated(SessionEvent event) async {
    var currentList = _summarizedActivityList;
    if (currentList == null || currentList.dateRange != _effectiveDateRange) {
      return;
    }

    var index = currentList.activities.indexWhere(
      (summarized) => summarized.value.id == event.session.activityId,
    );
    if (index < 0) {
      return;
    }

    var generation = ++_sessionUpdateGeneration;

    SummarizedActivity? updatedActivity;
    try {
      updatedActivity = await DataManager.get.getSummarizedActivity(
        currentList.activities[index].value,
        _effectiveDateRange,
      );
    } catch (e) {
      _log.e(e, reason: "Failed to refresh activity for Stats page");
    }

    if (!mounted ||
        generation != _sessionUpdateGeneration ||
        updatedActivity == null) {
      return;
    }

    var updatedActivities = List.of(currentList.activities);
    updatedActivities[index] = updatedActivity;

    setState(() {
      _summarizedActivityList = SummarizedActivityList(
        updatedActivities,
        currentList.dateRange,
      );
    });
  }
}
