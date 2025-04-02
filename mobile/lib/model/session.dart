import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/model.dart';
import 'package:timezone/timezone.dart';

class Session extends Model implements Comparable<Session> {
  static const keyActivityId = "activity_id";
  static const keyStartTimestamp = "start_timestamp";
  static const keyEndTimestamp = "end_timestamp";
  static const keyIsBanked = "is_banked";

  final String _activityId;
  final int _startTimestamp;
  final int? _endTimestamp;
  final bool? _isBanked;

  String get activityId => _activityId;

  int get startTimestamp => _startTimestamp;

  int? get endTimestamp => _endTimestamp;

  bool get isBanked => _isBanked != null && _isBanked;

  Session.fromMap(Map<String, dynamic> map)
      : _activityId = map[keyActivityId],
        _startTimestamp = map[keyStartTimestamp] ?? -1,
        _endTimestamp = map[keyEndTimestamp],
        _isBanked = map[keyIsBanked] == 1,
        super.fromMap(map);

  Session.fromBuilder(SessionBuilder builder)
      : assert(builder.startTimestamp != null),
        _activityId = builder.activityId,
        _startTimestamp = builder.startTimestamp!,
        _endTimestamp = builder.endTimestamp,
        _isBanked = builder.isBanked,
        super.fromBuilder(builder);

  int get millisecondsDuration {
    if (_endTimestamp == null) {
      // Session isn't over yet.
      return TimeManager.get.currentTimestamp - _startTimestamp;
    }
    return _endTimestamp - _startTimestamp;
  }

  Duration get duration => Duration(milliseconds: millisecondsDuration);

  TZDateTime get startDateTime => TimeManager.get.dateTime(startTimestamp);

  TZDateTime? get endDateTime =>
      endTimestamp == null ? null : TimeManager.get.dateTime(endTimestamp!);

  TimeOfDay get startTimeOfDay => TimeOfDay.fromDateTime(startDateTime);

  TimeOfDay? get endTimeOfDay =>
      endDateTime == null ? null : TimeOfDay.fromDateTime(endDateTime!);

  bool get inProgress {
    return _endTimestamp == null;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      keyActivityId: _activityId,
      keyStartTimestamp: _startTimestamp,
      keyEndTimestamp: _endTimestamp,
      keyIsBanked: _isBanked != null && _isBanked ? 1 : 0,
    }..addAll(super.toMap());
  }

  operator >(other) {
    return other is Session &&
        millisecondsDuration > other.millisecondsDuration;
  }

  operator >=(other) {
    return other is Session &&
        millisecondsDuration >= other.millisecondsDuration;
  }

  operator <(other) {
    return !(this >= other);
  }

  operator <=(other) {
    return !(this > other);
  }

  @override
  int compareTo(Session other) {
    int durationCompare = millisecondsDuration.compareTo(
      other.millisecondsDuration,
    );

    if (durationCompare == 0) {
      // Fallback on session start time.
      return startDateTime.compareTo(other.startDateTime);
    }

    return durationCompare;
  }
}

class SessionBuilder extends ModelBuilder {
  String activityId;
  int? startTimestamp;
  int? endTimestamp;
  bool? isBanked;

  SessionBuilder(this.activityId);

  SessionBuilder.fromSession(Session session)
      : activityId = session._activityId,
        startTimestamp = session._startTimestamp,
        endTimestamp = session._endTimestamp,
        isBanked = session._isBanked,
        super.fromModel(session);

  SessionBuilder endNow() {
    endTimestamp = TimeManager.get.currentTimestamp;
    return this;
  }

  /// Pins the session start and end time to the given [DateRange], if the
  /// session falls outside said range.
  SessionBuilder pinToDateRange(DateRange? dateRange) {
    if (dateRange == null) {
      return this;
    }

    if (startTimestamp == null || startTimestamp! < dateRange.startMs) {
      startTimestamp = dateRange.startMs;
    }

    if (endTimestamp != null && endTimestamp! > dateRange.endMs) {
      endTimestamp = dateRange.endMs;
    }

    return this;
  }

  @override
  Session get build {
    startTimestamp ??= TimeManager.get.currentTimestamp;
    return Session.fromBuilder(this);
  }
}
