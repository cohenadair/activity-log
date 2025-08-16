import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_range.dart';

void main() {
  test("fromPreference with null/empty input returns allDates", () {
    expect(DateRanges.fromPreference(null),
        DateRange(period: DateRange_Period.allDates));
    expect(DateRanges.fromPreference(""),
        DateRange(period: DateRange_Period.allDates));
  });

  test("fromPreference with legacy input", () {
    expect(DateRanges.fromPreference("last7Days"),
        DateRange(period: DateRange_Period.last7Days));
  });

  test("fromPreference parsed from invalid JSON returns allDates", () {
    expect(DateRanges.fromPreference("bad JSON"),
        DateRange(period: DateRange_Period.allDates));
  });

  test("fromPreference parsed from valid JSON", () {
    expect(DateRanges.fromPreference('{"1":9}'),
        DateRange(period: DateRange_Period.last7Days));
  });
}
