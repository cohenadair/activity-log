import 'package:uuid/uuid.dart';

class Activity {
  String _id;
  String _name;
  String get name => _name;

  Activity(this._name) {
    _id = Uuid().v1();
  }

  Activity.fromMap(Map<String, dynamic> map)
      : _id = map['id'],
        _name = map['string'];

  Activity.fromActivity(Activity activity)
      : _id = activity._id,
        _name = activity._name;

  /// Updates all fields of the receiver, with the exception of id.
  void updateFromActivity(Activity activity) {
    _name = activity._name;
  }

  Map<String, dynamic> toMap() => {
    'id' : _id,
    'name': _name
  };

  @override
  bool operator ==(other) {
    return _id == other._id;
  }

  @override
  int get hashCode => _id.hashCode;
}
