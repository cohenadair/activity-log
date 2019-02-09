import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/widgets/list_page.dart';
import 'package:mobile/widgets/activity_list_tile.dart';

class ActivitiesPage extends StatefulWidget {
  final AppManager _app;

  ActivitiesPage(this._app);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  AppManager get _app => widget._app;
  Stream<List<Activity>> _stream;

  @override
  void initState() {
    _app.dataManager.getActivitiesUpdateStream((stream) {
      _stream = stream;
      return true;
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ListPage<Activity>(
      app: _app,
      title: Strings.of(context).activitiesPageTitle,
      onGetEditPageCallback: (activity) {
        return EditActivityPage(_app, activity);
      },
      onBuildTileCallback: (activity, onTapTile) {
        return ActivityListTile(_app, activity, onTapTile);
      },
      stream: _stream,
    );
  }
}
