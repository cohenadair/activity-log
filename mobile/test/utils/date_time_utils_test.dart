import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_time_utils.dart';

void main() {
  group("IsInFutureWithMinuteAccuracy", () {
    DateTime now = DateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(isInFutureWithMinuteAccuracy(DateTime(2014, 6, 16, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 4, 16, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 5, 14, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 5, 15, 11, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 5, 15, 12, 29, 46, 10001), now), isFalse);
    });

    test("Value should be in the future", () {
      expect(isInFutureWithMinuteAccuracy(DateTime(2016, 4, 14, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 6, 14, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 5, 16, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 5, 15, 13, 29, 44, 9999), now), isTrue);
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 5, 15, 12, 30, 44, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 5, 15, 12, 30, 45, 9999), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(DateTime(2015, 5, 15, 12, 30, 44, 9999), now), isFalse);
    });
  });

  group("IsInFutureWithDayAccuracy", () {
    DateTime now = DateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(isInFutureWithDayAccuracy(DateTime(2014, 6, 16, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithDayAccuracy(DateTime(2015, 4, 16, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithDayAccuracy(DateTime(2015, 5, 14, 13, 31, 46, 10001), now), isFalse);
    });

    test("Value should be in the future", () {
      expect(isInFutureWithDayAccuracy(DateTime(2016, 4, 14, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithDayAccuracy(DateTime(2015, 6, 14, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithDayAccuracy(DateTime(2015, 5, 16, 11, 29, 44, 9999), now), isTrue);
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(isInFutureWithDayAccuracy(DateTime(2015, 5, 15, 11, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithDayAccuracy(DateTime(2015, 5, 15, 12, 29, 46, 10001), now), isFalse);
      expect(isInFutureWithDayAccuracy(DateTime(2015, 5, 15, 13, 29, 44, 9999), now), isFalse);
    });
  });
}