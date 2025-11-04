import 'package:mobile/model/model.dart';

class Activity extends Model {
  static const keyName = "name";
  static const keyCurrentSessionId = "current_session_id";
  static const keyCurrentLiveActivityId = "current_live_activity_id";

  final String _name;
  final String? _currentSessionId;
  final String? _currentLiveActivityId;

  String get name => _name;

  String? get currentSessionId => _currentSessionId;

  String? get currentLiveActivityId => _currentLiveActivityId;

  Activity.fromMap(super.map)
    : _name = map[keyName],
      _currentSessionId = map[keyCurrentSessionId],
      _currentLiveActivityId = map[keyCurrentLiveActivityId],
      super.fromMap();

  Activity.fromBuilder(ActivityBuilder super.builder)
    : _name = builder.name,
      _currentSessionId = builder.currentSessionId,
      _currentLiveActivityId = builder.currentLiveActivityId,
      super.fromBuilder();

  bool get isRunning => _currentSessionId != null;

  @override
  Map<String, dynamic> toMap() {
    return {
      keyName: name,
      keyCurrentSessionId: _currentSessionId,
      keyCurrentLiveActivityId: _currentLiveActivityId,
    }..addAll(super.toMap());
  }

  // Don't include currentLiveActivityId here as it is an ID local to the device
  // and doesn't make sense to backup.
  Map<String, dynamic> toJson() {
    return {keyName: name, keyCurrentSessionId: _currentSessionId}
      ..addAll(super.toMap());
  }

  @override
  bool operator ==(other) {
    return other is Activity && other.name == _name;
  }

  @override
  int get hashCode => _name.hashCode;
}

class ActivityBuilder extends ModelBuilder {
  String name;
  String? currentSessionId;
  String? currentLiveActivityId;

  ActivityBuilder(this.name);

  ActivityBuilder.fromActivity(Activity super.activity)
    : name = activity._name,
      currentSessionId = activity._currentSessionId,
      currentLiveActivityId = activity._currentLiveActivityId,
      super.fromModel();

  @override
  Activity get build {
    return Activity.fromBuilder(this);
  }
}
