import 'dart:async' as Async;

import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  final int durationMillis;
  final Widget Function() childBuilder;
  final bool Function() shouldUpdateCallback;

  Timer({
    @required this.childBuilder,
    this.durationMillis = 1000,
    this.shouldUpdateCallback,
  }) : assert(childBuilder != null);

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  Async.Timer _timer;

  @override
  void initState() {
    _timer = Async.Timer.periodic(
      Duration(milliseconds: widget.durationMillis), (Async.Timer timer) {
        if (widget.shouldUpdateCallback == null ||
            widget.shouldUpdateCallback())
        {
          setState(() {});
        }
      }
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
