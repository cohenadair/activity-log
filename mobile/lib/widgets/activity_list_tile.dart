import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/future_timer.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

typedef OnTapActivityListTile = Function(Activity);

class ActivityListTile extends StatefulWidget {
  final AppManager _app;
  final Activity _activity;
  final OnTapActivityListTile _onTap;

  ActivityListTile(this._app, this._activity, this._onTap);

  @override
  State<StatefulWidget> createState() => _ActivityListTileState();
}

class _ActivityListTileState extends State<ActivityListTile> {
  // Ensures this tile is updated if sessions are manually added from
  // elsewhere in the app.
  StreamSubscription<List<Session>> _sessionsUpdatedSub;

  Future<List<Session>> _sessionsFuture;
  Future<Session> _currentSessionFuture;

  // Used so back-to-back start/end sessions can't be created if there's a
  // delay round tripping to the database.
  bool _newSessionsLocked = false;

  AppManager get _app => widget._app;
  Activity get _activity => widget._activity;
  OnTapActivityListTile get _onTap => widget._onTap;

  @override
  void initState() {
    super.initState();

    _app.dataManager.getSessionsUpdatedStream(_activity.id, (stream) {
      _sessionsUpdatedSub = stream.listen((_) {
        setState(() {
          _updateSessionsFuture();
          _updateCurrentSessionFuture(_activity.currentSessionId);
        });
      });

      return true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sessionsUpdatedSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      contentPadding: EdgeInsets.only(right: 0, left: paddingDefault),
      title: Text(_activity.name),
      subtitle: FutureBuilder<List<Session>>(
        future: _sessionsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Session>> snapshot) {
          if (!snapshot.hasData) {
            return Empty();
          }

          List<Duration> durations = snapshot.data
              .where((session) => !session.inProgress)
              .map((session) => session.duration)
              .toList();

          return TotalDurationText(durations);
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
          FutureBuilder<Session>(
            future: _currentSessionFuture,
            builder: (_, AsyncSnapshot<Session> snapshot) => snapshot.hasData
                ? _buildRunningDuration(snapshot.data)
                : Empty(),
          ),
          _activity.isRunning ? _buildStopButton() : _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return _buildButton(Icons.play_arrow, Colors.green, () {
      _app.dataManager.startSession(_activity).then((newSessionId) {
        setState(() {
          _updateCurrentSessionFuture(newSessionId);
          _newSessionsLocked = false;
        });
      });
    });
  }

  Widget _buildStopButton() {
    return _buildButton(Icons.stop, Colors.red, () {
      _app.dataManager.endSession(_activity).then((_) {
        setState(() {
          _updateSessionsFuture();
          _updateCurrentSessionFuture(null);
          _newSessionsLocked = false;
        });
      });
    });
  }

  Widget _buildButton(IconData icon, Color color, Function onPressed) {
    assert(icon != null);
    assert(onPressed != null);

    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: () {
        if (_newSessionsLocked) {
          return;
        }
        onPressed();
        _newSessionsLocked = true;
      },
    );
  }

  Widget _buildRunningDuration(Session session) {
    return Timer(
      shouldUpdateCallback: () => _activity.isRunning,
      childBuilder: () => RunningDurationText(session.duration),
    );
  }

  void _updateSessionsFuture() {
    _sessionsFuture = _app.dataManager.getSessions(_activity.id);
  }

  void _updateCurrentSessionFuture(String currentSessionId) {
    _currentSessionFuture = _app.dataManager.getSession(currentSessionId);
  }
}
