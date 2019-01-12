import 'dart:async';

import 'package:flutter/material.dart';

typedef TimerTextGetTextCallback = String Function();
typedef TimerTextShouldUpdateCallback = bool Function();

class TimerText extends StatefulWidget {
  final int _durationMillis;
  final TimerTextGetTextCallback _getTextCallback;
  final TimerTextShouldUpdateCallback _shouldUpdateCallback;

  TimerText({
      @required int durationMillis,
      @required TimerTextGetTextCallback getTextCallback,
      @required TimerTextShouldUpdateCallback shouldUpdateCallback
  })
      : _durationMillis = durationMillis,
        _getTextCallback = getTextCallback,
        _shouldUpdateCallback = shouldUpdateCallback;

  @override
  State<StatefulWidget> createState() => _TimerTextState();
}

class _TimerTextState extends State<TimerText> {
  Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(
        Duration(milliseconds: widget._durationMillis), (Timer timer) {
          if (widget._shouldUpdateCallback()) {
            setState(() {});
          }
        });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget._getTextCallback());
  }
}
