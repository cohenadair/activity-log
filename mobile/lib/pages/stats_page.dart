import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/activities_bar_chart.dart';
import 'package:mobile/widgets/activity_picker.dart';
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
  Set<Activity> _currentActivities;
  StatsDateRange _currentDateRange;

  @override
  void initState() {
    super.initState();
    _currentDateRange = StatsDateRange.allDates;
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).statsPageTitle,
      ),
      child: ListView(
        children: <Widget>[
          ActivityPicker(
            app: widget.app,
            initialActivities: _currentActivities,
            onPickedActivitiesChanged: (Set<Activity> pickedActivities) {
              setState(() {
                _currentActivities = pickedActivities;
              });
            },
          ),
          StatsDateRangePicker(
            initialValue: _currentDateRange,
            onDurationPicked: (StatsDateRange pickedDateRange) {
              setState(() {
                _currentDateRange = pickedDateRange;
              });
            },
          ),
          MinDivider(),
          FutureBuilder<SummarizedActivityList>(
            future: widget.app.dataManager.getSummarizedActivities(
              _currentDateRange.value,
              _currentActivities == null ? [] : List.of(_currentActivities),
            ),
            builder: (BuildContext context,
                AsyncSnapshot<SummarizedActivityList> snapshot)
            {
              if (!snapshot.hasData) {
                return Empty();
              }

              List<SummarizedActivity> activities = snapshot.data.activities;
              if (activities == null || activities.isEmpty) {
                return Padding(
                  padding: insetsRowDefault,
                  child: ErrorText(
                    Strings.of(context).statsPageNoDataMessage
                  ),
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
    );
  }

  Widget _buildForMultipleActivities(SummarizedActivityList summary) {
    return Column(
      children: <Widget>[
        _buildSummary(summary),
        ActivitiesDurationBarChart(
          summary.activities,
          padding: insetsVerticalDefault,
        ),
        MinDivider(),
        ActivitiesNumberOfSessionsBarChart(
          summary.activities,
          padding: insetsVerticalDefault,
        ),
      ],
    );
  }

  Widget _buildSummary(SummarizedActivityList summary) {
    if (summary.longestSession == null && summary.mostFrequentActivity == null)
    {
      return Empty();
    }

    return Summary(
      title: Strings.of(context).statsPageSummaryTitle,
      padding: insetsVerticalDefault,
      items: _getSummaryItems(summary),
    );
  }

  List<SummaryItem> _getSummaryItems(SummarizedActivityList summary) {
    List<SummaryItem> result = [];

    if (summary.mostFrequentActivity != null) {
      result.add(SummaryItem(
        title: Strings.of(context).statsPageMostFrequentActivityLabel,
        subtitle: summary.mostFrequentActivity.first.name,
        value: format(
          Strings.of(context).statsPageMostFrequentActivityValue,
          [summary.mostFrequentActivity.second],
        ),
      ));
    }

    if (summary.longestSession != null) {
      result.add(SummaryItem(
        title: Strings.of(context).statsPageLongestSessionLabel,
        subtitle: summary.longestSession.first.name,
        value: formatTotalDuration(
          context: context,
          durations: [summary.longestSession.second.duration],
          includesSeconds: false,
          condensed: true,
          showHighestTwoOnly: true,
        ),
      ));
    }

    return result;
  }

  Widget _buildForSingleActivity(SummarizedActivity activity) {
    return Text("TODO single activity");
  }
}