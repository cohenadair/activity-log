import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/stats_date_range_picker.dart';

void main() {
  assertStatsDateRange({
    @required StatsDateRange dateRange,
    @required DateTime now,
    @required DateTime expected,
    DateTime expectedEnd,
  }) {
    DateRange range = dateRange.getValue(now);
    expect(range.startDate, equals(expected));
    expect(range.endDate, equals(expectedEnd ?? now));
  }

  group("StatsDateRange.thisWeek", () {
    test("This week - year overlap", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisWeek,
        now: DateTime(2019, 1, 3, 15, 30),
        expected: DateTime(2018, 12, 31, 0, 0, 0),
      );
    });

    test("This week - within the same month", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisWeek,
        now: DateTime(2019, 2, 13, 15, 30),
        expected: DateTime(2019, 2, 11, 0, 0, 0),
      );
    });

    test("This week - same day as week start", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisWeek,
        now: DateTime(2019, 2, 4, 15, 30),
        expected: DateTime(2019, 2, 4, 0, 0, 0),
      );
    });

    test("This week - daylight savings change", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisWeek,
        now: DateTime(2019, 3, 10, 15, 30),
        expected: DateTime(2019, 3, 4, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.thisMonth", () {
    test("This month - first day", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisMonth,
        now: DateTime(2019, 2, 1, 15, 30),
        expected: DateTime(2019, 2, 1, 0, 0, 0),
      );
    });

    test("This month - last day", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisMonth,
        now: DateTime(2019, 3, 31, 15, 30),
        expected: DateTime(2019, 3, 1, 0, 0, 0),
      );

      assertStatsDateRange(
        dateRange: StatsDateRange.thisMonth,
        now: DateTime(2019, 2, 28, 15, 30),
        expected: DateTime(2019, 2, 1, 0, 0, 0),
      );

      assertStatsDateRange(
        dateRange: StatsDateRange.thisMonth,
        now: DateTime(2019, 4, 30, 15, 30),
        expected: DateTime(2019, 4, 1, 0, 0, 0),
      );
    });

    test("This month - somewhere in the middle", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisMonth,
        now: DateTime(2019, 5, 17, 15, 30),
        expected: DateTime(2019, 5, 1, 0, 0, 0),
      );
    });

    test("This month - daylight savings change", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisMonth,
        now: DateTime(2019, 3, 13, 15, 30),
        expected: DateTime(2019, 3, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.thisYear", () {
    test("This year - first day", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisYear,
        now: DateTime(2019, 1, 1, 15, 30),
        expected: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - last day", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisYear,
        now: DateTime(2019, 12, 31, 15, 30),
        expected: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - somewhere in the middle", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisYear,
        now: DateTime(2019, 5, 17, 15, 30),
        expected: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - daylight savings change", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.thisYear,
        now: DateTime(2019, 3, 13, 15, 30),
        expected: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastWeek", () {
    test("Last week - year overlap", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastWeek,
        now: DateTime(2019, 1, 3, 15, 30),
        expected: DateTime(2018, 12, 24, 0, 0, 0),
        expectedEnd: DateTime(2018, 12, 31, 0, 0, 0),
      );
    });

    test("Last week - within the same month", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastWeek,
        now: DateTime(2019, 2, 13, 15, 30),
        expected: DateTime(2019, 2, 4, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 11, 0, 0, 0),
      );
    });

    test("Last week - same day as week start", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastWeek,
        now: DateTime(2019, 2, 4, 15, 30),
        expected: DateTime(2019, 1, 28, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 4, 0, 0, 0),
      );
    });

    test("Last week - daylight savings change", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastWeek,
        now: DateTime(2019, 3, 13, 15, 30),
        // TODO: Investigate how to handle daylight savings.
        expected: DateTime(2019, 3, 3, 23, 0, 0),
        expectedEnd: DateTime(2019, 3, 11, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastMonth", () {
    test("Last month - year overlap", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastMonth,
        now: DateTime(2019, 1, 3, 15, 30),
        expected: DateTime(2018, 12, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last month - within same year", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastMonth,
        now: DateTime(2019, 2, 4, 15, 30),
        expected: DateTime(2019, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 1, 0, 0, 0),
      );
    });

    test("Last month - daylight savings change", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastMonth,
        now: DateTime(2019, 3, 13, 15, 30),
        expected: DateTime(2019, 2, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 3, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastYear", () {
    test("Last year - normal case", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastYear,
        now: DateTime(2019, 12, 26, 15, 30),
        expected: DateTime(2018, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last year - daylight savings change", () {
      assertStatsDateRange(
        dateRange: StatsDateRange.lastYear,
        now: DateTime(2019, 3, 13, 15, 30),
        expected: DateTime(2018, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });
  });
}