import 'package:flutter/material.dart';

import 'pages/timers_page.dart';

import 'timer_manager.dart';

void main() => runApp(TimeTracker());

class TimeTracker extends StatelessWidget {
  final TimerManager _timerManager = TimerManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: TimersPage(_timerManager),
    );
  }
}
