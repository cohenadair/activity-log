import 'package:mobile/preferences_manager.dart';
import 'package:mobile/database/sqlite_data_manager.dart';

class AppManager {
  SQLiteDataManager? _dataManager;
  PreferencesManager? _preferencesManager;

  SQLiteDataManager get dataManager {
    _dataManager ??= SQLiteDataManager();
    return _dataManager!;
  }

  PreferencesManager get preferencesManager {
    _preferencesManager ??= PreferencesManager();
    return _preferencesManager!;
  }
}
