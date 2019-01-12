import 'package:flutter/material.dart';

import '../model/activity.dart';
import '../widgets/list_item_view.dart';

typedef OnTapActivityListItemView = Function(Activity);

class ActivityListItemView extends StatelessWidget {
  static List<ActivityListItemView> getViews({
      @required List<Activity> activities,
      @required OnTapActivityListItemView onTap})
  {
    return List<ActivityListItemView>.generate(activities.length,
        (int index) => ActivityListItemView(activities[index], onTap));
  }

  final Activity _activity;
  final OnTapActivityListItemView _onTap;

  ActivityListItemView(this._activity, this._onTap);

  @override
  Widget build(BuildContext context) {
    return ListItemView(
      onTap: () {
        _onTap(_activity);
      },
      child: Row(
        children: <Widget>[
          Text(_activity.name),
        ],
      ),
    );
  }
}
