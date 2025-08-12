import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/log.dart';

const _log = Log("DateRanges");

extension DateRanges on DateRange {
  // TODO: Properly migrate to storing DateRange_Period rather than legacy IDs.
  static DateRange fromLegacyDisplayDateRangeId(String displayDateRangeId) {
    switch (displayDateRangeId) {
      case "allDates":
        return DateRange(period: DateRange_Period.allDates);
      case "today":
        return DateRange(period: DateRange_Period.today);
      case "yesterday":
        return DateRange(period: DateRange_Period.yesterday);
      case "thisWeek":
        return DateRange(period: DateRange_Period.thisWeek);
      case "thisMonth":
        return DateRange(period: DateRange_Period.thisMonth);
      case "thisYear":
        return DateRange(period: DateRange_Period.thisYear);
      case "lastWeek":
        return DateRange(period: DateRange_Period.lastWeek);
      case "lastMonth":
        return DateRange(period: DateRange_Period.lastMonth);
      case "lastYear":
        return DateRange(period: DateRange_Period.lastYear);
      case "last7Days":
        return DateRange(period: DateRange_Period.last7Days);
      case "last14Days":
        return DateRange(period: DateRange_Period.last14Days);
      case "last30Days":
        return DateRange(period: DateRange_Period.last30Days);
      case "last60Days":
        return DateRange(period: DateRange_Period.last60Days);
      case "last12Months":
        return DateRange(period: DateRange_Period.last12Months);
      case "custom":
        return DateRange(period: DateRange_Period.custom);
      default:
        _log.w("Unknown legacy ID: $displayDateRangeId");
        return DateRange(period: DateRange_Period.allDates);
    }
  }

  String get legacyDisplayDateRangeId {
    switch (period) {
      case DateRange_Period.allDates:
        return "allDates";
      case DateRange_Period.custom:
        return "custom";
      case DateRange_Period.last12Months:
        return "last12Months";
      case DateRange_Period.last14Days:
        return "last14Days";
      case DateRange_Period.last30Days:
        return "last30Days";
      case DateRange_Period.last60Days:
        return "last60Days";
      case DateRange_Period.last7Days:
        return "last7Days";
      case DateRange_Period.lastMonth:
        return "lastMonth";
      case DateRange_Period.lastWeek:
        return "lastWeek";
      case DateRange_Period.lastYear:
        return "lastYear";
      case DateRange_Period.thisMonth:
        return "thisMonth";
      case DateRange_Period.thisWeek:
        return "thisWeek";
      case DateRange_Period.thisYear:
        return "thisYear";
      case DateRange_Period.today:
        return "today";
      case DateRange_Period.yesterday:
        return "yesterday";
      default:
        _log.w("Unknown DateRange_Period: $period");
        return "allDates";
    }
  }
}
