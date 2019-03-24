import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/pages/edit_session_page.dart';
import 'package:mobile/widgets/list_page.dart';
import 'package:mobile/widgets/session_list_tile.dart';

class SessionsPage extends StatefulWidget {
  final AppManager _app;
  final Activity _activity;

  SessionsPage(this._app, this._activity);

  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  AppManager get _app => widget._app;
  Activity get _activity => widget._activity;

  Stream<List<Session>> _stream;

  @override
  void initState() {
    _app.dataManager.getSessionsUpdatedStream(_activity.id, (stream) {
      _stream = stream;
      return true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListPage<Session>(
      title: _activity.name,
      onGetEditPageCallback: (session) {
        return EditSessionPage(
          app: _app,
          activity: _activity,
          editingSession: session,
        );
      },
      onBuildTileCallback: (session, onTapTile) {
        return SessionListTile(
          app: _app,
          session: session,
          onTap: onTapTile,
        );
      },
      stream: _stream,
    );
  }
}