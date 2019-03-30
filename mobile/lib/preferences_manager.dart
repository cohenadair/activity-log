import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  final _keyLargestDurationUnit = "preferences.largestDurationUnit";

  final StreamController<DurationUnit> _largestDurationUnitUpdated =
      StreamController.broadcast();

  Stream<DurationUnit> getLargestDurationUnitStream() {
    return _largestDurationUnitUpdated.stream;
  }

  void setLargestDurationUnit(DurationUnit unit) async {
    if ((await largestDurationUnit) == unit) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLargestDurationUnit,
        DurationUnit.values.indexOf(unit));
    _notifyLargestDurationUnitUpdated(unit);
  }

  Future<DurationUnit> get largestDurationUnit async {
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
class LargestDurationFutureBuilder extends StatefulWidget {
  final AppManager app;
  final Widget Function(DurationUnit) builder;

  LargestDurationFutureBuilder({
    @required this.app,
    @required this.builder,
  }) : assert(app != null),
       assert(builder != null);

  @override
  _LargestDurationFutureBuilderState createState() =>
      _LargestDurationFutureBuilderState();
}

class _LargestDurationFutureBuilderState
    extends State<LargestDurationFutureBuilder>
{
  StreamSubscription<DurationUnit> _onDurationUnitUpdated;
  Future<DurationUnit> _durationUnitFuture;

  @override
  void initState() {
    super.initState();

    _onDurationUnitUpdated = widget.app.preferencesManager
        .getLargestDurationUnitStream().listen((_) {
          setState(() {
            _updateDurationUnitFuture();
          });
        });

    _updateDurationUnitFuture();
  }

  @override
  void dispose() {
    super.dispose();
    _onDurationUnitUpdated.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DurationUnit>(
      future: _durationUnitFuture,
      builder: (BuildContext context, AsyncSnapshot<DurationUnit> snapshot) {
        if (!snapshot.hasData) {
          return Empty();
        }

        return widget.builder(snapshot.data);
      },
    );
  }

  void _updateDurationUnitFuture() {
    _durationUnitFuture = widget.app.preferencesManager.largestDurationUnit;
  }
}