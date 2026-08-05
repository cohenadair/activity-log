import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/stats_date_range_picker.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create(); // For TimeManager.
  });

  testWidgets("Initially set custom date range", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => StatsDateRangePicker(
          initialValue: DateRange(
            period: DateRange_Period.custom,
            startTimestamp: Int64(
              TimeManager.get
                  .dateTimeFromValues(2020, 1, 1)
                  .millisecondsSinceEpoch,
            ),
            endTimestamp: Int64(
              TimeManager.get
                  .dateTimeFromValues(2020, 2, 1)
                  .millisecondsSinceEpoch,
            ),
            timeZone: TimeManager.get.currentTimeZone,
          ),
          onDurationPicked: (_) {},
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Jan 1, 2020 to Feb 1, 2020"));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text("Jan 1, 2020 to Feb 1, 2020"), findsOneWidget);
  });

  testWidgets("Custom date range picker includes entire last day", (
    tester,
  ) async {
    managers.lib.stubCurrentTime(DateTime(2020, 1, 15));

    DateRange? pickedRange;
    await tester.pumpWidget(
      Testable(
        (_) => StatsDateRangePicker(
          initialValue: DateRange(period: DateRange_Period.allDates),
          onDurationPicked: (range) => pickedRange = range,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("All dates"));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text("Custom"));

    // Pick a date range from the 3rd to the 10th within the calendar.
    await tapAndSettle(tester, find.text("3").first);
    await tapAndSettle(tester, find.text("10").first);
    await tapAndSettle(tester, find.text("SAVE"));

    // The end timestamp should be midnight the day *after* the last picked
    // day, so the entirety of the last picked day is included in the range.
    expect(
      pickedRange!.endTimestamp,
      Int64(
        TimeManager.get.dateTimeFromValues(2020, 1, 11).millisecondsSinceEpoch,
      ),
    );
  });
}
