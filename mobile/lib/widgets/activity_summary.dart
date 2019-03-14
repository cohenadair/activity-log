import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/sessions_line_chart.dart';
import 'package:mobile/widgets/summary.dart';
import 'package:mobile/widgets/widget.dart';

/// A widget displays statistical information about a single [Activity].
class ActivitySummary extends StatelessWidget {
  final SummarizedActivity activity;

  ActivitySummary(this.activity);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Summary(
          title: Strings.of(context).summaryDefaultTitle,
          padding: insetsVerticalDefault,
          items: [],
        ),
        MinDivider(),
        _buildSessionsChart(),
      ],
    );
  }

  Widget _buildSessionsChart() {
    if (activity.sessions == null || activity.sessions.isEmpty) {
      return Empty();
    }

    return SessionsLineChart(
      activity.sessions,
      padding: insetsVerticalDefault,
    );
  }
}