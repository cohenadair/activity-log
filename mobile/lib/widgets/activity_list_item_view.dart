import 'package:flutter/material.dart';

import '../model/activity.dart';
import '../res/res.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SafeArea(
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    _onTap(_activity);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(Dimen.defaultPadding),
                    child: Text(_activity.name)
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}
