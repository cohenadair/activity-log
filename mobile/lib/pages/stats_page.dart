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
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/summary.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class StatsPage extends StatefulWidget {
  final AppManager app;

  StatsPage(this.app);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final scrollController = ScrollController();

  Set<Activity> _currentActivities;
  DisplayDateRange _currentDateRange = DisplayDateRange.allDates;

  Future<SummarizedActivityList> _summarizedActivityListFuture;
  StreamSubscription<void> _onActivitiesUpdated;

  @override
  void initState() {
    super.initState();

    _onActivitiesUpdated = widget.app.dataManager.activitiesUpdatedStream
        .listen((_) {
          _updateFutures();
        });

    _updateFutures();
  }

  @override
  void dispose() {
    _onActivitiesUpdated.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).statsPageTitle,
      ),
      child: SingleChildScrollView(
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
                  AsyncSnapshot<SummarizedActivityList> snapshot)
              {
                if (!snapshot.hasData) {
                  return Loading.centered();
                }

                List<SummarizedActivity> activities = snapshot.data.activities;
                if (activities == null || activities.isEmpty) {
                  return Padding(
                    padding: insetsRowDefault,
                    child: ErrorText(Strings.of(context)
                        .statsPageNoDataMessage),
                  );
                }

                if (activities.length == 1) {
                  return _buildForSingleActivity(activities.first);
                } else {
                  return _buildForMultipleActivities(snapshot.data);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForMultipleActivities(SummarizedActivityList summary) {
    return Column(
      children: <Widget>[
        _buildSummary(summary),
        MinDivider(),
        ActivitiesDurationBarChart(
          app: widget.app,
          activities: summary.activities,
          padding: insetsVerticalDefaultHorizontalSmall,
          onSelect: _onSelectChartActivity,
        ),
        MinDivider(),
        ActivitiesNumberOfSessionsBarChart(
          summary.activities,
          padding: insetsVerticalDefaultHorizontalSmall,
          onSelect: _onSelectChartActivity,
        ),
      ],
    );
  }

  void _onSelectChartActivity(SummarizedActivity activity) {
    push(context, StatsActivitySummaryPage(
      app: widget.app,
      activity: activity,
    ));
  }

  Widget _buildSummary(SummarizedActivityList summary) {
    return LargestDurationBuilder(
      app: widget.app,
      builder: (BuildContext context, DurationUnit largestDurationUnit) {
        return Summary(
          title: Strings.of(context).summaryDefaultTitle,
          padding: insetsVerticalDefault,
          items: [
            SummaryItem(
              title: Strings.of(context).statsPageMostFrequentActivityLabel,
              subtitle: summary.mostFrequentActivity == null
                  ? null
                  : summary.mostFrequentActivity.first.name,
              value: summary.mostFrequentActivity == null
                  ? Strings.of(context).none
                  : format(
                      Strings.of(context).statsPageMostFrequentActivityValue,
                      [summary.mostFrequentActivity.second],
                    ),
            ),
            SummaryItem(
              title: Strings.of(context).statsPageLongestSessionLabel,
              subtitle: summary.longestSession == null
                  ? null
                  : summary.longestSession.first.name,
              value: summary.longestSession == null
                  ? Strings.of(context).none
                  : formatTotalDuration(
                      context: context,
                      durations: [summary.longestSession.second.duration],
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
    DisplayDateRange dateRange = _currentDateRange ?? DisplayDateRange.allDates;

    List<Activity> activities = _currentActivities == null
        ? []
        : List.of(_currentActivities);

    _summarizedActivityListFuture = widget.app.dataManager
        .getSummarizedActivities(dateRange, activities);
  }
}