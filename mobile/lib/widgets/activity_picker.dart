import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/widgets/list_picker.dart';

typedef OnActivityDropdownItemSelected = void Function(Activity);

/// A [ListPicker] wrapper for selecting a single [Activity], or
/// "All activities".
class ActivityPicker extends StatefulWidget {
  final AppManager app;
  final Set<Activity> initialActivities;

  /// This function is invoked with `null` if "All activities" is selected.
  final OnListPickerChanged<Set<Activity>> onPickedActivitiesChanged;

  ActivityPicker({
    @required this.app,
    @required this.initialActivities,
    @required this.onPickedActivitiesChanged,
  });

  @override
  _ActivityPickerState createState() => _ActivityPickerState();
}

class _ActivityPickerState extends State<ActivityPicker> {
  Stream<List<Activity>> _stream;
  Activity _allActivitiesActivity;

  @override
  void initState() {
    super.initState();

    widget.app.dataManager.getActivitiesUpdateStream((stream) {
      _stream = stream;
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Activity>>(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
        if (_allActivitiesActivity == null) {
          _allActivitiesActivity = ActivityBuilder(
            Strings.of(context).activityDropdownAllActivities,
          ).build;
        }

        List<Activity> activities = [];
        if (snapshot.hasData) {
          activities.addAll(snapshot.data);
        }

        return ListPicker<Activity>(
          allowsMultiSelect: true,
          initialValues: widget.initialActivities
              ?? Set.of([_allActivitiesActivity]),
          onChanged: (Set<Activity> newActivities) {
            if (newActivities == null
                || newActivities.first == _allActivitiesActivity)
            {
              // Invoke the callback with null if "All activities" was picked.
              widget.onPickedActivitiesChanged(null);
            } else {
              widget.onPickedActivitiesChanged(newActivities);
            }
          },
          allItem: _buildItem(_allActivitiesActivity),
          items: activities.map((activity) => _buildItem(activity)).toList(),
          titleBuilder: (Set<Activity> selectedActivities) {
            return Text(
              selectedActivities.map((activity) => activity.name)
                  .toList().join(", "),
            );
          },
        );
      }
    );
  }

  ListPickerItem<Activity> _buildItem(Activity activity) {
    return ListPickerItem<Activity>(
      value: activity,
      child: Text(activity.name),
    );
  }
}