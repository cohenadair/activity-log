import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/future_timer_text.dart';

typedef OnTapActivityListItemView = Function(Activity);

class ActivityListItemView extends StatefulWidget {
  final AppManager _app;
  final Activity _activity;
  final OnTapActivityListItemView _onTap;

  ActivityListItemView(this._app, this._activity, this._onTap);

  @override
  State<StatefulWidget> createState() => _ActivityListItemViewState();
}

class _ActivityListItemViewState extends State<ActivityListItemView> {
  String _currentDisplayDuration;

  AppManager get _app => widget._app;
  Activity get _activity => widget._activity;
  OnTapActivityListItemView get _onTap => widget._onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_activity.name),
      onTap: () {
        if (_onTap != null) {
          _onTap(_activity);
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: Dimen.rightWidgetSpacing,
            child: FutureTimerText(
              shouldUpdateCallback: () => _activity.isRunning,
              futureBuilder: () => FutureBuilder<String>(
                future: _app.dataManager.getDisplayDuration(_activity.id),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot)
                {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      break;
                    default:
                      _currentDisplayDuration = snapshot.data;
                      break;
                  }
                  return _currentDisplayDuration == null
                      ? Container() : Text(_currentDisplayDuration);
                },
              ),
            ),
          ),
          Button(
            text: _activity.isRunning ? 'Stop' : 'Start',
            onPressed: () {
              if (_activity.isRunning) {
                _app.dataManager.endSession(_activity).catchError((error) {
                  print(error);
                });
              } else {
                _app.dataManager.startSession(_activity).catchError((error) {
                  print(error);
                });
              }
            },
            color: _activity.isRunning ? Colors.red : null,
          ),
        ],
      ),
    );
  }
}
