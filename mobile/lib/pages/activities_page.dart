import 'package:flutter/material.dart';
import 'package:mobile/activity_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/activity_list_item_view.dart';
import 'package:mobile/widgets/page.dart';

class ActivitiesPage extends StatefulWidget {
  final ActivityManager _activityManager;
  final AuthManager _authManager;

  ActivitiesPage(this._activityManager, this._authManager);

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
    widget._activityManager.add(this);
    super.initState();
  }

  @override
  void dispose() {
    widget._activityManager.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      padding: EdgeInsets.all(0),
      appBarStyle: PageAppBarStyle(
        title: 'Activities',
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add activity',
            onPressed: _onPressAddButton,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          tooltip: 'Logout',
          onPressed: () {
            widget._authManager.logout();
          },
        ),
      ),
      child: ListView(
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
    PageUtils.push(
      context,
      EditActivityPage(widget._activityManager, activity),
      fullscreenDialog: activity == null,
    );
  }

  @override
  void onActivitiesChanged() {
    setState(() {
      _activities = widget._activityManager.activities;
    });
  }
}
