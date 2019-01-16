import 'package:mobile/activity_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/data_manager.dart';

class AppManager {
  ActivityManager _activityManager;
  AuthManager _authManager;
  DataManager _dataManager;

  ActivityManager get activityManager {
    if (_activityManager == null) {
      _activityManager = ActivityManager();
    }
    return _activityManager;
  }

  AuthManager get authManager {
    if (_authManager == null) {
      _authManager = AuthManager();
    }
    return _authManager;
  }

  DataManager get dataManager {
    if (_dataManager == null) {
      _dataManager = DataManager(this);
    }
    return _dataManager;
  }
}