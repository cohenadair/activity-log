import 'package:flutter/material.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/pages/edit_session_page.dart';
import 'package:mobile/widgets/list_page.dart';
import 'package:mobile/widgets/session_list_tile.dart';

class SessionsPage extends StatelessWidget {
  final Activity activity;

  const SessionsPage(this.activity);

  @override
  Widget build(BuildContext context) {
    return SessionsBuilder(
      activityId: activity.id,
      builder: (context, sessions) => ListPage<Session>(
        items: sessions,
        title: activity.name,
        getEditPageCallback: (session) => EditSessionPage(
          activity: activity,
          editingSession: session,
        ),
        buildTileCallback: (session, onTapTile) => SessionListTile(
          session: session,
          onTap: onTapTile,
        ),
      ),
    );
  }
}
