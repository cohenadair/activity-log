import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_time_utils.dart';

void main() {
  group("IsInFutureWithMinuteAccuracy", () {
    DateTime now = DateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2014, 6, 16, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 4, 16, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 14, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 11, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 12, 29, 46, 10001), now),
        isFalse,
      );
    });

    test("Value should be in the future", () {
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2016, 4, 14, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 6, 14, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 16, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 13, 29, 44, 9999), now),
        isTrue,
      );
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 12, 30, 44, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 12, 30, 45, 9999), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 12, 30, 44, 9999), now),
        isFalse,
      );
    });
  });

  group("IsInFutureWithDayAccuracy", () {
    DateTime now = DateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2014, 6, 16, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2015, 4, 16, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2015, 5, 14, 13, 31, 46, 10001), now),
        isFalse,
      );
    });

    test("Value should be in the future", () {
      expect(
        isInFutureWithDayAccuracy(DateTime(2016, 4, 14, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithDayAccuracy(DateTime(2015, 6, 14, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithDayAccuracy(DateTime(2015, 5, 16, 11, 29, 44, 9999), now),
        isTrue,
      );
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2015, 5, 15, 11, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2015, 5, 15, 12, 29, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithDayAccuracy(DateTime(2015, 5, 15, 13, 29, 44, 9999), now),
        isFalse,
      );
    });
  });

  group("DateTime", () {
    test("Days calculated correctly", () {
      DateRange range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 2, 1),
      );

      expect(range.days, equals(31));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 10),
      );

      expect(range.days, equals(9));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 1),
      );

      expect(range.days, equals(0));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 1, 15, 30),
      );

      expect(range.days, equals(0.6458333333333334));
    });

    test("Weeks calculated correctly", () {
      DateRange range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 2, 1),
      );

      expect(range.weeks, equals(4.428571428571429));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 3, 10),
      );

      expect(range.weeks, equals(9.714285714285714));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 1),
      );

      expect(range.weeks, equals(0));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 4),
      );

      expect(range.weeks, equals(0.42857142857142855));
    });

    test("Months calculated correctly", () {
      DateRange range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 2, 1),
      );

      expect(range.months, equals(1.0333333333333334));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 3, 10),
      );

      expect(range.months, equals(2.2666666666666666));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 1),
      );

      expect(range.months, equals(0));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 20),
      );

      expect(range.months, equals(0.6333333333333333));
    });
  });
}
