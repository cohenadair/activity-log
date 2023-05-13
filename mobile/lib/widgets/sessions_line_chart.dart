import 'package:community_charts_flutter/community_charts_flutter.dart'
    as f_charts;
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../utils/chart_utils.dart';

class SessionsLineChart extends StatefulWidget {
  final AppManager app;
  final List<Session> sessions;
  final EdgeInsets padding;

  const SessionsLineChart({
    required this.app,
    this.sessions = const [],
    this.padding = insetsZero,
  });

  @override
  SessionsLineChartState createState() => SessionsLineChartState();
}

class SessionsLineChartState extends State<SessionsLineChart> {
  final String _chartId = "ActivitySummaryLineChart";
  final double _height = 250;

  Session? _selectedSession;

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
            child: LargestDurationBuilder(
              app: widget.app,
              builder: (BuildContext context, DurationUnit unit) => Column(
                children: <Widget>[
                  _buildLineChart(unit),
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
          _selectedSession!.startDateTime,
          _selectedSession!.duration,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TimeRangeText(
          startTime: _selectedSession!.startTimeOfDay,
          endTime: _selectedSession!.endTimeOfDay,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildLineChart(DurationUnit longestDurationUnit) {
    return Container(
      height: _height,
      padding: insetsLeftDefault,
      child: f_charts.LineChart(
        _getSeriesList(context),
        animate: true,
        domainAxis: const f_charts.NumericAxisSpec(
          renderSpec: f_charts.NoneRenderSpec(),
        ),
        primaryMeasureAxis: f_charts.NumericAxisSpec(
          tickFormatterSpec:
              _DurationAxisFormatter(context, longestDurationUnit),
          renderSpec: defaultChartRenderSpec(context),
        ),
        selectionModels: [
          f_charts.SelectionModelConfig(
            changedListener: (f_charts.SelectionModel model) {
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

  List<f_charts.Series<Session, int>> _getSeriesList(BuildContext context) {
    return [
      f_charts.Series<Session, int>(
        id: _chartId,
        colorFn: (_, __) => f_charts.ColorUtil.fromDartColor(colorAppTheme),
        domainFn: (_, int? index) => index ?? 0,
        measureFn: (Session session, _) => session.millisecondsDuration,
        data: widget.sessions,
      ),
    ];
  }

  List<f_charts.ChartBehavior<num>> get _behaviors {
    List<f_charts.ChartBehavior<num>> result = [
      f_charts.PanAndZoomBehavior(),
    ];

    int? selectedIndex = _selectedSession == null
        ? null
        : widget.sessions.indexOf(_selectedSession!);
    if (selectedIndex != null) {
      result.add(f_charts.InitialSelection(selectedDataConfig: [
        f_charts.SeriesDatumConfig(_chartId, selectedIndex)
      ]));
    } else {
      _selectedSession = null;
    }

    return result;
  }
}

/// A custom formatter for the vertical axis, so units can be formatted as a
/// duration, rather than number of milliseconds.
class _DurationAxisFormatter extends f_charts.SimpleTickFormatterBase<num>
    implements f_charts.NumericTickFormatterSpec {
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
  f_charts.TickFormatter<num> createTickFormatter(
    f_charts.ChartContext context,
  ) {
    return _DurationAxisFormatter(this.context, largestDurationUnit);
  }
}
