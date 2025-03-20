import 'package:mobile/database/data_manager.dart';
import 'package:mobile/preferences_manager.dart';

import 'mocks/mocks.mocks.dart';

class StubbedManagers {
  late final MockDataManager dataManager;
  late final MockPreferencesManager preferencesManager;

  StubbedManagers() {
    dataManager = MockDataManager();
    DataManager.set(dataManager);

    preferencesManager = MockPreferencesManager();
    PreferencesManager.set(preferencesManager);
  }
}
