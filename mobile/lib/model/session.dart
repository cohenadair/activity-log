import 'package:flutter/material.dart';
import 'package:mobile/model/model.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/time.dart';

class Session extends Model implements Comparable<Session> {
  static final keyActivityId = "activity_id";
  static final keyStartTimestamp = "start_timestamp";
  static final keyEndTimestamp = "end_timestamp";

  final String _activityId;
  final int _startTimestamp;
  final int _endTimestamp;
  final Clock _clock;

  String get activityId => _activityId;
  int get startTimestamp => _startTimestamp;
  int get endTimestamp => _endTimestamp;

  Session.fromMap(Map<String, dynamic> map)
    : _activityId = map[keyActivityId],
      _startTimestamp = map[keyStartTimestamp],
      _endTimestamp = map[keyEndTimestamp],
      _clock = Clock(),
      super.fromMap(map);

  Session.fromBuilder(SessionBuilder builder)
    : _activityId = builder.activityId,
      _startTimestamp = builder.startTimestamp,
      _endTimestamp = builder.endTimestamp,
      _clock = builder.clock,
      super.fromBuilder(builder);

  int get millisecondsDuration {
    if (_endTimestamp == null) {
      // Session isn't over yet.
      return _clock.now().millisecondsSinceEpoch - _startTimestamp;
    }
    return _endTimestamp - _startTimestamp;
  }

  Duration get duration => Duration(milliseconds: millisecondsDuration);

  DateTime get startDateTime =>
      DateTime.fromMillisecondsSinceEpoch(startTimestamp);

  DateTime get endDateTime => endTimestamp == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(endTimestamp);

  DateRange get dateRange =>
      DateRange(startDate: startDateTime, endDate: endDateTime);

  TimeOfDay get startTimeOfDay => TimeOfDay.fromDateTime(startDateTime);
  TimeOfDay get endTimeOfDay => endDateTime == null
      ? null
      : TimeOfDay.fromDateTime(endDateTime);

  bool get inProgress {
    return _endTimestamp == null;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      keyActivityId : _activityId,
      keyStartTimestamp : _startTimestamp,
      keyEndTimestamp : _endTimestamp,
    }..addAll(super.toMap());
  }

  operator >(other) {
    return other is Session
        && millisecondsDuration > other.millisecondsDuration;
  }

  operator >=(other) {
    return other is Session
        && millisecondsDuration >= other.millisecondsDuration;
  }

  operator <(other) {
    return !(this >= other);
  }

  operator <=(other) {
    return !(this > other);
  }

  @override
  int compareTo(Session other) {
    int durationCompare =
        this.millisecondsDuration.compareTo(other.millisecondsDuration);

    if (durationCompare == 0) {
      // Fallback on session start time.
      return this.startDateTime.compareTo(other.startDateTime);
    }

    return durationCompare;
  }
}

class SessionBuilder extends ModelBuilder {
  String activityId;
  int startTimestamp;
  int endTimestamp;
  Clock clock;

  SessionBuilder(this.activityId);

  SessionBuilder.fromSession(Session session)
      : activityId = session._activityId,
        startTimestamp = session._startTimestamp,
        endTimestamp = session._endTimestamp,
        super.fromModel(session);

  SessionBuilder endNow() {
    if (clock == null) {
      endTimestamp = DateTime.now().millisecondsSinceEpoch;
    } else {
      endTimestamp = clock.now().millisecondsSinceEpoch;
    }
    return this;
  }

  /// Pins the session start and end time to the given [DateRange], if the
  /// session falls outside said range.
  SessionBuilder pinToDateRange(DateRange dateRange) {
    if (dateRange == null) {
      return this;
    }

    if (startTimestamp < dateRange.startMs) {
      startTimestamp = dateRange.startMs;
    }

    if (endTimestamp != null && endTimestamp > dateRange.endMs) {
      endTimestamp = dateRange.endMs;
    }

    return this;
  }

  Session get build {
    if (clock == null) {
      clock = Clock();
    }

    if (startTimestamp == null) {
      startTimestamp = clock.now().millisecondsSinceEpoch;
    }

    return Session.fromBuilder(this);
  }
}