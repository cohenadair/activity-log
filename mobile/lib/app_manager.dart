import 'package:mobile/data_manageable.dart';
import 'package:mobile/sql_data_manager.dart';

class AppManager {
  DataManageable _dataManager;

  DataManageable get dataManager {
    if (_dataManager == null) {
      _dataManager = SQLiteDataManager();
    }
    return _dataManager;
  }
}