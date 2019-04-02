import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/sqlite_data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/pages/edit_session_page.dart';
import 'package:mobile/widgets/list_page.dart';
import 'package:mobile/widgets/session_list_tile.dart';

class SessionsPage extends StatelessWidget {
  final AppManager app;
  final Activity activity;

  SessionsPage(this.app, this.activity);

  @override
  Widget build(BuildContext context) {
    return SessionsBuilder(
      app: app,
      activityId: activity.id,
      builder: (context, sessions) => ListPage<Session>(
        items: sessions,
        title: activity.name,
        getEditPageCallback: (session) => EditSessionPage(
          app: app,
          activity: activity,
          editingSession: session,
        ),
        buildTileCallback: (session, onTapTile) => SessionListTile(
          app: app,
          session: session,
          onTap: onTapTile,
        ),
      ),
    );
  }
}