import 'package:flutter/material.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/widgets/activity_summary.dart';
import 'package:mobile/widgets/page.dart';

class StatsActivitySummaryPage extends StatelessWidget {
  final SummarizedActivity activity;

  StatsActivitySummaryPage(this.activity) : assert(activity != null);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: activity.value.name,
      ),
      child: SingleChildScrollView(
        child: ActivitySummary(activity),
      ),
    );
  }
}