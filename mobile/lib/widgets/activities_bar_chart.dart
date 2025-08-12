import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as f_charts;
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/widgets/text.dart';
import 'package:quiver/strings.dart';

import '../utils/chart_utils.dart';
import '../utils/duration.dart';

typedef ActivitiesBarChartOnSelectCallback = Function(SummarizedActivity);

class ActivitiesDurationBarChart extends StatelessWidget {
  final EdgeInsets padding;
  final List<SummarizedActivity> activities;
  final ActivitiesBarChartOnSelectCallback onSelect;

  const ActivitiesDurationBarChart({
    required this.activities,
    required this.padding,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LargestDurationBuilder(
      builder: (BuildContext context, AppDurationUnit largestDurationUnit) {
        return _ActivitiesBarChart(
          chartId: "ActivitiesDurationBarChart",
          title: Strings.of(context).statsPageDurationTitle,
          padding: padding,
          activities: activities,
          onBuildLabel: (SummarizedActivity activity) {
            var durationText = formatDurations(
              context: context,
              durations: [activity.totalDuration],
              includesSeconds: false,
              condensed: true,
              numberOfQuantities: 2,
              largestDurationUnit: toLibDurationUnit(largestDurationUnit),
            );
            return "${activity.value.name} ($durationText)";
          },
          onMeasure: (activity) => activity.totalDuration.inSeconds,
          primaryAxisTickFormatterSpec: _DurationTickFormatter(
            context: context,
            formatCallback: _getFormatCallback(context, largestDurationUnit),
          ),
          onSelect: onSelect,
        );
      },
    );
  }

  _DurationTickFormatCallback _getFormatCallback(
    BuildContext context,
    AppDurationUnit largestDurationUnit,
  ) {
    Duration longestDuration = const Duration();

    for (var activity in activities) {
      if (activity.totalDuration > longestDuration) {
        longestDuration = activity.totalDuration;
      }
    }

    if (longestDuration.inDays > 0) {
      // 0d 0h
      return (Duration duration) => formatDurations(
            context: context,
            durations: [duration],
            includesSeconds: false,
            includesMinutes: false,
            largestDurationUnit: toLibDurationUnit(largestDurationUnit),
          );
    } else if (longestDuration.inHours > 0) {
      // 0h 0m
      return (Duration duration) => formatDurations(
            context: context,
            durations: [duration],
            includesDays: false,
            includesSeconds: false,
            largestDurationUnit: toLibDurationUnit(largestDurationUnit),
          );
    } else {
      // 0m
      return (Duration duration) => formatDurations(
            context: context,
            durations: [duration],
            includesDays: false,
            includesHours: false,
            includesSeconds: false,
            largestDurationUnit: toLibDurationUnit(largestDurationUnit),
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

class _ActivitiesBarChart extends StatefulWidget {
  final String chartId;
  final String title;
  final EdgeInsets padding;
  final List<SummarizedActivity> activities;
  final f_charts.NumericTickFormatterSpec? primaryAxisTickFormatterSpec;
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
    this.primaryAxisTickFormatterSpec,
    required this.onSelect,
  })  : assert(!isEmpty(chartId)),
        assert(activities.isNotEmpty);

  @override
  State<_ActivitiesBarChart> createState() => _ActivitiesBarChartState();
}

class _ActivitiesBarChartState extends State<_ActivitiesBarChart> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        children: <Widget>[
          isEmpty(widget.title)
              ? const SizedBox()
              : LargeHeadingText(widget.title),
          SizedBox(
            height: widget.activities.length == 1
                ? chartBarHeightSingle
                : (widget.activities.length * chartBarHeightDefault).toDouble(),
            child: SafeArea(
              child: f_charts.BarChart(
                _getSeriesList(context),
                animate: true,
                vertical: false,
                barRendererDecorator: f_charts.BarLabelDecorator<String>(),
                domainAxis: const f_charts.OrdinalAxisSpec(
                  renderSpec: f_charts.NoneRenderSpec(),
                ),
                primaryMeasureAxis: f_charts.NumericAxisSpec(
                  tickFormatterSpec: widget.primaryAxisTickFormatterSpec,
                  renderSpec: defaultChartRenderSpec(context),
                ),
                selectionModels: [
                  f_charts.SelectionModelConfig(
                    changedListener: (f_charts.SelectionModel model) {
                      widget.onSelect(model.selectedDatum.first.datum);
                      // Reload to ensure bar is deselected.
                      setState(() {});
                    },
                  ),
                ],
                userManagedState: f_charts.UserManagedState()
                  ..selectionModels.addAll({}),
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
        id: widget.chartId,
        data: widget.activities,
        domainFn: (SummarizedActivity activity, _) => activity.value.name,
        measureFn: (SummarizedActivity activity, _) =>
            widget.onMeasure(activity),
        colorFn: (_, __) =>
            f_charts.ColorUtil.fromDartColor(AppConfig.get.colorAppTheme),
        labelAccessorFn: (SummarizedActivity activity, _) =>
            widget.onBuildLabel(activity),
        outsideLabelStyleAccessorFn: (_, __) => f_charts.TextStyleSpec(
          color: f_charts.ColorUtil.fromDartColor(context.colorText),
        ),
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

  _DurationTickFormatter({required this.context, required this.formatCallback});

  @override
  String formatValue(num value) {
    return formatCallback(Duration(seconds: value.toInt()));
  }

  @override
  f_charts.TickFormatter<num> createTickFormatter(
    f_charts.ChartContext context,
  ) {
    return _DurationTickFormatter(
      context: this.context,
      formatCallback: formatCallback,
    );
  }
}
