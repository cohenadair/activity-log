import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../utils/duration.dart';
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
  final AppDurationUnit largestDurationUnit;
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
              value: formatDurations(
                context: context,
                durations: [averageDurations.overall],
                largestDurationUnit: toLibDurationUnit(largestDurationUnit),
              ),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerDay,
              value: formatDurations(
                context: context,
                durations: [averageDurations.perDay],
                largestDurationUnit: toLibDurationUnit(largestDurationUnit),
              ),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerWeek,
              value: formatDurations(
                context: context,
                durations: [averageDurations.perWeek],
                largestDurationUnit: toLibDurationUnit(largestDurationUnit),
              ),
            ),
            SummaryItem(
              title: Strings.of(context).activitySummaryAveragePerMonth,
              value: formatDurations(
                context: context,
                durations: [averageDurations.perMonth],
                largestDurationUnit: toLibDurationUnit(largestDurationUnit),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
