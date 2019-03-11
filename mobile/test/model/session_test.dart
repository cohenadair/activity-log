import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';

void main() {
  group("Session builder", () {
    test("Pin to date range start", () {
      SessionBuilder builder = SessionBuilder("0")
          ..startTimestamp = DateTime(2018, 1, 15, 3).millisecondsSinceEpoch
          ..endTimestamp = DateTime(2018, 3, 10).millisecondsSinceEpoch;

      DateRange dateRange = DateRange(
        startDate: DateTime(2018, 2, 1),
        endDate: DateTime(2018, 2, 15),
      );

      Session session = builder.pinToDateRange(dateRange).build;
      expect(session.startDateTime, equals(dateRange.startDate));
      expect(session.endDateTime, equals(dateRange.endDate));
    });
  });

  group("Operators", () {
    test(">=, <=, <, >", () {
      SessionBuilder builder1 = SessionBuilder("")
        ..startTimestamp = 0
        ..endTimestamp = 750;

      SessionBuilder builder2 = SessionBuilder("")
        ..startTimestamp = 500
        ..endTimestamp = 1000;

      // >
      expect(builder1.build > builder2.build, isTrue);

      builder1..endTimestamp = 250;
      expect(builder1.build > builder2.build, isFalse);

      // <
      expect(builder1.build < builder2.build, isTrue);

      builder1..endTimestamp = 750;
      expect(builder1.build < builder2.build, isFalse);

      // <=
      builder1..endTimestamp = 500;
      expect(builder1.build <= builder2.build, true);

      // >=
      expect(builder1.build >= builder2.build, true);
    });
  });
}