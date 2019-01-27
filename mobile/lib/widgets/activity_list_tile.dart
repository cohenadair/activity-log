import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/model_utils.dart';
import 'package:mobile/widgets/future_timer_text.dart';

typedef OnTapActivityListItemView = Function(Activity);

class ActivityListTile extends StatefulWidget {
  final AppManager _app;
  final Activity _activity;
  final OnTapActivityListItemView _onTap;

  ActivityListTile(this._app, this._activity, this._onTap);

  @override
  State<StatefulWidget> createState() => _ActivityListTileState();
}

// Used to keep track of start and end progress so multiple requests aren't
// sent if the button is spam-pressed.
enum _WaitingStatus {
  forStart,
  forEnd
}

class _ActivityListTileState extends State<ActivityListTile> {
  String _currentDisplayDuration;
  _WaitingStatus _waitingStatus;

  AppManager get _app => widget._app;
  Activity get _activity => widget._activity;
  OnTapActivityListItemView get _onTap => widget._onTap;

  bool get _isWaiting => _waitingStatus != null;

  @override
  Widget build(BuildContext context) {
    _updateWaitingStatus();

    return ListTile(
      contentPadding: EdgeInsets.only(right: 0, left: paddingDefault),
      title: Text(_activity.name),
      subtitle: FutureBuilder<String>(
        future: _getTotalDuration(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasError) {
            print('Error building total duration: '
                + '${snapshot.error.toString()}');
          }
          return Text(snapshot.hasData ? snapshot.data : "");
        },
      ),
      onTap: () {
        if (_onTap != null) {
          _onTap(_activity);
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FutureTimerText(
            shouldUpdateCallback: () => _activity.isRunning,
            futureBuilder: () => FutureBuilder<String>(
              future: _getSessionDuration(),
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
          _activity.isRunning ? _getStopButton() : _getStartButton(),
        ],
      ),
    );
  }

  void _updateWaitingStatus() {
    if (_waitingStatus == null) {
      return;
    }

    if ((_waitingStatus == _WaitingStatus.forEnd && !_activity.isRunning)
        || (_waitingStatus == _WaitingStatus.forStart && _activity.isRunning))
    {
      _waitingStatus = null;
    }
  }

  Widget _getStartButton() {
    return _getButton(Icons.play_arrow, Colors.green, () {
      _waitingStatus = _WaitingStatus.forStart;
      _app.dataManager.startSession(_activity);
    });
  }

  Widget _getStopButton() {
    return _getButton(Icons.stop, Colors.red, () {
      _waitingStatus = _WaitingStatus.forEnd;
      _app.dataManager.endSession(_activity);
    });
  }

  Widget _getButton(IconData icon, Color color, Function onPressed) {
    assert(icon != null);
    assert(onPressed != null);

    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: () {
        if (_isWaiting) {
          return;
        }

        onPressed();
        _update();
      },
    );
  }

  Future<String> _getTotalDuration() async {
    List<Session> sessions = await _app.dataManager.getSessions(_activity.id);
    return formatTotalDuration(sessions);
  }

  Future<String> _getSessionDuration() async {
    if (!_activity.isRunning) {
      return null;
    }

    Session session =
        await _app.dataManager.getCurrentSession(_activity.currentSessionId);
    return formatSessionDuration(session);
  }

  void _update() {
    setState(() {
    });
  }
}
