import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:quiver/strings.dart';

extension DateRanges on DateRange {
  static DateRange get _default => DateRange(period: DateRange_Period.allDates);

  // TODO: Remove when there are no more 1.x users.
  static DateRange fromPreference(String? pref) {
    return DateRanges._fromLegacyDisplayDateRangeId(pref) ??
        (isEmpty(pref) ? _default : _safeFromJson(pref!));
  }

  static DateRange _safeFromJson(String json) {
    try {
      return DateRange.fromJson(json);
    } catch (ex) {
      return _default;
    }
  }

  static DateRange? _fromLegacyDisplayDateRangeId(String? displayDateRangeId) {
    if (isEmpty(displayDateRangeId)) {
      return null;
    }

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
      default:
        return null;
    }
  }
}
