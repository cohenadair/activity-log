import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';

typedef ActivityDropdownItemSelectedCallback = void Function(Activity);

/// A [DropdownButton] for selecting a single [Activity], or "All activities".
class ActivityDropdown extends StatefulWidget {
  final AppManager app;

  /// Called when a new item is selected. If "All activities" is selected,
  /// the passed [Activity] is equal to `null`.
  final ActivityDropdownItemSelectedCallback itemSelectedCallback;

  ActivityDropdown({
    @required this.app,
    this.itemSelectedCallback,
  });

  @override
  _ActivityDropdownState createState() => _ActivityDropdownState();
}

class _ActivityDropdownState extends State<ActivityDropdown> {
  AppManager get app => widget.app;
  ActivityDropdownItemSelectedCallback get itemSelectedCallback =>
      widget.itemSelectedCallback;

  Activity _selectedActivity;
  Stream<List<Activity>> _stream;

  @override
  void initState() {
    super.initState();

    app.dataManager.getActivitiesUpdateStream((stream) {
      _stream = stream;
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Activity>>(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
        Activity allItems = ActivityBuilder(
          Strings.of(context).activityDropdownAllActivities
        ).build;
        List<Activity> activities = [allItems];

        if (_selectedActivity == null) {
          _selectedActivity = activities.first;
        }

        if (snapshot.hasData) {
          activities.addAll(snapshot.data);
        }

        return DropdownButton<Activity>(
          value: _selectedActivity,
          isExpanded: true,
          onChanged: (Activity activity) {
            if (itemSelectedCallback != null) {
              itemSelectedCallback(activity);
            }
            setState(() {
              _selectedActivity = activity;
            });
          },
          items: activities.map((Activity activity) {
            return DropdownMenuItem<Activity>(
              value: activity,
              child: Text(activity.name),
            );
          }).toList(),
        );
      }
    );
  }
}