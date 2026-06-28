import 'package:mobile/model/model.dart';

enum ActivitySortOption {
  totalTime,
  mostRecentSession,
  creationDate,
  alphabetical,
}

class Activity extends Model {
  static const keyName = "name";
  static const keyCurrentSessionId = "current_session_id";
  static const keyCurrentLiveActivityId = "current_live_activity_id";
  static const keyIsArchived = "is_archived";
  static const keyIsHiddenFromStats = "is_hidden_from_stats";
  static const keyCreatedAt = "created_at";

  final String _name;
  final String? _currentSessionId;
  final String? _currentLiveActivityId;
  final bool isArchived;
  final bool isHiddenFromStats;
  final int createdAt;

  String get name => _name;

  String? get currentSessionId => _currentSessionId;

  String? get currentLiveActivityId => _currentLiveActivityId;

  Activity.fromMap(super.map)
    : _name = map[keyName],
      _currentSessionId = map[keyCurrentSessionId],
      _currentLiveActivityId = map[keyCurrentLiveActivityId],
      isArchived = map[keyIsArchived] == 1,
      isHiddenFromStats = map[keyIsHiddenFromStats] == 1,
      createdAt = map[keyCreatedAt] ?? 0,
      super.fromMap();

  Activity.fromBuilder(ActivityBuilder super.builder)
    : _name = builder.name,
      _currentSessionId = builder.currentSessionId,
      _currentLiveActivityId = builder.currentLiveActivityId,
      isArchived = builder.isArchived,
      isHiddenFromStats = builder.isHiddenFromStats,
      createdAt = builder.createdAt,
      super.fromBuilder();

  bool get isRunning => _currentSessionId != null;

  @override
  Map<String, dynamic> toMap() {
    return {
      keyName: name,
      keyCurrentSessionId: _currentSessionId,
      keyCurrentLiveActivityId: _currentLiveActivityId,
      keyIsArchived: isArchived ? 1 : 0,
      keyIsHiddenFromStats: isHiddenFromStats ? 1 : 0,
      keyCreatedAt: createdAt,
    }..addAll(super.toMap());
  }

  // Don't include currentLiveActivityId here as it is an ID local to the device
  // and doesn't make sense to backup.
  Map<String, dynamic> toJson() {
    return {
      keyName: name,
      keyCurrentSessionId: _currentSessionId,
      keyIsArchived: isArchived ? 1 : 0,
      keyIsHiddenFromStats: isHiddenFromStats ? 1 : 0,
      keyCreatedAt: createdAt,
    }..addAll(super.toMap());
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
  bool isArchived;
  bool isHiddenFromStats;

  int createdAt = 0;

  ActivityBuilder(this.name) : isArchived = false, isHiddenFromStats = false;

  ActivityBuilder.fromActivity(Activity super.activity)
    : name = activity._name,
      currentSessionId = activity._currentSessionId,
      currentLiveActivityId = activity._currentLiveActivityId,
      isArchived = activity.isArchived,
      isHiddenFromStats = activity.isHiddenFromStats,
      createdAt = activity.createdAt,
      super.fromModel();

  @override
  Activity get build {
    return Activity.fromBuilder(this);
  }
}
