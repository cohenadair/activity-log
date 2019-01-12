import 'model/activity.dart';
import 'utils/string_utils.dart';

class ActivityManagerListener {
  void onActivitiesChanged() {}
}

class ActivityManager {
  List<Activity> _activities = [];
  List<Activity> get activities => _activities;

  List<ActivityManagerListener> _listeners = [];

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

  void addListener(ActivityManagerListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ActivityManagerListener listener) {
    _listeners.remove(listener);
  }

  void _notifyActivitiesChanged() {
    _listeners.forEach((l) => l.onActivitiesChanged());
  }
}
