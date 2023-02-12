import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/time.dart';

void main() {
  group("Session builder", () {
    test("Pin to date range start", () {
      SessionBuilder builder = SessionBuilder("0")
        ..startTimestamp = DateTime(2018, 1, 15, 3).millisecondsSinceEpoch
        ..endTimestamp = DateTime(2018, 3, 10).millisecondsSinceEpoch;

      Session session = builder.pinToDateRange(null).build;
      expect(session.startDateTime, equals(session.startDateTime));

      DateRange dateRange = DateRange(
        startDate: DateTime(2018, 2, 1),
        endDate: DateTime(2018, 2, 15),
      );

      session = builder.pinToDateRange(dateRange).build;
      expect(session.startDateTime, equals(dateRange.startDate));
      expect(session.endDateTime, equals(dateRange.endDate));

      var clock = Clock.fixed(DateTime(2019, 1, 1));
      builder
        ..endTimestamp = null
        ..clock = clock
        ..endNow();
      expect(builder.build.endDateTime, equals(clock.now()));
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

  group("Comparable", () {
    SessionBuilder builder1 = SessionBuilder("")
      ..startTimestamp = 0
      ..endTimestamp = 750;

    SessionBuilder builder2 = SessionBuilder("")
      ..startTimestamp = 500
      ..endTimestamp = 1000;

    test("Sessions with different durations", () {
      // Greater than
      expect(builder1.build.compareTo(builder2.build), equals(1));

      // Less than
      builder1..endTimestamp = 100;
      expect(builder1.build.compareTo(builder2.build), equals(-1));
    });

    test("Sessions with equal durations and different start times", () {
      builder1
        ..startTimestamp = 0
        ..endTimestamp = 250;
      builder1
        ..startTimestamp = 500
        ..endTimestamp = 750;

      // Less than
      expect(builder1.build.compareTo(builder2.build), equals(-1));

      // Greater than
      expect(builder2.build.compareTo(builder1.build), equals(1));

      // Equal
      builder1
        ..startTimestamp = 0
        ..endTimestamp = 250;
      expect(builder2.build.compareTo(builder1.build), equals(1));
    });
  });
}
