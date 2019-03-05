import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';

class ActivitiesBarChart extends StatefulWidget {
  final List<SummarizedActivity> activities;

  ActivitiesBarChart(this.activities) : assert(activities.isNotEmpty);

  @override
  _ActivitiesBarChartState createState() => _ActivitiesBarChartState();
}

class _ActivitiesBarChartState extends State<ActivitiesBarChart> {
  final String chartId = "all_activities_chart";

  List<SummarizedActivity> get data => widget.activities;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (data.length * chartBarHeightDefault).toDouble(),
      child: SafeArea(
        child: Charts.BarChart(
          seriesList,
          animate: true,
          vertical: false,
          barRendererDecorator: Charts.BarLabelDecorator<String>(),
          domainAxis: Charts.OrdinalAxisSpec(
            renderSpec: Charts.NoneRenderSpec(),
          ),
          primaryMeasureAxis: Charts.NumericAxisSpec(
            tickFormatterSpec: _MeasureAxisFormatter(context),
          ),
        ),
      ),
    );
  }

  List<Charts.Series<SummarizedActivity, String>> get seriesList {
    return [
      Charts.Series<SummarizedActivity, String>(
        id: chartId,
        data: data,
        domainFn: (SummarizedActivity activity, _) => activity.value.name,
        measureFn: (SummarizedActivity activity, _) =>
            activity.totalDuration.inSeconds,
        colorFn: (_, __) => Charts.ColorUtil
            .fromDartColor(Theme.of(context).primaryColor),
        labelAccessorFn: (SummarizedActivity activity, _) {
          return "${activity.value.name} (${formatTotalDuration(
            context: context,
            durations: [activity.totalDuration],
            includesSeconds: false,
            condensed: true,
            showHighestTwoOnly: true,
          )})";
        },
      ),
    ];
  }
}

/// A custom formatter for the measure axis, so units can be displayed as "5d"
/// rather than "5".
class _MeasureAxisFormatter extends Charts.SimpleTickFormatterBase<num>
    implements Charts.NumericTickFormatterSpec
{
  final BuildContext context;

  _MeasureAxisFormatter(this.context);

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
    return _MeasureAxisFormatter(this.context);
  }
}
