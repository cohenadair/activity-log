import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:adair_flutter_lib/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/widgets/average_durations_list_item.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/sessions_line_chart.dart';
import 'package:mobile/widgets/summary.dart';
import 'package:mobile/widgets/widget.dart';

import '../utils/duration.dart';

/// A widget displays statistical information about a single [Activity].
class ActivitySummary extends StatelessWidget {
  final SummarizedActivity activity;
  final ScrollController scrollController;

  const ActivitySummary({
    required this.activity,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return LargestDurationBuilder(
      builder: (BuildContext context, AppDurationUnit largestDurationUnit) {
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
                  value: _buildSessionCountValue(context),
                ),
              ],
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
                          context,
                          activity.shortestSession!.startDateTime,
                        ),
                  value: activity.shortestSession == null
                      ? Strings.of(context).none
                      : formatDurations(
                          context: context,
                          durations: [activity.shortestSession!.duration],
                          largestDurationUnit: toLibDurationUnit(
                            largestDurationUnit,
                          ),
                        ),
                ),
                SummaryItem(
                  title: Strings.of(context).activitySummaryLongestSession,
                  subtitle: activity.longestSession == null
                      ? null
                      : formatDateTime(
                          context,
                          activity.longestSession!.startDateTime,
                        ),
                  value: activity.longestSession == null
                      ? Strings.of(context).none
                      : formatDurations(
                          context: context,
                          durations: [activity.longestSession!.duration],
                          largestDurationUnit: toLibDurationUnit(
                            largestDurationUnit,
                          ),
                        ),
                ),
                SummaryItem(
                  title: Strings.of(context).activitySummaryCurrentStreak,
                  subtitle: Strings.of(
                    context,
                  ).activitySummaryStreakDescription,
                  value: activity.currentStreak,
                ),
                SummaryItem(
                  title: Strings.of(context).activitySummaryStreak,
                  subtitle: Strings.of(
                    context,
                  ).activitySummaryStreakDescription,
                  value: activity.longestStreak,
                ),
              ],
            ),
            Summary(
              items: <SummaryItem>[
                SummaryItem(
                  title: Strings.of(context).activitySummaryTotalDuration,
                  value: formatDurations(
                    context: context,
                    durations: [activity.totalDuration],
                    largestDurationUnit: toLibDurationUnit(largestDurationUnit),
                  ),
                ),
              ],
            ),
            AverageDurationsListItem(
              scrollController: scrollController,
              largestDurationUnit: largestDurationUnit,
              averageDurations: activity.averageDurations,
            ),
          ],
        );
      },
    );
  }

  String _buildSessionCountValue(BuildContext context) {
    final totalDays = activity.totalDaysForSessions;
    final percent = totalDays > 0
        ? (activity.sessionCount / totalDays * 100).round()
        : 0;
    final template = totalDays == 1
        ? Strings.of(context).activitySummarySessionCountWithPercentSingular
        : Strings.of(context).activitySummarySessionCountWithPercent;
    return format(template, [activity.sessionCount, totalDays, percent]);
  }

  Widget _buildSessionsChart() {
    return SessionsLineChart(
      sessions: activity.sessions,
      padding: insetsVerticalDefault,
    );
  }
}
