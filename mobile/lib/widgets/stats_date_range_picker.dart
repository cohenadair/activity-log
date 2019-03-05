import 'dart:async';

import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
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
          popsListOnPicked: false,
          child: Text(StatsDateRange.custom.getTitle(context)),
          onTap: () => _onTapCustom(context),
          value: StatsDateRange.custom,
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

  Future<bool> _onTapCustom(BuildContext context) async {
    DateTime now = DateTime.now();
    DateRange customValue = StatsDateRange.custom.getValue(now);

    List<DateTime> pickedRange = await DateRangePicker.showDatePicker(
      context: context,
      initialFirstDate: customValue.startDate,
      initialLastDate: customValue.endDate,
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: now,
    );

    DateRange dateRange = DateRange(
      startDate: pickedRange.first,
      endDate: pickedRange.last,
    );

    // Reset StatsDateRange.custom properties to return the picked DateRange.
    StatsDateRange.custom.getValue = (DateTime dateTime) => dateRange;
    StatsDateRange.custom.getTitle =
        (BuildContext context) => formatDateRange(dateRange);

    onDurationPicked(StatsDateRange.custom);

    Navigator.pop(context);
    return true;
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
    return DateRange(
      startDate: now.subtract(Duration(days: 7)),
      endDate: now,
    );
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast7Days;
  });

  static final last14Days = StatsDateRange._((DateTime now) {
    return DateRange(
      startDate: now.subtract(Duration(days: 14)),
      endDate: now,
    );
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast14Days;
  });

  static final last30Days = StatsDateRange._((DateTime now) {
    return DateRange(
      startDate: now.subtract(Duration(days: 30)),
      endDate: now,
    );
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast30Days;
  });

  static final last60Days = StatsDateRange._((DateTime now) {
    return DateRange(
      startDate: now.subtract(Duration(days: 60)),
      endDate: now,
    );
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast60Days;
  });

  static final last12Months = StatsDateRange._((DateTime now) {
    return DateRange(
      startDate: now.subtract(Duration(days: 365)),
      endDate: now,
    );
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationLast12Months;
  });

  /// Used for a custom picker row. Defaults to "this month". We use a static
  /// instance in order for `==` to work correctly. Overriding `==` isn't
  /// easy for classes whose properties are functions.
  static final custom = StatsDateRange._((DateTime now) {
    return thisMonth.getValue(now);
  }, (BuildContext context) {
    return Strings.of(context).analysisDurationCustom;
  });

  DateRange Function(DateTime now) getValue;
  String Function(BuildContext context) getTitle;

  StatsDateRange._(this.getValue, this.getTitle);

  DateRange get value => getValue(DateTime.now());
}