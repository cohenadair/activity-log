import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/future_timer.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class ActivityListTileModel {
  final Activity activity;
  Session currentSession;
  Duration duration;

  ActivityListTileModel(this.activity) : assert(activity != null);
}

class ActivityListTile extends StatelessWidget {
  final AppManager app;
  final ActivityListTileModel model;
  final Function(Activity) onTap;
  final Function() onTapStartSession;
  final Function() onTapEndSession;

  ActivityListTile({
    @required this.app,
    this.model,
    this.onTap,
    this.onTapStartSession,
    this.onTapEndSession,
  }) : assert(app != null),
       assert(model != null);

  @override
  Widget build(BuildContext context) {
    return LargestDurationFutureBuilder(
      app: app,
      builder: (DurationUnit largestDurationUnit) => ListItem(
        contentPadding: EdgeInsets.only(right: 0, left: paddingDefault),
        title: Text(model.activity.name),
        subtitle: TotalDurationText(model.duration == null
            ? []
            : [model.duration],
          largestDurationUnit: largestDurationUnit,
        ),
        onTap: () {
          onTap?.call(model.activity);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildRunningDuration(model.currentSession),
            model.activity.isRunning ? _buildStopButton() : _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return _buildButton(Icons.play_arrow, Colors.green, () {
      onTapStartSession?.call();
    });
  }

  Widget _buildStopButton() {
    return _buildButton(Icons.stop, Colors.red, () {
      onTapEndSession?.call();
    });
  }

  Widget _buildButton(IconData icon, Color color, Function onPressed) {
    assert(icon != null);
    assert(onPressed != null);

    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: onPressed,
    );
  }

  Widget _buildRunningDuration(Session session) {
    return Timer(
      shouldUpdateCallback: () => model.activity.isRunning,
      childBuilder: () {
        bool visible = session != null;
        return FadeIn<Duration>(
          visible: visible,
          value: visible ? session.duration : null,
          childBuilder: (Duration value) =>
              RunningDurationText(value ?? Duration()),
        );
      },
    );
  }
}
