import 'package:flutter/material.dart';

import 'package:mobile/activity_manager.dart';
import 'package:mobile/widgets/activity_list_item_view.dart';
import 'package:mobile/widgets/my_app_bar.dart';
import 'package:mobile/model/activity.dart';

import 'edit_activity_page.dart';

class ActivitiesPage extends StatefulWidget {
  final ActivityManager _activityManager;

  ActivitiesPage(this._activityManager);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState(_activityManager);
}

class _ActivitiesPageState extends State<ActivitiesPage>
    implements ActivityManagerListener
{
  final ActivityManager _activityManager;
  List<Activity> _activities;

  _ActivitiesPageState(this._activityManager) {
    _activities = _activityManager.activities;
    _activityManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text('Activities'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add activity',
            onPressed: _onPressAddButton,
          )
        ],
      ),
      body: ListView(
        children: ActivityListItemView.getViews(
          activities: _activities,
          onTap: (Activity activity) {
            print('Tapped activity: ${activity.name}');
          }
        ),
      )
    );
  }

  void _onPressAddButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditActivityPage(),
        fullscreenDialog: true,
      )
    );
  }

  @override
  void onActivityAdded() {
    setState(() {
      _activities = widget._activityManager.activities;
    });
  }
}
