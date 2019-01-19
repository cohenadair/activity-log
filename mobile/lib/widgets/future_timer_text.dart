import 'dart:async';

import 'package:flutter/material.dart';

typedef FutureTimerTextBuilderCallback = FutureBuilder<String> Function();
typedef FutureTimerTextShouldUpdateCallback = bool Function();

class FutureTimerText extends StatefulWidget {
  final int _durationMillis;
  final FutureTimerTextBuilderCallback _futureBuilder;
  final FutureTimerTextShouldUpdateCallback _shouldUpdateCallback;

  FutureTimerText({
    @required FutureTimerTextBuilderCallback futureBuilder,
    int durationMillis = 1000,
    FutureTimerTextShouldUpdateCallback shouldUpdateCallback,
  }) : assert(futureBuilder != null),
       _durationMillis = durationMillis,
       _futureBuilder = futureBuilder,
       _shouldUpdateCallback = shouldUpdateCallback;

  @override
  State<StatefulWidget> createState() => _FutureTimerTextState();
}

class _FutureTimerTextState extends State<FutureTimerText> {
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
