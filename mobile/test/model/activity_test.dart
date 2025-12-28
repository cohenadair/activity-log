import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';

void main() {
  test("toMap includes currentLiveActivityId", () {
    final activity = (ActivityBuilder(
      "Test",
    )..currentLiveActivityId = "test-id").build;
    expect(activity.toMap()[Activity.keyCurrentLiveActivityId], "test-id");
  });

  test("toJson does not include currentLiveActivityId", () {
    final activity = (ActivityBuilder(
      "Test",
    )..currentLiveActivityId = "test-id").build;
    expect(
      activity.toJson().containsKey(Activity.keyCurrentLiveActivityId),
      isFalse,
    );
  });
}
