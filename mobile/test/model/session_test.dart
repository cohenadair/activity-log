import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/session.dart';

import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  group("Session builder", () {
    test("Pin to date range start", () {
      SessionBuilder builder = SessionBuilder("0")
        ..startTimestamp = DateTime(2018, 1, 15, 3).millisecondsSinceEpoch
        ..endTimestamp = DateTime(2018, 3, 10).millisecondsSinceEpoch;

      Session session = builder.pinToDateRange(null).build;
      expect(session.startDateTime, equals(session.startDateTime));

      var dateRange = DateRange(
        startTimestamp: Int64(
          TimeManager.get.dateTimeFromValues(2018, 2, 1).millisecondsSinceEpoch,
        ),
        endTimestamp: Int64(
          TimeManager.get
              .dateTimeFromValues(2018, 2, 15)
              .millisecondsSinceEpoch,
        ),
      );

      session = builder.pinToDateRange(dateRange).build;
      expect(session.startDateTime, equals(dateRange.startDate));
      expect(session.endDateTime, equals(dateRange.endDate));

      managers.lib.stubCurrentTime(DateTime(2019, 1, 2));
      builder
        ..endTimestamp = null
        ..endNow();
      expect(builder.build.endDateTime!.year, 2019);
      expect(builder.build.endDateTime!.month, 1);
      expect(builder.build.endDateTime!.day, 2);
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

      builder1.endTimestamp = 250;
      expect(builder1.build > builder2.build, isFalse);

      // <
      expect(builder1.build < builder2.build, isTrue);

      builder1.endTimestamp = 750;
      expect(builder1.build < builder2.build, isFalse);

      // <=
      builder1.endTimestamp = 500;
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
      builder1.endTimestamp = 100;
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
