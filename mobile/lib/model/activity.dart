class Activity {
  final String name;

  Activity(this.name);

  Activity.fromMap(Map<String, dynamic> map) : name = map['string'];

  Activity.fromActivity(Activity activity) : name = activity.name;

  Map<String, dynamic> toMap() => {
    'name': name
  };
}
