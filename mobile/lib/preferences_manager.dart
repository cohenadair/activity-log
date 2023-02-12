import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  final _keyLargestDurationUnit = "preferences.largestDurationUnit";
  final _keyHomeDateRange = "preferences.homeDateRange";
  final _keyStatsSelectedActivityIds = "preferences.statsSelectedActivityIds";
  final _keyStatsDateRange = "preferences.statsDateRange";

  final VoidStreamController _largestDurationUnitUpdated =
      VoidStreamController();
  final VoidStreamController _homeDateRangeUpdated = VoidStreamController();

  Stream<void> get homeDateRangeStream => _homeDateRangeUpdated.stream;

  late DurationUnit _largestDurationUnit;
  late DisplayDateRange _homeDateRange;

  late List<String> _statsSelectedActivityIds;
  late DisplayDateRange _statsDateRange;

  /// The largest unit used to display [Duration] objects. This value will never
  /// be `null`. Defaults to [DurationUnit.days].
  DurationUnit get largestDurationUnit => _largestDurationUnit;

  /// The date range used to display the total [Duration] of an [Activity] on
  /// the home page. This value will never be `null`. Defaults to
  /// [DisplayDateRange.allDates].
  DisplayDateRange get homeDateRange => _homeDateRange;

  List<String> get statsSelectedActivityIds => _statsSelectedActivityIds;
  DisplayDateRange get statsDateRange => _statsDateRange;

  /// Initializes preference properties. This method should be called on app
  /// start.
  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _largestDurationUnit =
        DurationUnit.values[prefs.getInt(_keyLargestDurationUnit) ?? 0];
    _homeDateRange = _getDisplayDateRange(prefs, _keyHomeDateRange);

    List<String> activityIds =
        prefs.getStringList(_keyStatsSelectedActivityIds) ?? [];
    _statsSelectedActivityIds = activityIds.isEmpty ? [] : activityIds;

    _statsDateRange = _getDisplayDateRange(prefs, _keyStatsDateRange);
  }

  DisplayDateRange _getDisplayDateRange(SharedPreferences prefs, String key) {
    return DisplayDateRange.of(
        prefs.getString(key) ?? DisplayDateRange.allDates.id)!;
  }

  void setLargestDurationUnit(DurationUnit unit) async {
    if (_largestDurationUnit == unit) {
      return;
    }

    _largestDurationUnit = unit;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLargestDurationUnit,
        DurationUnit.values.indexOf(_largestDurationUnit));

    _largestDurationUnitUpdated.notify();
  }

  void setHomeDateRange(DisplayDateRange range) async {
    if (_homeDateRange == range) {
      return;
    }

    _homeDateRange = range;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHomeDateRange, _homeDateRange.id);

    _homeDateRangeUpdated.notify();
  }

  void setStatsSelectedActivityIds(List<String>? ids) async {
    if (DeepCollectionEquality.unordered().equals(_statsSelectedActivityIds,
        ids))
    {
      return;
    }

    _statsSelectedActivityIds = ids ?? [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyStatsSelectedActivityIds,
        _statsSelectedActivityIds);
  }

  void setStatsDateRange(DisplayDateRange range) async {
    if (_statsDateRange == range) {
      return;
    }

    _statsDateRange = range;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStatsDateRange, _statsDateRange.id);
  }
}

class LargestDurationBuilder extends _SimpleStreamBuilder<DurationUnit> {
  LargestDurationBuilder({
    required AppManager app,
    required Widget Function(BuildContext, DurationUnit) builder,
  }) : super(
    app: app,
    stream: app.preferencesManager._largestDurationUnitUpdated.stream,
    valueCallback: () => app.preferencesManager.largestDurationUnit,
    builder: builder,
  );
}

class HomeDateRangeBuilder extends _SimpleStreamBuilder<DisplayDateRange> {
  HomeDateRangeBuilder({
    required AppManager app,
    required Widget Function(BuildContext, DisplayDateRange) builder,
  }) : super(
    app: app,
    stream: app.preferencesManager._homeDateRangeUpdated.stream,
    valueCallback: () => app.preferencesManager.homeDateRange,
    builder: builder,
  );
}

class _SimpleStreamBuilder<T> extends StatelessWidget {
  final AppManager app;
  final Stream stream;
  final T Function() valueCallback;
  final Widget Function(BuildContext, T) builder;

  _SimpleStreamBuilder({
    required this.app,
    required this.stream,
    required this.valueCallback,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: stream,
      builder: (BuildContext context, _) => builder(context, valueCallback()),
    );
  }
}