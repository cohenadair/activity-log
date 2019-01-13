import 'package:mobile/model/activity.dart';
import 'package:mobile/utils/change_listener.dart';
import 'package:mobile/utils/string_utils.dart';

class ActivityManagerListener {
  void onActivitiesChanged() {}
}

class ActivityManager extends ChangeListener<ActivityManagerListener> {
  List<Activity> _activities = [];
  List<Activity> get activities => _activities;

  void addActivity(Activity activity) {
    _activities.add(activity);
    _notifyActivitiesChanged();
  }

  void deleteActivity(Activity activity) {
    if (_activities.remove(activity)) {
      _notifyActivitiesChanged();
    }
  }

  void updateActivity(Activity activity, {Activity newActivity}) {
    _activities[_activities.indexOf(activity)] = newActivity;
  }

  /// Trimmed, case-insensitive compare of 'name' to all other activities.
  bool activityNameExists(String name, [String excludingName]) {
    for (var activity in _activities) {
      if (StringUtils.isEqualTrimmedLowercase(activity.name, name)) {
        return true;
      }
    }
    return false;
  }

  void _notifyActivitiesChanged() {
    notify((l) => l.onActivitiesChanged());
  }
}
