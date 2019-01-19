import 'package:mobile/auth_manager.dart';
import 'package:mobile/data_manager.dart';

class AppManager {
  AuthManager _authManager;
  DataManager _dataManager;

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