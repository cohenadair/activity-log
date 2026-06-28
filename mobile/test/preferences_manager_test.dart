import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stubbed_managers.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StubbedManagers.create();
    PreferencesManager.reset();
    await PreferencesManager.get.init();
  });

  test("init defaults activitySortOption to alphabetical when not set", () {
    expect(
      PreferencesManager.get.activitySortOption,
      ActivitySortOption.alphabetical,
    );
  });

  test("init loads activitySortOption from SharedPreferences", () async {
    SharedPreferences.setMockInitialValues({
      "preferences.activitySortOption": ActivitySortOption.totalTime.index,
    });
    PreferencesManager.reset();
    await PreferencesManager.get.init();

    expect(
      PreferencesManager.get.activitySortOption,
      ActivitySortOption.totalTime,
    );
  });

  test("setActivitySortOption does nothing when option is the same", () async {
    var emitted = false;
    PreferencesManager.get.activitySortOptionStream.listen((_) {
      emitted = true;
    });

    await PreferencesManager.get.setActivitySortOption(
      ActivitySortOption.alphabetical,
    );

    expect(emitted, isFalse);
    expect(
      PreferencesManager.get.activitySortOption,
      ActivitySortOption.alphabetical,
    );
  });

  test("setActivitySortOption saves new option and notifies", () async {
    var emitted = false;
    PreferencesManager.get.activitySortOptionStream.listen((_) {
      emitted = true;
    });

    await PreferencesManager.get.setActivitySortOption(
      ActivitySortOption.totalTime,
    );
    await Future.delayed(Duration.zero);

    expect(emitted, isTrue);
    expect(
      PreferencesManager.get.activitySortOption,
      ActivitySortOption.totalTime,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getInt("preferences.activitySortOption"),
      ActivitySortOption.totalTime.index,
    );
  });
}
