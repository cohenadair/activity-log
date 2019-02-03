import 'dart:async';

import 'package:flutter/material.dart';

typedef FutureTimerBuilderCallback = FutureBuilder<dynamic> Function();
typedef FutureTimerShouldUpdateCallback = bool Function();

class FutureTimer extends StatefulWidget {
  final int _durationMillis;
  final FutureTimerBuilderCallback _futureBuilder;
  final FutureTimerShouldUpdateCallback _shouldUpdateCallback;

  FutureTimer({
    @required FutureTimerBuilderCallback futureBuilder,
    int durationMillis = 1000,
    FutureTimerShouldUpdateCallback shouldUpdateCallback,
  }) : assert(futureBuilder != null),
       _durationMillis = durationMillis,
       _futureBuilder = futureBuilder,
       _shouldUpdateCallback = shouldUpdateCallback;

  @override
  State<StatefulWidget> createState() => _FutureTimerState();
}

class _FutureTimerState extends State<FutureTimer> {
  Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(
      Duration(milliseconds: widget._durationMillis), (Timer timer) {
        if (widget._shouldUpdateCallback == null ||
            widget._shouldUpdateCallback())
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
    return widget._futureBuilder();
  }
}
