import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

enum PreferencesDurationUnit {
  days,
  hours,
  minutes
}

class PreferencesManager {
  final _keyLargestDurationUnit = "preferences.largestDurationUnit";

  final StreamController<PreferencesDurationUnit> _largestDurationUnitUpdated =
      StreamController.broadcast();

  Stream<PreferencesDurationUnit> getLargestDurationUnitStream() {
    return _largestDurationUnitUpdated.stream;
  }

  void setLargestDurationUnit(PreferencesDurationUnit unit) async {
    if ((await largestDurationUnit) == unit) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLargestDurationUnit,
        PreferencesDurationUnit.values.indexOf(unit));
    _notifyLargestDurationUnitUpdated(unit);
  }

  Future<PreferencesDurationUnit> get largestDurationUnit async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int unitIndex = prefs.getInt(_keyLargestDurationUnit) ?? 0;
    return PreferencesDurationUnit.values[unitIndex];
  }

  void _notifyLargestDurationUnitUpdated(PreferencesDurationUnit newUnit) {
    if (_largestDurationUnitUpdated.hasListener) {
      _largestDurationUnitUpdated.add(newUnit);
    }
  }
}