import 'package:uuid/uuid.dart';

import 'session.dart';

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

  int get totalMillisecondsDuration {
    int result = 0;
    sessions.forEach((session) => result += session.millisecondsDuration);
    return result;
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
    sessions.add(_currentSession);
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
