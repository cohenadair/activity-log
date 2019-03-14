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
      onMeasure: (SummarizedActivity activity) =>
          activity.totalDuration.inSeconds,
      primaryAxisSpec: Charts.NumericAxisSpec(
        tickFormatterSpec: _DurationMeasureAxisFormatter(context),
      ),
    );
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

/// A custom formatter for the measure axis, so units can be displayed as "5d"
/// rather than "5".
class _DurationMeasureAxisFormatter extends Charts.SimpleTickFormatterBase<num>
    implements Charts.NumericTickFormatterSpec
{
  final BuildContext context;

  _DurationMeasureAxisFormatter(this.context);

  @override
  String formatValue(num value) {
    Duration duration = Duration(seconds: value.toInt());

    if (duration.inDays > 0) {
      return format(Strings.of(context).daysFormat, [duration.inDays]);
    }

    if (duration.inHours > 0) {
      return format(Strings.of(context).hoursFormat, [duration.inHours]);
    }

    return format(Strings.of(context).minutesFormat, [duration.inMinutes]);
  }

  @override
  Charts.TickFormatter<num> createTickFormatter(Charts.ChartContext context) {
    return _DurationMeasureAxisFormatter(this.context);
  }
}
