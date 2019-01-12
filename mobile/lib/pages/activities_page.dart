import 'package:flutter/material.dart';

import '../activity_manager.dart';
import '../model/activity.dart';
import '../widgets/activity_list_item_view.dart';
import '../widgets/my_app_bar.dart';

import 'edit_activity_page.dart';

class ActivitiesPage extends StatefulWidget {
  final ActivityManager _activityManager;

  ActivitiesPage(this._activityManager);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    implements ActivityManagerListener
{
  List<Activity> _activities;

  @override
  void initState() {
    _activities = widget._activityManager.activities;
    widget._activityManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    widget._activityManager.removeListener(this);
    super.dispose();
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
            _openEditActivityPage(activity);
          },
        ),
      )
    );
  }

  void _onPressAddButton() {
    _openEditActivityPage();
  }

  void _openEditActivityPage([Activity activity]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditActivityPage(widget._activityManager,
            activity),
        fullscreenDialog: true,
      )
    );
  }

  @override
  void onActivitiesChanged() {
    setState(() {
      _activities = widget._activityManager.activities;
    });
  }
}
