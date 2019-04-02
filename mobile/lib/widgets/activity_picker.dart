import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/sqlite_data_manager.dart';
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
  Activity _allActivitiesActivity;

  @override
  Widget build(BuildContext context) {
    return ActivitiesBuilder(
      app: widget.app,
      builder: (BuildContext context, List<Activity> activities) {
        if (_allActivitiesActivity == null) {
          _allActivitiesActivity = ActivityBuilder(
            Strings.of(context).activityDropdownAllActivities,
          ).build;
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
      title: activity.name,
    );
  }
}