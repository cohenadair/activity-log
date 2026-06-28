import 'dart:async' as d_async;

import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  final int durationMillis;
  final Widget Function() childBuilder;
  final bool Function()? updatesWidget;

  const Timer({
    required this.childBuilder,
    this.durationMillis = 1000,
    this.updatesWidget,
  });

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  late d_async.Timer _timer;

  @override
  void initState() {
    _timer = d_async.Timer.periodic(
      Duration(milliseconds: widget.durationMillis),
      (d_async.Timer timer) {
        if (widget.updatesWidget?.call() ?? true) {
          setState(() {});
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder();
  }
}
