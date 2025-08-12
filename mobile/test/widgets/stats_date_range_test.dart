import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:flutter_test/flutter_test.dart';

import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  assertDateRangePeriod({
    required DateRange_Period period,
    required DateTime now,
    required DateTime expectedStart,
    DateTime? expectedEnd,
  }) {
    managers.lib.stubCurrentTime(now);
    var dateRange = DateRange(period: period);
    expect(dateRange.startMs, equals(expectedStart.millisecondsSinceEpoch));
    expect(
        dateRange.endMs, equals((expectedEnd ?? now).millisecondsSinceEpoch));
  }

  group("StatsDateRange.today", () {
    test("Today", () {
      assertDateRangePeriod(
        period: DateRange_Period.today,
        now: DateTime(2019, 1, 15, 15, 30),
        expectedStart: DateTime(2019, 1, 15),
      );
    });
  });

  group("StatsDateRange.yesterday", () {
    test("Yesterday", () {
      assertDateRangePeriod(
        period: DateRange_Period.yesterday,
        now: DateTime(2019, 1, 15, 15, 30),
        expectedStart: DateTime(2019, 1, 14),
        expectedEnd: DateTime(2019, 1, 15),
      );
    });
  });

  group("StatsDateRange.thisWeek", () {
    test("This week - year overlap", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisWeek,
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 31, 0, 0, 0),
      );
    });

    test("This week - within the same month", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisWeek,
        now: DateTime(2019, 2, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 11, 0, 0, 0),
      );
    });

    test("This week - same day as week start", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisWeek,
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 2, 4, 0, 0, 0),
      );
    });

    test("This week - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisWeek,
        now: DateTime(2019, 3, 10, 15, 30),
        expectedStart: DateTime(2019, 3, 4, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.thisMonth", () {
    test("This month - first day", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisMonth,
        now: DateTime(2019, 2, 1, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
      );
    });

    test("This month - last day", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisMonth,
        now: DateTime(2019, 3, 31, 15, 30),
        expectedStart: DateTime(2019, 3, 1, 0, 0, 0),
      );

      assertDateRangePeriod(
        period: DateRange_Period.thisMonth,
        now: DateTime(2019, 2, 28, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
      );

      assertDateRangePeriod(
        period: DateRange_Period.thisMonth,
        now: DateTime(2019, 4, 30, 15, 30),
        expectedStart: DateTime(2019, 4, 1, 0, 0, 0),
      );
    });

    test("This month - somewhere in the middle", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisMonth,
        now: DateTime(2019, 5, 17, 15, 30),
        expectedStart: DateTime(2019, 5, 1, 0, 0, 0),
      );
    });

    test("This month - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisMonth,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 3, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.thisYear", () {
    test("This year - first day", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisYear,
        now: DateTime(2019, 1, 1, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - last day", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisYear,
        now: DateTime(2019, 12, 31, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - somewhere in the middle", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisYear,
        now: DateTime(2019, 5, 17, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.thisYear,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastWeek", () {
    test("Last week - year overlap", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastWeek,
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 24, 0, 0, 0),
        expectedEnd: DateTime(2018, 12, 31, 0, 0, 0),
      );
    });

    test("Last week - within the same month", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastWeek,
        now: DateTime(2019, 2, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 4, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 11, 0, 0, 0),
      );
    });

    test("Last week - same day as week start", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastWeek,
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 1, 28, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 4, 0, 0, 0),
      );
    });

    test("Last week - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastWeek,
        now: DateTime(2019, 3, 13, 15, 30),
        // TODO: Investigate how to handle daylight savings.
        expectedStart: DateTime(2019, 3, 3, 23, 0, 0),
        expectedEnd: DateTime(2019, 3, 11, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastMonth", () {
    test("Last month - year overlap", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastMonth,
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last month - within same year", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastMonth,
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 1, 0, 0, 0),
      );
    });

    test("Last month - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastMonth,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 3, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastYear", () {
    test("Last year - normal case", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastYear,
        now: DateTime(2019, 12, 26, 15, 30),
        expectedStart: DateTime(2018, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last year - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.lastYear,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2018, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.last7Days", () {
    test("Last 7 days - normal case", () {
      assertDateRangePeriod(
        period: DateRange_Period.last7Days,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 2, 13, 15, 30, 0),
      );
    });

    test("Last 7 days - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.last7Days,
        now: DateTime(2019, 3, 13, 15, 30),
        // TODO: Investigate how to handle daylight savings.
        expectedStart: DateTime(2019, 3, 6, 14, 30, 0),
      );
    });
  });

  group("StatsDateRange.last14Days", () {
    test("Last 14 days - normal case", () {
      assertDateRangePeriod(
        period: DateRange_Period.last14Days,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 2, 6, 15, 30, 0),
      );
    });

    test("Last 14 days - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.last14Days,
        now: DateTime(2019, 3, 13, 15, 30),
        // TODO: Investigate how to handle daylight savings.
        expectedStart: DateTime(2019, 2, 27, 14, 30, 0),
      );
    });
  });

  group("StatsDateRange.last30Days", () {
    test("Last 30 days - normal case", () {
      assertDateRangePeriod(
        period: DateRange_Period.last30Days,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 1, 21, 15, 30, 0),
      );
    });

    test("Last 30 days - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.last30Days,
        now: DateTime(2019, 3, 13, 15, 30),
        // TODO: Investigate how to handle daylight savings.
        expectedStart: DateTime(2019, 2, 11, 14, 30, 0),
      );
    });
  });

  group("StatsDateRange.last60Days", () {
    test("Last 60 days - normal case", () {
      assertDateRangePeriod(
        period: DateRange_Period.last60Days,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2018, 12, 22, 15, 30, 0),
      );
    });

    test("Last 60 days - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.last60Days,
        now: DateTime(2019, 3, 13, 15, 30),
        // TODO: Investigate how to handle daylight savings.
        expectedStart: DateTime(2019, 1, 12, 14, 30, 0),
      );
    });
  });

  group("StatsDateRange.last12Months", () {
    test("Last 12 months - normal case", () {
      assertDateRangePeriod(
        period: DateRange_Period.last12Months,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2018, 2, 20, 15, 30),
      );
    });

    test("Last 12 months - daylight savings change", () {
      assertDateRangePeriod(
        period: DateRange_Period.last12Months,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2018, 3, 13, 15, 30),
      );
    });
  });
}
