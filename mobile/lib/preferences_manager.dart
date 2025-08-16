import 'dart:async';

import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/void_stream_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/date_range.dart';
import 'package:mobile/utils/duration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static var _instance = PreferencesManager._();

  static PreferencesManager get get => _instance;

  @visibleForTesting
  static void set(PreferencesManager manager) => _instance = manager;

  @visibleForTesting
  static void suicide() => _instance = PreferencesManager._();

  PreferencesManager._();

  final _keyLargestDurationUnit = "preferences.largestDurationUnit";
  final _keyHomeDateRange = "preferences.homeDateRange";
  final _keyStatsSelectedActivityIds = "preferences.statsSelectedActivityIds";
  final _keyStatsDateRange = "preferences.statsDateRange";
  final _keyUserName = "preferences.userName";
  final _keyUserEmail = "preferences.userEmail";

  final VoidStreamController _largestDurationUnitUpdated =
      VoidStreamController();
  final VoidStreamController _homeDateRangeUpdated = VoidStreamController();

  Stream<void> get largestDurationUnitStream =>
      _largestDurationUnitUpdated.stream;

  Stream<void> get homeDateRangeStream => _homeDateRangeUpdated.stream;

  late AppDurationUnit _largestDurationUnit;
  late DateRange _homeDateRange;

  late List<String> _statsSelectedActivityIds;
  late DateRange _statsDateRange;
  late String? _userName;
  late String? _userEmail;

  /// The largest unit used to display [Duration] objects. This value will never
  /// be `null`. Defaults to [AppDurationUnit.days].
  AppDurationUnit get largestDurationUnit => _largestDurationUnit;

  /// The date range used to display the total [Duration] of an [Activity] on
  /// the home page. This value will never be `null`. Defaults to all dates.
  DateRange get homeDateRange => _homeDateRange;

  List<String> get statsSelectedActivityIds => _statsSelectedActivityIds;

  DateRange get statsDateRange => _statsDateRange;

  String? get userName => _userName;

  String? get userEmail => _userEmail;

  /// Initializes preference properties. This method should be called on app
  /// start.
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _largestDurationUnit =
        AppDurationUnit.values[prefs.getInt(_keyLargestDurationUnit) ?? 0];
    _homeDateRange =
        DateRanges.fromPreference(prefs.getString(_keyHomeDateRange));

    List<String> activityIds =
        prefs.getStringList(_keyStatsSelectedActivityIds) ?? [];
    _statsSelectedActivityIds = activityIds.isEmpty ? [] : activityIds;

    _statsDateRange =
        DateRanges.fromPreference(prefs.getString(_keyStatsDateRange));

    _userName = prefs.getString(_keyUserName);
    _userEmail = prefs.getString(_keyUserEmail);
  }

  void setLargestDurationUnit(AppDurationUnit unit) async {
    if (_largestDurationUnit == unit) {
      return;
    }

    _largestDurationUnit = unit;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _keyLargestDurationUnit,
      AppDurationUnit.values.indexOf(_largestDurationUnit),
    );

    _largestDurationUnitUpdated.notify();
  }

  void setHomeDateRange(DateRange range) async {
    if (_homeDateRange == range) {
      return;
    }

    _homeDateRange = range;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHomeDateRange, _homeDateRange.writeToJson());

    _homeDateRangeUpdated.notify();
  }

  void setStatsSelectedActivityIds(List<String>? ids) async {
    if (const DeepCollectionEquality.unordered().equals(
      _statsSelectedActivityIds,
      ids,
    )) {
      return;
    }

    _statsSelectedActivityIds = ids ?? [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyStatsSelectedActivityIds,
      _statsSelectedActivityIds,
    );
  }

  void setStatsDateRange(DateRange range) async {
    if (_statsDateRange == range) {
      return;
    }

    _statsDateRange = range;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStatsDateRange, _statsDateRange.writeToJson());
  }

  void setUserInfo(String name, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (name != _userName) {
      _userName = name;
      await prefs.setString(_keyUserName, name);
    }

    if (email != _userEmail) {
      _userEmail = email;
      await prefs.setString(_keyUserEmail, email);
    }
  }
}

class LargestDurationBuilder extends _SimpleStreamBuilder<AppDurationUnit> {
  LargestDurationBuilder({required super.builder})
      : super(
          stream: PreferencesManager.get.largestDurationUnitStream,
          valueCallback: () => PreferencesManager.get.largestDurationUnit,
        );
}

class HomeDateRangeBuilder extends _SimpleStreamBuilder<DateRange> {
  HomeDateRangeBuilder({required super.builder})
      : super(
          stream: PreferencesManager.get.homeDateRangeStream,
          valueCallback: () => PreferencesManager.get.homeDateRange,
        );
}

class _SimpleStreamBuilder<T> extends StatelessWidget {
  final Stream stream;
  final T Function() valueCallback;
  final Widget Function(BuildContext, T) builder;

  const _SimpleStreamBuilder({
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
