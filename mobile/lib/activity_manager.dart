import 'model/activity.dart';

class ActivityManager {
  List<Activity> _activities = [];
  List<Activity> get activities => _activities;

  List<ActivityManagerListener> _listeners = [];

  ActivityManager() {
    addActivity(Activity('Test 1'));
    addActivity(Activity('Test 2'));
    addActivity(Activity('Test 3'));
    addActivity(Activity('Test 4'));
  }

  void addActivity(Activity activity) {
    _activities.add(activity);
    _notifyActivityAdded();
  }

  void addListener(ActivityManagerListener listener) {
    _listeners.add(listener);
  }

  void _notifyActivityAdded() {
    for (var listener in _listeners) {
      listener.onActivityAdded();
    }
  }
}

class ActivityManagerListener {
  void onActivityAdded() {}
}
