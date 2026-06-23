import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';

void main() {
  test("isArchived defaults to false in ActivityBuilder", () {
    final builder = ActivityBuilder("Test");
    expect(builder.isArchived, isFalse);
  });

  test("isHiddenFromStats defaults to false in ActivityBuilder", () {
    final builder = ActivityBuilder("Test");
    expect(builder.isHiddenFromStats, isFalse);
  });

  test("toMap includes isArchived as 0 when false", () {
    final activity = ActivityBuilder("Test").build;
    expect(activity.toMap()[Activity.keyIsArchived], 0);
  });

  test("toMap includes isArchived as 1 when true", () {
    final activity = (ActivityBuilder("Test")..isArchived = true).build;
    expect(activity.toMap()[Activity.keyIsArchived], 1);
  });

  test("toMap includes isHiddenFromStats as 0 when false", () {
    final activity = ActivityBuilder("Test").build;
    expect(activity.toMap()[Activity.keyIsHiddenFromStats], 0);
  });

  test("toMap includes isHiddenFromStats as 1 when true", () {
    final activity = (ActivityBuilder("Test")..isHiddenFromStats = true).build;
    expect(activity.toMap()[Activity.keyIsHiddenFromStats], 1);
  });

  test("toJson includes isArchived", () {
    final activity = (ActivityBuilder("Test")..isArchived = true).build;
    expect(activity.toJson()[Activity.keyIsArchived], 1);
  });

  test("toJson includes isHiddenFromStats", () {
    final activity = (ActivityBuilder("Test")..isHiddenFromStats = true).build;
    expect(activity.toJson()[Activity.keyIsHiddenFromStats], 1);
  });

  test("Activity.fromMap reads isArchived false when value is 0", () {
    final activity = Activity.fromMap({
      "id": "1",
      Activity.keyName: "Test",
      Activity.keyIsArchived: 0,
      Activity.keyIsHiddenFromStats: 0,
    });
    expect(activity.isArchived, isFalse);
  });

  test("Activity.fromMap reads isArchived true when value is 1", () {
    final activity = Activity.fromMap({
      "id": "1",
      Activity.keyName: "Test",
      Activity.keyIsArchived: 1,
      Activity.keyIsHiddenFromStats: 0,
    });
    expect(activity.isArchived, isTrue);
  });

  test("Activity.fromMap reads isHiddenFromStats true when value is 1", () {
    final activity = Activity.fromMap({
      "id": "1",
      Activity.keyName: "Test",
      Activity.keyIsArchived: 0,
      Activity.keyIsHiddenFromStats: 1,
    });
    expect(activity.isHiddenFromStats, isTrue);
  });

  test(
    "ActivityBuilder.fromActivity copies isArchived and isHiddenFromStats",
    () {
      final original =
          (ActivityBuilder("Test")
                ..isArchived = true
                ..isHiddenFromStats = true)
              .build;
      final builder = ActivityBuilder.fromActivity(original);
      expect(builder.isArchived, isTrue);
      expect(builder.isHiddenFromStats, isTrue);
    },
  );

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
