import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/future_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  final _keyLargestDurationUnit = "preferences.largestDurationUnit";

  final StreamController<DurationUnit> _largestDurationUnitUpdated =
      StreamController.broadcast();

  Stream<DurationUnit> _getLargestDurationUnitStream() {
    return _largestDurationUnitUpdated.stream;
  }

  void setLargestDurationUnit(DurationUnit unit) async {
    if ((await _largestDurationUnit) == unit) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLargestDurationUnit,
        DurationUnit.values.indexOf(unit));
    _notifyLargestDurationUnitUpdated(unit);
  }

  Future<DurationUnit> get _largestDurationUnit async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int unitIndex = prefs.getInt(_keyLargestDurationUnit) ?? 0;
    return DurationUnit.values[unitIndex];
  }

  void _notifyLargestDurationUnitUpdated(DurationUnit newUnit) {
    if (_largestDurationUnitUpdated.hasListener) {
      _largestDurationUnitUpdated.add(newUnit);
    }
  }
}

/// A [FutureBuilder] wrapper for listening for [PreferencesManager] largest
/// duration updates.
class LargestDurationFutureBuilder extends FutureListener<DurationUnit> {
  final AppManager app;
  final Widget Function(DurationUnit) builder;

  LargestDurationFutureBuilder({
    @required this.app,
    @required this.builder,
  }) : super (
    getFutureCallback: () => app.preferencesManager._largestDurationUnit,
    stream: app.preferencesManager._getLargestDurationUnitStream(),
    builder: builder,
  );
}