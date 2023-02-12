import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/pages/stats_activity_summary_page.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/activities_bar_chart.dart';
import 'package:mobile/widgets/activity_picker.dart';
import 'package:mobile/widgets/activity_summary.dart';
import 'package:mobile/widgets/loading.dart';
import 'package:mobile/widgets/stats_date_range_picker.dart';
import 'package:mobile/widgets/page.dart' as p;
import 'package:mobile/widgets/summary.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class StatsPage extends StatefulWidget {
  final AppManager app;

  const StatsPage(this.app);

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  final scrollController = ScrollController();

  Set<Activity> _currentActivities = {};
  late DisplayDateRange _currentDateRange;

  late Future<SummarizedActivityList> _summarizedActivityListFuture;
  late Future<int> _activityCountFuture;
  late StreamSubscription<void> _onActivitiesUpdated;

  @override
  void initState() {
    super.initState();

    _currentDateRange = widget.app.preferencesManager.statsDateRange;

    _onActivitiesUpdated = widget.app.dataManager.activitiesUpdatedStream
        .listen((_) => _updateFutures());

    // Retrieve initial activities if needed.
    List<String> selectedIds =
        widget.app.preferencesManager.statsSelectedActivityIds;
    if (selectedIds.isNotEmpty) {
      widget.app.dataManager.getActivities(selectedIds).then((activities) {
        if (activities.isNotEmpty) {
          _currentActivities = Set.of(activities);
        }
        _updateFutures();
      });
    } else {
      _updateFutures();
    }
  }

  @override
  void dispose() {
    _onActivitiesUpdated.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return p.Page(
      appBarStyle: p.PageAppBarStyle(
        title: Strings.of(context).statsPageTitle,
      ),
      child: FutureBuilder<int>(
        future: _activityCountFuture,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) {
            return Empty();
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
                  app: widget.app,
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
                  onDurationPicked: (DisplayDateRange pickedDateRange) {
                    setState(() {
                      _currentDateRange = pickedDateRange;
                      _updateFutures();
                    });
                  },
                ),
                MinDivider(),
                FutureBuilder<SummarizedActivityList>(
                  future: _summarizedActivityListFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<SummarizedActivityList> snapshot) {
                    if (!snapshot.hasData) {
                      return Loading.centered();
                    }

                    List<SummarizedActivity> activities =
                        snapshot.data!.activities;
                    if (activities.isEmpty) {
                      return Padding(
                        padding: insetsDefault,
                        child: ErrorText(
                            Strings.of(context).statsPageNoDataMessage),
                      );
                    }

                    if (activities.length == 1 &&
                        activities.first.displayDateRange !=
                            DisplayDateRange.allDates) {
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

  Widget _buildForMultipleActivities(SummarizedActivityList summary) {
    if (summary.activitiesSortedByDuration == null ||
        summary.activitiesSortedByNumberOfSessions == null) {
      return Empty();
    }

    return Column(
      children: <Widget>[
        _buildSummary(summary),
        MinDivider(),
        ActivitiesDurationBarChart(
          app: widget.app,
          activities: summary.activitiesSortedByDuration!,
          padding: insetsVerticalDefaultHorizontalSmall,
          onSelect: _onSelectChartActivity,
        ),
        MinDivider(),
        ActivitiesNumberOfSessionsBarChart(
          summary.activitiesSortedByNumberOfSessions!,
          padding: insetsVerticalDefaultHorizontalSmall,
          onSelect: _onSelectChartActivity,
        ),
      ],
    );
  }

  void _onSelectChartActivity(SummarizedActivity activity) {
    push(
      context,
      StatsActivitySummaryPage(
        app: widget.app,
        activity: activity,
      ),
    );
  }

  Widget _buildSummary(SummarizedActivityList summary) {
    if (summary.mostFrequentActivity == null ||
        summary.longestSession == null) {
      return Empty();
    }

    return LargestDurationBuilder(
      app: widget.app,
      builder: (BuildContext context, DurationUnit largestDurationUnit) {
        return Summary(
          title: Strings.of(context).summaryDefaultTitle,
          padding: insetsVerticalDefault,
          items: [
            SummaryItem(
              title: Strings.of(context).statsPageTotalDuration,
              value: formatTotalDuration(
                context: context,
                durations: [Duration(milliseconds: summary.totalDuration)],
                includesSeconds: false,
                condensed: true,
                showHighestTwoOnly: true,
                largestDurationUnit: largestDurationUnit,
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
              value: formatTotalDuration(
                context: context,
                durations: [summary.longestSession!.second.duration],
                includesSeconds: false,
                condensed: true,
                showHighestTwoOnly: true,
                largestDurationUnit: largestDurationUnit,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForSingleActivity(SummarizedActivity activity) {
    return ActivitySummary(
      app: widget.app,
      activity: activity,
      scrollController: scrollController,
    );
  }

  void _updateFutures() {
    // Update preferences.
    widget.app.preferencesManager.setStatsDateRange(_currentDateRange);
    widget.app.preferencesManager.setStatsSelectedActivityIds(
        _currentActivities.map((activity) => activity.id).toList());

    List<Activity> activities = List.of(_currentActivities);

    // Pass null for "All dates" so the stats are restricted to the existing
    // sessions, rather than whatever the "All dates" start date is.
    DisplayDateRange? dateRange = _currentDateRange == DisplayDateRange.allDates
        ? null
        : _currentDateRange;
    _summarizedActivityListFuture =
        widget.app.dataManager.getSummarizedActivities(dateRange, activities);

    _activityCountFuture = widget.app.dataManager.activityCount;
  }
}
