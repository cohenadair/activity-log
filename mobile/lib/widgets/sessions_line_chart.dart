import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class SessionsLineChart extends StatefulWidget {
  final AppManager app;
  final List<Session> sessions;
  final EdgeInsets padding;

  SessionsLineChart({
    @required this.app,
    this.sessions,
    this.padding = insetsZero
  }) : assert(app != null);

  @override
  _SessionsLineChartState createState() => _SessionsLineChartState();
}

class _SessionsLineChartState extends State<SessionsLineChart> {
  final String _chartId = "ActivitySummaryLineChart";
  final double _height = 250;

  Session _selectedSession;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        children: <Widget>[
          Padding(
            padding: insetsBottomSmall,
            child: LargeHeadingText(
              Strings.of(context).activitySummarySessionTitle,
            ),
          ),
          SafeArea(
            bottom: false,
            child: LargestDurationFutureBuilder(
              app: widget.app,
              builder: (DurationUnit longestDurationUnit) => Column(
                children: <Widget>[
                  _buildLineChart(longestDurationUnit),
                  _buildSessionSummary(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSummary(BuildContext context) {
    if (_selectedSession == null) {
      return Empty();
    }

    return Column(
      children: <Widget>[
        DateDurationText(
          _selectedSession.startDateTime,
          _selectedSession.duration,
          style: Theme.of(context).textTheme.subhead,
        ),
        TimeRangeText(
          startTime: _selectedSession.startTimeOfDay,
          endTime: _selectedSession.endTimeOfDay,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildLineChart(DurationUnit longestDurationUnit) {
    return Container(
      height: _height,
      padding: insetsLeftDefault,
      child: Charts.LineChart(
        _getSeriesList(context),
        animate: false,
        domainAxis: Charts.NumericAxisSpec(
          renderSpec: Charts.NoneRenderSpec(),
        ),
        primaryMeasureAxis: Charts.NumericAxisSpec(
          tickFormatterSpec:
          _DurationAxisFormatter(context, longestDurationUnit),
        ),
        selectionModels: [
          Charts.SelectionModelConfig(
            changedListener: (Charts.SelectionModel model) {
              setState(() {
                _selectedSession = model.selectedDatum.first.datum;
              });
            },
          ),
        ],
        behaviors: _behaviors,
      ),
    );
  }

  List<Charts.Series<Session, int>> _getSeriesList(BuildContext context) {
    return [
      Charts.Series<Session, int>(
        id: _chartId,
        colorFn: (_, __) => Charts.ColorUtil
            .fromDartColor(Theme.of(context).primaryColor),
        domainFn: (_, int index) => index,
        measureFn: (Session session, _) => session.millisecondsDuration,
        data: widget.sessions,
      ),
    ];
  }

  List<Charts.ChartBehavior> get _behaviors {
    List<Charts.ChartBehavior> result = [
      Charts.PanAndZoomBehavior(),
    ];

    int selectedIndex = widget.sessions.indexOf(_selectedSession);
    if (selectedIndex >= 0) {
      result.add(Charts.InitialSelection(selectedDataConfig: [
        new Charts.SeriesDatumConfig(_chartId, selectedIndex)
      ]));
    } else {
      _selectedSession = null;
    }

    return result;
  }
}

/// A custom formatter for the vertical axis, so units can be formatted as a
/// duration, rather than number of milliseconds.
class _DurationAxisFormatter extends Charts.SimpleTickFormatterBase<num>
    implements Charts.NumericTickFormatterSpec
{
  final BuildContext context;
  final DurationUnit largestDurationUnit;

  _DurationAxisFormatter(this.context, this.largestDurationUnit);

  @override
  String formatValue(num value) {
    return formatTotalDuration(
      context: context,
      durations: [Duration(milliseconds: value.toInt())],
      includesDays: false,
      includesSeconds: false,
      largestDurationUnit: largestDurationUnit,
    );
  }

  @override
  Charts.TickFormatter<num> createTickFormatter(Charts.ChartContext context) {
    return _DurationAxisFormatter(this.context, this.largestDurationUnit);
  }
}