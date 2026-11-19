import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/widgets/activity_picker.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  final running = ActivityBuilder("Running").build;
  final swimming = ActivityBuilder("Swimming").build;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.dataManager.activitiesUpdatedStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      managers.dataManager.activities,
    ).thenAnswer((_) async => [running, swimming]);
    when(managers.subscriptionManager.isFree).thenReturn(false);
  });

  Future<Set<Activity>?> pickAndDone(
    WidgetTester tester, {
    required Set<Activity> initialActivities,
    required List<String> taps,
  }) async {
    Set<Activity>? picked;
    await pumpContext(
      tester,
      (_) => ActivityPicker(
        initialActivities: initialActivities,
        onPickedActivitiesChanged: (activities) => picked = activities,
      ),
    );
    await tester.pumpAndSettle();

    // Open the picker page.
    await tapAndSettle(tester, find.text(initialActivities.first.name));
    for (final text in taps) {
      await tapAndSettle(tester, find.text(text).last);
    }
    await tapAndSettle(tester, find.text("DONE"));
    return picked;
  }

  testWidgets("Done with nothing selected picks all activities", (
    tester,
  ) async {
    expect(
      await pickAndDone(
        tester,
        initialActivities: {running},
        taps: ["Running"],
      ),
      isEmpty,
    );
    // The picker page closed.
    expect(find.text("DONE"), findsNothing);
  });

  testWidgets("Picking all activities invokes callback with empty set", (
    tester,
  ) async {
    expect(
      await pickAndDone(
        tester,
        initialActivities: {running},
        taps: ["All activities"],
      ),
      isEmpty,
    );
  });

  testWidgets("Picking activities invokes callback with picked set", (
    tester,
  ) async {
    expect(
      await pickAndDone(
        tester,
        initialActivities: {running},
        taps: ["Swimming"],
      ),
      {running, swimming},
    );
  });
}
