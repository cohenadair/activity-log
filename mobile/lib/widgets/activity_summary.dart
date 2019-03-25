import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/sessions_line_chart.dart';
import 'package:mobile/widgets/summary.dart';
import 'package:mobile/widgets/widget.dart';

/// A widget displays statistical information about a single [Activity].
class ActivitySummary extends StatelessWidget {
  final SummarizedActivity activity;
  final ScrollController scrollController;

  ActivitySummary({
    this.activity,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSessionsChart(),
        MinDivider(),
        Summary(
          title: Strings.of(context).summaryDefaultTitle,
          padding: insetsTopDefault,
          items: <SummaryItem>[
            SummaryItem(
              title: Strings.of(context).activitySummaryNumberOfSessions,
              value: activity.numberOfSessions,
            ),
          ]
        ),
        ExpansionListItem(
          scrollController: scrollController,
          title: Text(Strings.of(context).activitySummaryAverageSessions),
          children: <Widget>[
            Summary(
              items: <SummaryItem>[
                SummaryItem(
                  title: Strings.of(context).activitySummaryAveragePerDay,
                  value: activity.sessionsPerDay.toStringAsFixed(2),
                ),
                SummaryItem(
                  title: Strings.of(context).activitySummaryAveragePerWeek,
                  value: activity.sessionsPerWeek.toStringAsFixed(2),
                ),
                SummaryItem(
                  title: Strings.of(context).activitySummaryAveragePerMonth,
                  value: activity.sessionsPerMonth.toStringAsFixed(2),
                ),
              ],
            ),
          ],
        ),
        Summary(
          items: <SummaryItem>[
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
          ]
        ),
        Summary(
          items: <SummaryItem>[
            SummaryItem(
              title: Strings.of(context).activitySummaryTotalDuration,
              value: _formatDuration(context, activity.totalDuration),
            ),
          ]
        ),
        ExpansionListItem(
          scrollController: scrollController,
          toBottomSafeArea: true,
          title: Text(Strings.of(context).activitySummaryAverageDurations),
          children: <Widget>[
            Summary(
              items: <SummaryItem>[
                SummaryItem(
                  title: Strings.of(context).activitySummaryAverageOverall,
                  value: _formatDuration(context,
                      activity.averageDurationOverall),
                ),
                SummaryItem(
                  title: Strings.of(context).activitySummaryAveragePerDay,
                  value: _formatDuration(context,
                      activity.averageDurationPerDay),
                ),
                SummaryItem(
                  title: Strings.of(context).activitySummaryAveragePerWeek,
                  value: _formatDuration(context,
                      activity.averageDurationPerWeek),
                ),
                SummaryItem(
                  title: Strings.of(context).activitySummaryAveragePerMonth,
                  value: _formatDuration(context,
                      activity.averageDurationPerMonth),
                ),
              ],
            ),
          ],
        )
      ]
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