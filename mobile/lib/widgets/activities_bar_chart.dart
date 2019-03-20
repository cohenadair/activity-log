import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class ActivitiesDurationBarChart extends StatelessWidget {
  final EdgeInsets padding;
  final List<SummarizedActivity> activities;

  ActivitiesDurationBarChart(this.activities, {
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
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
        )})",
      onMeasure: (activity) => activity.totalDuration.inSeconds,
      primaryAxisSpec: Charts.NumericAxisSpec(
        tickFormatterSpec: _DurationTickFormatter(
          context: context,
          formatCallback: _getFormatCallback(context),
        ),
      ),
    );
  }

  _DurationTickFormatCallback _getFormatCallback(BuildContext context) {
    Duration longestDuration = Duration();

    activities.forEach((SummarizedActivity activity) {
      if (activity.totalDuration != null
          && activity.totalDuration > longestDuration)
      {
        longestDuration = activity.totalDuration;
      }
    });

    if (longestDuration.inDays > 0) {
      // 0d 0h
      return (Duration duration) => formatTotalDuration(
        context: context,
        durations: [duration],
        includesSeconds: false,
        includesMinutes: false,
      );
    } else if (longestDuration.inHours > 0) {
      // 0h 0m
      return (Duration duration) => formatTotalDuration(
        context: context,
        durations: [duration],
        includesDays: false,
        includesSeconds: false,
      );
    } else {
      // 0m
      return (Duration duration) => formatTotalDuration(
        context: context,
        durations: [duration],
        includesDays: false,
        includesHours: false,
        includesSeconds: false,
      );
    }
  }
}

class ActivitiesNumberOfSessionsBarChart extends StatelessWidget {
  final EdgeInsets padding;
  final List<SummarizedActivity> activities;

  ActivitiesNumberOfSessionsBarChart(this.activities, {
    this.padding,
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
    );
  }
}

class _ActivitiesBarChart extends StatelessWidget {
  final String chartId;
  final String title;
  final EdgeInsets padding;
  final List<SummarizedActivity> activities;
  final Charts.AxisSpec primaryAxisSpec;

  /// Return the quantity value for the given [SummarizedActivity].
  final num Function(SummarizedActivity) onMeasure;

  /// Called when building the label for each bar.
  final String Function(SummarizedActivity) onBuildLabel;

  _ActivitiesBarChart({
    @required this.chartId,
    this.title,
    this.padding = insetsZero,
    this.activities,
    this.onMeasure,
    this.onBuildLabel,
    this.primaryAxisSpec,
  }) : assert(!isEmpty(chartId)),
       assert(activities.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: <Widget>[
          title == null ? Empty() : LargeHeadingText(title),
          Container(
            height: activities.length == 1
                ? chartBarHeightSingle
                : (activities.length * chartBarHeightDefault).toDouble(),
            child: SafeArea(
              child: Charts.BarChart(
                _getSeriesList(context),
                animate: true,
                vertical: false,
                barRendererDecorator: Charts.BarLabelDecorator<String>(),
                domainAxis: Charts.OrdinalAxisSpec(
                  renderSpec: Charts.NoneRenderSpec(),
                ),
                primaryMeasureAxis: primaryAxisSpec,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Charts.Series<SummarizedActivity, String>>
      _getSeriesList(BuildContext context)
  {
    return [
      Charts.Series<SummarizedActivity, String>(
        id: chartId,
        data: activities,
        domainFn: (SummarizedActivity activity, _) => activity.value.name,
        measureFn: (SummarizedActivity activity, _) => onMeasure(activity),
        colorFn: (_, __) => Charts.ColorUtil
            .fromDartColor(Theme.of(context).primaryColor),
        labelAccessorFn: (SummarizedActivity activity, _) =>
            onBuildLabel(activity),
      ),
    ];
  }
}

typedef _DurationTickFormatCallback = String Function(Duration);

/// A custom formatter for the measure axis, so units can be displayed as "5d"
/// rather than "5".
class _DurationTickFormatter extends Charts.SimpleTickFormatterBase<num>
    implements Charts.NumericTickFormatterSpec
{
  final BuildContext context;
  final _DurationTickFormatCallback formatCallback;

  _DurationTickFormatter({
    this.context,
    this.formatCallback,
  });

  @override
  String formatValue(num value) {
    return formatCallback(Duration(seconds: value.toInt()));
  }

  @override
  Charts.TickFormatter<num> createTickFormatter(Charts.ChartContext context) {
    return _DurationTickFormatter(
      context: this.context,
      formatCallback: formatCallback,
    );
  }
}
