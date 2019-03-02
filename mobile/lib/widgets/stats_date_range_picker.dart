import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/list_picker.dart';

/// A [ListPicker] wrapper widget for selecting a date range, such as the
/// "Last 7 days" or "This week" from a list.
class StatsDateRangePicker extends StatelessWidget {
  final StatsDateRange initialValue;
  final OnListPickerChanged<StatsDateRange> onDurationPicked;

  StatsDateRangePicker({
    @required this.initialValue,
    @required this.onDurationPicked
  });

  @override
  Widget build(BuildContext context) {
    return ListPicker<StatsDateRange>(
      initialValue: initialValue,
      onChanged: onDurationPicked,
      options: [
        _buildItem(context, StatsDateRange.allDates),
        ListPickerItem.divider(),
        _buildItem(context, StatsDateRange.thisWeek),
        _buildItem(context, StatsDateRange.thisMonth),
        _buildItem(context, StatsDateRange.thisYear),
        ListPickerItem.divider(),
        _buildItem(context, StatsDateRange.lastWeek),
        _buildItem(context, StatsDateRange.lastMonth),
        _buildItem(context, StatsDateRange.lastYear),
        ListPickerItem.divider(),
        _buildItem(context, StatsDateRange.last7Days),
        _buildItem(context, StatsDateRange.last14Days),
        _buildItem(context, StatsDateRange.last30Days),
        _buildItem(context, StatsDateRange.last60Days),
        _buildItem(context, StatsDateRange.last12Months),
        ListPickerItem.divider(),
        ListPickerItem<StatsDateRange>(
          child: Text(Strings.of(context).analysisDurationCustom),
          onTap: () {
          },
        ),
      ],
    );
  }

  ListPickerItem<StatsDateRange> _buildItem(BuildContext context,
      StatsDateRange duration)
  {
    return ListPickerItem<StatsDateRange>(
      child: Text(duration.getTitle(context)),
      value: duration,
    );
  }
}

class StatsDateRange {
  static final allDates = StatsDateRange._((DateTime now) {
    return DateRange(
      startDate: DateTime.fromMicrosecondsSinceEpoch(0),
      endDate: now,
    );
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationAllDates;
  });

  static final thisWeek = StatsDateRange._((DateTime now) {
    return DateRange(startDate: getStartOfWeek(now), endDate: now);
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationThisWeek;
  });

  static final thisMonth = StatsDateRange._((DateTime now) {
    return DateRange(startDate: getStartOfMonth(now), endDate: now);
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationThisMonth;
  });

  static final thisYear = StatsDateRange._((DateTime now) {
    return DateRange(startDate: getStartOfYear(now), endDate: now);
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationThisYear;
  });

  static final lastWeek = StatsDateRange._((DateTime now) {
    DateTime endOfLastWeek = getStartOfWeek(now);
    DateTime startOfLastWeek = endOfLastWeek.subtract(Duration(
      days: DateTime.daysPerWeek),
    );
    return DateRange(startDate: startOfLastWeek, endDate: endOfLastWeek);
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLastWeek;
  });

  static final lastMonth = StatsDateRange._((DateTime now) {
    DateTime endOfLastMonth = getStartOfMonth(now);
    int year = now.year;
    int month = now.month - 1;
    if (month < DateTime.january) {
      month = DateTime.december;
      year -= 1;
    }
    return DateRange(startDate: DateTime(year, month), endDate: endOfLastMonth);
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLastMonth;
  });

  static final lastYear = StatsDateRange._((DateTime now) {
    DateTime endOfLastYear = getStartOfYear(now);
    return DateRange(startDate: DateTime(now.year - 1), endDate: endOfLastYear);
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLastYear;
  });

  static final last7Days = StatsDateRange._((DateTime now) {
    return DateRange(startDate: DateTime.now(), endDate: DateTime.now());
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast7Days;
  });

  static final last14Days = StatsDateRange._((DateTime now) {
    return DateRange(startDate: DateTime.now(), endDate: DateTime.now());
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast14Days;
  });

  static final last30Days = StatsDateRange._((DateTime now) {
    return DateRange(startDate: DateTime.now(), endDate: DateTime.now());
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast30Days;
  });

  static final last60Days = StatsDateRange._((DateTime now) {
    return DateRange(startDate: DateTime.now(), endDate: DateTime.now());
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast60Days;
  });

  static final last12Months = StatsDateRange._((DateTime now) {
    return DateRange(startDate: DateTime.now(), endDate: DateTime.now());
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast12Months;
  });

  final DateRange Function(DateTime now) getValue;
  final String Function(BuildContext context) getTitle;

  StatsDateRange._(this.getValue, this.getTitle);
}