import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/activity_dropdown.dart';
import 'package:mobile/widgets/page.dart';

class StatsPage extends StatelessWidget {
  final AppManager _app;

  StatsPage(this._app);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: "Stats",
      ),
      child: Padding(
        padding: insetsRowDefault,
        child: ListView(
          children: <Widget>[
            ActivityDropdown(
              app: _app,
              itemSelectedCallback: (Activity activity) {
                print(activity.name);
              },
            ),
          ],
        ),
      ),
    );
  }
}