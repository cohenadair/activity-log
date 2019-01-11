import 'package:flutter/material.dart';

import 'package:mobile/model/timer.dart';
import 'package:mobile/res/res.dart';

typedef OnTapTimerListView = Function(Timer);

class TimerListView extends StatelessWidget {
  static List<TimerListView> getTimerViews(
      {@required List<Timer> timers, @required OnTapTimerListView onTap})
  {
    return List<TimerListView>.generate(
        timers.length, (int index) => TimerListView(timers[index], onTap));
  }

  final Timer _timer;
  final OnTapTimerListView _onTap;

  TimerListView(this._timer, this._onTap);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () {
                  _onTap(_timer);
                },
                child: Padding(
                  padding: EdgeInsets.all(Dimen.defaultPadding),
                  child: Text(_timer.name)
                ),
              ),
            ),
          ],
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}
