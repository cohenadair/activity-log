import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/fullscreen_activity_page.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mobile/widgets/activity_list_tile.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.preferencesManager.largestDurationUnitStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.hours);

    when(
      managers.dataManager.activitiesUpdatedStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      managers.dataManager.activity(any),
    ).thenAnswer((_) => Future.value(ActivityBuilder("Test").build));
    when(
      managers.dataManager.inProgressSession(any),
    ).thenAnswer((_) => Future.value(null));
  });

  testWidgets("Expand button opens full screen activity", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => Material(
          child: ActivityListTile(
            model: ActivityListTileModel(ActivityBuilder("Test").build),
            onTap: (_) {},
            onTapStartSession: () {},
            onTapEndSession: () {},
          ),
        ),
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.fullscreen));
    expect(find.byType(FullscreenActivityPage), findsOneWidget);
  });
}
