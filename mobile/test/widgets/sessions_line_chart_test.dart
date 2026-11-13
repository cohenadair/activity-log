import 'package:community_charts_flutter/community_charts_flutter.dart'
    as f_charts;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/duration.dart';
import 'package:mobile/widgets/sessions_line_chart.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/mocks.mocks.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  late Session session;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.preferencesManager.largestDurationUnit,
    ).thenReturn(AppDurationUnit.hours);

    session =
        (SessionBuilder("activity_id")
              ..startTimestamp = DateTime(2024, 1, 1, 9).millisecondsSinceEpoch
              ..endTimestamp = DateTime(2024, 1, 1, 10).millisecondsSinceEpoch)
            .build;
  });

  Future<void> pumpChart(WidgetTester tester) async {
    await pumpContext(tester, (_) => SessionsLineChart(sessions: [session]));
    await tester.pumpAndSettle();
  }

  Future<void> changeSelection(
    WidgetTester tester,
    List<f_charts.SeriesDatum<num>> selectedData,
  ) async {
    tester
        .widget<f_charts.LineChart>(find.byType(f_charts.LineChart))
        .selectionModels!
        .first
        .changedListener!(f_charts.SelectionModel(selectedData: selectedData));
    await tester.pumpAndSettle();
  }

  testWidgets("Selecting a session shows its summary", (tester) async {
    await pumpChart(tester);
    expect(find.byType(DateDurationText), findsNothing);

    await changeSelection(tester, [
      f_charts.SeriesDatum(MockImmutableSeries<num>(), session),
    ]);
    expect(find.byType(DateDurationText), findsOneWidget);
  });

  testWidgets("Clearing the selection hides the session summary", (
    tester,
  ) async {
    await pumpChart(tester);
    await changeSelection(tester, [
      f_charts.SeriesDatum(MockImmutableSeries<num>(), session),
    ]);
    expect(find.byType(DateDurationText), findsOneWidget);

    await changeSelection(tester, []);
    expect(tester.takeException(), isNull);
    expect(find.byType(DateDurationText), findsNothing);
  });
}
