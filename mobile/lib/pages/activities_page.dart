import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/activity_list_tile.dart';
import 'package:mobile/widgets/loading.dart';
import 'package:mobile/widgets/page.dart';

class ActivitiesPage extends StatefulWidget {
  final AppManager _app;

  ActivitiesPage(this._app);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  AppManager get _app => widget._app;

  @override
  Widget build(BuildContext context) {
    return Page(
      padding: EdgeInsets.all(0),
      appBarStyle: PageAppBarStyle(
        title: "Activities",
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            tooltip: "Add activity",
            onPressed: _onPressAddButton,
          ),
        ],
      ),
      child: StreamBuilder<List<Activity>>(
        stream: _app.dataManager.activitiesUpdated,
        builder: (BuildContext context,
            AsyncSnapshot<List<Activity>> snapshot)
        {
          if (!snapshot.hasData) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Loading(
                  padding: insetsTopDefault,
                ),
              ],
            );
          }

          return ListView.separated(
            itemCount: snapshot.data.length,
            separatorBuilder: (BuildContext context, int i) =>
                Divider(height: 1),
            itemBuilder: (BuildContext context, int i) {
              return ActivityListTile(_app, snapshot.data[i],
                  _openEditActivityPage);
            },
          );
        },
      ),
    );
  }

  void _onPressAddButton() {
    _openEditActivityPage();
  }

  void _openEditActivityPage([Activity activity]) {
    push(
      context,
      EditActivityPage(_app, activity),
      fullscreenDialog: activity == null,
    );
  }
}
