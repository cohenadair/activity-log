import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/activity_list_item_view.dart';
import 'package:mobile/widgets/loading.dart';
import 'package:mobile/widgets/page.dart';

class ActivitiesPage extends StatefulWidget {
  final AppManager _app;

  ActivitiesPage(this._app);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState(_app);
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final AppManager _app;

  _ActivitiesPageState(this._app);

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
            _app.authManager.logout();
          },
        ),
      ),
      child: _app.dataManager.getActivitiesListenerWidget(
        loading: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Loading(
              padding: Dimen.defaultTopPadding,
            ),
          ],
        ),
        error: Text(
          'Error loading activities',
          style: Style.textError,
        ),
        display: (List<Activity> activities) {
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (BuildContext context, int i) {
              return ActivityListItemView(_app, activities[i],
                  _openEditActivityPage);
            },
          );
        }
      ),
    );
  }

  void _onPressAddButton() {
    _openEditActivityPage();
  }

  void _openEditActivityPage([Activity activity]) {
    PageUtils.push(
      context,
      EditActivityPage(_app, activity),
      fullscreenDialog: activity == null,
    );
  }
}
