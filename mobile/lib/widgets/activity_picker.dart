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
  final Activity initialActivity;

  /// This function is invoked with `null` if "All activities" is selected.
  final OnListPickerChanged<Activity> onActivityPicked;

  ActivityPicker({
    @required this.app,
    @required this.initialActivity,
    @required this.onActivityPicked,
  });

  @override
  _ActivityPickerState createState() => _ActivityPickerState();
}

class _ActivityPickerState extends State<ActivityPicker> {
  Stream<List<Activity>> _stream;

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
        Activity allItems = ActivityBuilder(
          Strings.of(context).activityDropdownAllActivities
        ).build;
        List<Activity> activities = [allItems];

        if (snapshot.hasData) {
          activities.addAll(snapshot.data);
        }

        return ListPicker<Activity>(
          initialValue: widget.initialActivity ?? activities.first,
          onChanged: (Activity activity) {
            if (activity == activities.first) {
              // Invoke the callback with null if "All activities" was picked.
              widget.onActivityPicked(null);
            } else {
              widget.onActivityPicked(activity);
            }
          },
          options: activities.map((Activity activity) {
            return ListPickerItem<Activity>(
              value: activity,
              child: Text(activity.name),
            );
          }).toList(),
        );
      }
    );
  }
}