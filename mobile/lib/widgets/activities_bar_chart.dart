import 'package:charts_flutter/flutter.dart' as f_charts;
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

typedef ActivitiesBarChartOnSelectCallback = Function(SummarizedActivity);

class ActivitiesDurationBarChart extends StatelessWidget {
  final AppManager app;
  final EdgeInsets padding;
  final List<SummarizedActivity> activities;
  final ActivitiesBarChartOnSelectCallback onSelect;

  const ActivitiesDurationBarChart({
    required this.app,
    required this.activities,
    required this.padding,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LargestDurationBuilder(
      app: app,
      builder: (BuildContext context, DurationUnit largestDurationUnit) {
        return _ActivitiesBarChart(
          chartId: "ActivitiesDurationBarChart",
          title: Strings.of(context).statsPageDurationTitle,
          padding: padding,
          activities: activities,
          onBuildLabel: (SummarizedActivity activity) =>
              "${activity.value.name} (${formatTotalDuration(
            context: context,
            durations: [activity.totalDuration],
            includesSeconds: false,
            condensed: true,
            showHighestTwoOnly: true,
            largestDurationUnit: largestDurationUnit,
          )})",
          onMeasure: (activity) => activity.totalDuration.inSeconds,
          primaryAxisSpec: f_charts.NumericAxisSpec(
            tickFormatterSpec: _DurationTickFormatter(
              context: context,
              formatCallback: _getFormatCallback(context, largestDurationUnit),
            ),
          ),
          onSelect: onSelect,
        );
      },
    );
  }

  _DurationTickFormatCallback _getFormatCallback(
    BuildContext context,
    DurationUnit largestDurationUnit,
  ) {
    Duration longestDuration = const Duration();

    for (var activity in activities) {
      if (activity.totalDuration > longestDuration) {
        longestDuration = activity.totalDuration;
      }
    }

    if (longestDuration.inDays > 0) {
      // 0d 0h
      return (Duration duration) => formatTotalDuration(
            context: context,
            durations: [duration],
            includesSeconds: false,
            includesMinutes: false,
            largestDurationUnit: largestDurationUnit,
          );
    } else if (longestDuration.inHours > 0) {
      // 0h 0m
      return (Duration duration) => formatTotalDuration(
            context: context,
            durations: [duration],
            includesDays: false,
            includesSeconds: false,
            largestDurationUnit: largestDurationUnit,
          );
    } else {
      // 0m
      return (Duration duration) => formatTotalDuration(
            context: context,
            durations: [duration],
            includesDays: false,
            includesHours: false,
            includesSeconds: false,
            largestDurationUnit: largestDurationUnit,
          );
    }
  }
}

class ActivitiesNumberOfSessionsBarChart extends StatelessWidget {
  final EdgeInsets padding;
  final List<SummarizedActivity> activities;
  final ActivitiesBarChartOnSelectCallback onSelect;

  const ActivitiesNumberOfSessionsBarChart(
    this.activities, {
    required this.padding,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return _ActivitiesBarChart(
      chartId: "ActivitiesNumberOfSessionsBarChart",
      title: Strings.of(context).statsPageNumberOfSessionsTitle,
      padding: padding,
      activities: activities,
      onBuildLabel: (SummarizedActivity activity) =>
          "${activity.value.name} (${activity.numberOfSessions})",
      onMeasure: (SummarizedActivity activity) => activity.numberOfSessions,
      onSelect: onSelect,
    );
  }
}

class _ActivitiesBarChart extends StatelessWidget {
  final String chartId;
  final String title;
  final EdgeInsets padding;
  final List<SummarizedActivity> activities;
  final f_charts.NumericAxisSpec? primaryAxisSpec;
  final ActivitiesBarChartOnSelectCallback onSelect;

  /// Return the quantity value for the given [SummarizedActivity].
  final num Function(SummarizedActivity) onMeasure;

  /// Called when building the label for each bar.
  final String Function(SummarizedActivity) onBuildLabel;

  _ActivitiesBarChart({
    required this.chartId,
    required this.title,
    this.padding = insetsZero,
    required this.activities,
    required this.onMeasure,
    required this.onBuildLabel,
    this.primaryAxisSpec,
    required this.onSelect,
  })  : assert(!isEmpty(chartId)),
        assert(activities.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: <Widget>[
          isEmpty(title) ? Empty() : LargeHeadingText(title),
          SizedBox(
            height: activities.length == 1
                ? chartBarHeightSingle
                : (activities.length * chartBarHeightDefault).toDouble(),
            child: SafeArea(
              child: f_charts.BarChart(
                _getSeriesList(context),
                animate: true,
                vertical: false,
                barRendererDecorator: f_charts.BarLabelDecorator<String>(),
                domainAxis: const f_charts.OrdinalAxisSpec(
                  renderSpec: f_charts.NoneRenderSpec(),
                ),
                primaryMeasureAxis: primaryAxisSpec,
                selectionModels: [
                  f_charts.SelectionModelConfig(
                    changedListener: (f_charts.SelectionModel model) {
                      onSelect(model.selectedDatum.first.datum);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<f_charts.Series<SummarizedActivity, String>> _getSeriesList(
    BuildContext context,
  ) {
    return [
      f_charts.Series<SummarizedActivity, String>(
        id: chartId,
        data: activities,
        domainFn: (SummarizedActivity activity, _) => activity.value.name,
        measureFn: (SummarizedActivity activity, _) => onMeasure(activity),
        colorFn: (_, __) =>
            f_charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
        labelAccessorFn: (SummarizedActivity activity, _) =>
            onBuildLabel(activity),
      ),
    ];
  }
}

typedef _DurationTickFormatCallback = String Function(Duration);

/// A custom formatter for the measure axis, so units can be displayed as "5d"
/// rather than "5".
class _DurationTickFormatter extends f_charts.SimpleTickFormatterBase<num>
    implements f_charts.NumericTickFormatterSpec {
  final BuildContext context;
  final _DurationTickFormatCallback formatCallback;

  _DurationTickFormatter({
    required this.context,
    required this.formatCallback,
  });

  @override
  String formatValue(num value) {
    return formatCallback(Duration(seconds: value.toInt()));
  }

  @override
  f_charts.TickFormatter<num> createTickFormatter(
      f_charts.ChartContext context) {
    return _DurationTickFormatter(
      context: this.context,
      formatCallback: formatCallback,
    );
  }
}
