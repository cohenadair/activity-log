import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';

void main() {
  test("Activity.fromMap createdAt defaults to 0 when absent", () {
    final map = {
      "id": "1",
      "name": "Run",
      "is_archived": 0,
      "is_hidden_from_stats": 0,
    };
    expect(Activity.fromMap(map).createdAt, 0);
  });

  test("Activity.fromMap createdAt read from map", () {
    final map = {
      "id": "1",
      "name": "Run",
      "is_archived": 0,
      "is_hidden_from_stats": 0,
      "created_at": 99,
    };
    final activity = Activity.fromMap(map);
    expect(activity.createdAt, 99);
  });
}
