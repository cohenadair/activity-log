import 'package:mobile/model/session.dart';
import 'package:mobile/utils/time_utils.dart';
import 'package:uuid/uuid.dart';

class Activity {
  final String _id;
  final String _name;
  List<Session> _sessions = [];
  Session _currentSession;

  String get id => _id;
  String get name => _name;
  List<Session> get sessions => List.from(_sessions);

  Activity._fromBuilder(ActivityBuilder builder)
    : _id = builder.id,
      _name = builder.name,
      _sessions = builder.sessions,
      _currentSession = builder.currentSession;

  bool get isRunning => _currentSession != null;

  String get displayDuration {
    int totalMillis = 0;

    // Add all previous sessions.
    sessions.forEach((session) => totalMillis += session.millisecondsDuration);

    // Current session.
    if (_currentSession != null) {
      totalMillis += _currentSession.millisecondsDuration;
    }

    int hours = (totalMillis / TimeUtils.msInHour).floor();
    totalMillis -= hours * TimeUtils.msInHour;
    int minutes = (totalMillis / TimeUtils.msInMinute).floor();
    totalMillis -= minutes * TimeUtils.msInMinute;
    int seconds = (totalMillis / TimeUtils.msInSecond).floor();

    return hours.toString() + 'h ' +
           minutes.toString() + 'm ' +
           seconds.toString() + 's';
  }

  void startSession() {
    if (_currentSession != null) {
      // Can't start a new session if one already exists.
      return;
    }
    _currentSession = Session();
  }

  void endSession() {
    if (_currentSession == null) {
      // Can't end a session that hasn't started yet.
      return;
    }

    _currentSession.end();
    _sessions.add(_currentSession);
    _currentSession = null;
  }
}

class ActivityBuilder {
  String id = Uuid().v1();
  String name;
  List<Session> sessions = [];
  Session currentSession;

  ActivityBuilder(this.name);

  ActivityBuilder.fromActivity(Activity activity)
    : id = activity._id,
      name = activity._name,
      sessions = activity._sessions,
      currentSession = activity._currentSession;

  Activity get build {
    return Activity._fromBuilder(this);
  }
}
