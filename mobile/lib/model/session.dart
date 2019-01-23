import 'package:mobile/model/model.dart';

class Session extends Model {
  static final keyActivityId = "activityId";
  static final keyStartTimestamp = "startTimestamp";
  static final keyEndTimestamp = "endTimestamp";

  final String _activityId;
  final int _startTimestamp;
  final int _endTimestamp;

  Session.fromMap(Map<String, dynamic> map)
      : _activityId = map[keyActivityId],
        _startTimestamp = map[keyStartTimestamp],
        _endTimestamp = map[keyEndTimestamp],
        super.fromMap(map);

  Session.fromBuilder(SessionBuilder builder)
      : _activityId = builder.activityId,
        _startTimestamp = builder.startTimestamp,
        _endTimestamp = builder.endTimestamp,
        super.fromBuilder(builder);

  int get millisecondsDuration {
    if (_endTimestamp == null) {
      // Session isn't over yet.
      return DateTime.now().millisecondsSinceEpoch - _startTimestamp;
    }
    return _endTimestamp - _startTimestamp;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      keyActivityId : _activityId,
      keyStartTimestamp : _startTimestamp,
      keyEndTimestamp : _endTimestamp,
    };
  }
}

class SessionBuilder extends ModelBuilder {
  String activityId;
  int startTimestamp = DateTime.now().millisecondsSinceEpoch;
  int endTimestamp;

  SessionBuilder(this.activityId);

  SessionBuilder.fromSession(Session session)
      : activityId = session._activityId,
        startTimestamp = session._startTimestamp,
        endTimestamp = session._endTimestamp,
        super.fromModel(session);

  SessionBuilder endNow() {
    endTimestamp = DateTime.now().millisecondsSinceEpoch;
    return this;
  }

  Session get build {
    return Session.fromBuilder(this);
  }
}