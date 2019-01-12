import 'package:uuid/uuid.dart';

class Session {
  final String _id;
  final int _startTimestamp;
  int _endTimestamp;

  Session()
    : _id = Uuid().v1(),
      _startTimestamp = DateTime.now().millisecondsSinceEpoch;

  int get millisecondsDuration {
    if (_endTimestamp == null) {
      // Session isn't over yet.
      return DateTime.now().millisecondsSinceEpoch - _startTimestamp;
    }
    return _endTimestamp - _startTimestamp;
  }

  void end() {
    _endTimestamp = DateTime.now().millisecondsSinceEpoch;
  }
}