import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/widgets/activity_summary.dart';
import 'package:mobile/widgets/my_page.dart' as p;

class StatsActivitySummaryPage extends StatelessWidget {
  final SummarizedActivity activity;
  final scrollController = ScrollController();

  StatsActivitySummaryPage({required this.activity});

  @override
  Widget build(BuildContext context) {
    return p.MyPage(
      appBarStyle: p.MyPageAppBarStyle(
        title: activity.value.name,
        subtitle: activity.displayDateRange == null
            ? DisplayDateRange.allDates.onTitle(context)
            : activity.displayDateRange!.onTitle(context),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: ActivitySummary(
          activity: activity,
          scrollController: scrollController,
        ),
      ),
    );
  }
}
