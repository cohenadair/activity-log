import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../utils/date_time_utils.dart';
import '../utils/string_utils.dart';
import 'list_item.dart';
import 'summary.dart';

class AverageDurations {
  final Duration overall;
  final Duration perDay;
  final Duration perWeek;
  final Duration perMonth;

  AverageDurations({
    required this.overall,
    required this.perDay,
    required this.perWeek,
    required this.perMonth,
  });
}

class AverageDurationsListItem extends StatelessWidget {
  final ScrollController? scrollController;
  final DurationUnit largestDurationUnit;
  final AverageDurations averageDurations;

  const AverageDurationsListItem({
    this.scrollController,
    required this.largestDurationUnit,
    required this.averageDurations,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionListItem(
      scrollController: scrollController,
      toBottomSafeArea: true,
      title: Text(Strings.of(context).activitySummaryAverageDurations),
      children: <Widget>[
        Summary(
          items: <SummaryItem>[
            SummaryItem(
              title: Strings.of(context).activitySummaryAverageOverall,
              value: formatDuration(
                context,
                averageDurations.overall,
                largestDurationUnit,
              ),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerDay,
              value: formatDuration(
                context,
                averageDurations.perDay,
                largestDurationUnit,
              ),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerWeek,
              value: formatDuration(
                context,
                averageDurations.perWeek,
                largestDurationUnit,
              ),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerMonth,
              value: formatDuration(
                context,
                averageDurations.perMonth,
                largestDurationUnit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
