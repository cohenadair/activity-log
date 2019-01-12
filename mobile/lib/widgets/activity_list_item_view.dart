import 'package:flutter/material.dart';

import '../model/activity.dart';
import '../res/res.dart';
import '../widgets/list_item_view.dart';
import '../widgets/timer_text.dart';

typedef OnTapActivityListItemView = Function(Activity);

class ActivityListItemView extends StatefulWidget {
  static List<ActivityListItemView> getViews({
      @required List<Activity> activities,
      @required OnTapActivityListItemView onTap})
  {
    return List<ActivityListItemView>.generate(activities.length,
        (int index) => ActivityListItemView(activities[index], onTap));
  }

  final Activity _activity;
  final OnTapActivityListItemView _onTap;

  ActivityListItemView(this._activity, this._onTap);

  @override
  State<StatefulWidget> createState() => _ActivityListItemViewState();
}

class _ActivityListItemViewState extends State<ActivityListItemView> {
  @override
  Widget build(BuildContext context) {
    return ListItemView(
      onTap: () {
        widget._onTap(widget._activity);
      },
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: Dimen.rightWidgetSpacing,
              child: Text(widget._activity.name),
            )
          ),
          Padding(
            padding: Dimen.rightWidgetSpacing,
            child: TimerText(
              durationMillis: 1000,
              getTextCallback: () => widget._activity.displayDuration,
              shouldUpdateCallback: () => widget._activity.isRunning,
            ),
          ),
          _getStatusButton(),
        ],
      ),
    );
  }

  Widget _getStatusButton() {
    if (widget._activity.isRunning) {
      return FlatButton(
        onPressed: () {
          widget._activity.endSession();
          _update();
        },
        child: Text('Stop'.toUpperCase()),
        color: Colors.red,
        textColor: Colors.white,
      );
    } else {
      return FlatButton(
        onPressed: () {
          widget._activity.startSession();
          _update();
        },
        child: Text('Start'.toUpperCase()),
        color: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  void _update() {
    setState(() {});
  }
}
