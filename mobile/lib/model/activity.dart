import 'package:mobile/model/model.dart';

class Activity extends Model {
  static final keyName = "name";
  static final keyCurrentSessionId = "currentSessionId";

  final String _name;
  final String _currentSessionId;

  String get name => _name;
  String get currentSessionId => _currentSessionId;

  Activity.fromMap(Map<String, dynamic> map)
    : _name = map[keyName],
      _currentSessionId = map[keyCurrentSessionId],
      super.fromMap(map);

  Activity.fromBuilder(ActivityBuilder builder)
    : _name = builder.name,
      _currentSessionId = builder.currentSessionId,
      super.fromBuilder(builder);

  bool get isRunning => _currentSessionId != null;

  @override
  Map<String, dynamic> toMap() {
    return {
      keyName : name,
      keyCurrentSessionId : _currentSessionId,
    };
  }
}

class ActivityBuilder extends ModelBuilder {
  String name;
  String currentSessionId;

  ActivityBuilder(this.name);

  ActivityBuilder.fromActivity(Activity activity)
    : name = activity._name,
      currentSessionId = activity._currentSessionId,
      super.fromModel(activity);

  Activity get build {
    return Activity.fromBuilder(this);
  }
}
