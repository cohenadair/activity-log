import 'package:flutter/material.dart';

import 'pages/activities_page.dart';

import 'activity_manager.dart';

void main() => runApp(ActivityTracker());

class ActivityTracker extends StatelessWidget {
  final ActivityManager _activityManager = ActivityManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ActivitiesPage(_activityManager),
    );
  }
}
