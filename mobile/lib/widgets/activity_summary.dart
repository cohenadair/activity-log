import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/sessions_line_chart.dart';
import 'package:mobile/widgets/summary.dart';
import 'package:mobile/widgets/widget.dart';

/// A widget displays statistical information about a single [Activity].
class ActivitySummary extends StatelessWidget {
  final SummarizedActivity activity;

  ActivitySummary(this.activity);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSessionsChart(),
        MinDivider(),
        Summary(
          title: Strings.of(context).summaryDefaultTitle,
          padding: insetsVerticalDefault,
          items: [
            SummaryItem(
              title: Strings.of(context).activitySummaryNumberOfSessions,
              value: activity.numberOfSessions,
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryTotalDuration,
              value: _formatDuration(context, activity.totalDuration),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAverageOverall,
              value: _formatDuration(context, activity.averageDurationOverall),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerDay,
              value: _formatDuration(context, activity.averageDurationPerDay),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerWeek,
              value: _formatDuration(context, activity.averageDurationPerWeek),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerMonth,
              value: _formatDuration(context, activity.averageDurationPerMonth),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryShortestSession,
              subtitle: activity.shortestSession == null
                  ? null
                  : formatDateTime(
                    context: context,
                    dateTime: activity.shortestSession.startDateTime,
                  ),
              value: activity.shortestSession == null
                  ? Strings.of(context).none
                  : _formatDuration(context, activity.shortestSession.duration),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryLongestSession,
              subtitle: activity.longestSession == null
                  ? null
                  : formatDateTime(
                    context: context,
                    dateTime: activity.longestSession.startDateTime,
                  ),
              value: activity.longestSession == null
                  ? Strings.of(context).none
                  : _formatDuration(context, activity.longestSession.duration),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryStreak,
              subtitle: Strings.of(context).activitySummaryStreakDescription,
              value: activity.longestStreak,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(BuildContext context, Duration duration) {
    return formatTotalDuration(
      context: context,
      durations: [duration],
      condensed: true,
      showHighestTwoOnly: true,
    );
  }

  Widget _buildSessionsChart() {
    return SessionsLineChart(
      activity.sessions == null ? [] : activity.sessions,
      padding: insetsVerticalDefault,
    );
  }
}