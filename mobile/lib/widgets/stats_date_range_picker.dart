import 'dart:async';

import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_picker.dart';

/// A [ListPicker] wrapper widget for selecting a date range, such as the
/// "Last 7 days" or "This week" from a list.
class StatsDateRangePicker extends StatefulWidget {
  final StatsDateRange initialValue;
  final OnListPickerChanged<StatsDateRange> onDurationPicked;

  StatsDateRangePicker({
    @required this.initialValue,
    @required this.onDurationPicked
  }) : assert(initialValue != null),
       assert(onDurationPicked != null);

  @override
  _StatsDateRangePickerState createState() => _StatsDateRangePickerState();
}

class _StatsDateRangePickerState extends State<StatsDateRangePicker> {
  StatsDateRange _customDateRange = StatsDateRange.custom;

  @override
  Widget build(BuildContext context) {
    return ListPicker<StatsDateRange>(
      initialValues: Set.of([widget.initialValue]),
      onChanged: (Set<StatsDateRange> pickedDurations) {
        widget.onDurationPicked(pickedDurations.first);

        if (pickedDurations.first != _customDateRange) {
          // If anything other than the custom option is picked, reset the
          // custom text back to the default.
          setState(() {
            _customDateRange = StatsDateRange.custom;
          });
        }
      },
      allItem: _buildItem(context, StatsDateRange.allDates),
      items: [
        ListPickerItem.divider(),
        _buildItem(context, StatsDateRange.today),
        _buildItem(context, StatsDateRange.yesterday),
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
          title: _customDateRange.getTitle(context),
          onTap: () => _onTapCustom(context),
          value: _customDateRange,
        ),
      ],
    );
  }

  ListPickerItem<StatsDateRange> _buildItem(BuildContext context,
      StatsDateRange duration)
  {
    return ListPickerItem<StatsDateRange>(
      title: duration.getTitle(context),
      value: duration,
    );
  }

  Future<StatsDateRange> _onTapCustom(BuildContext context) async {
    DateTime now = DateTime.now();
    DateRange customValue = _customDateRange.getValue(now);

    List<DateTime> pickedRange = await DateRangePicker.showDatePicker(
      context: context,
      initialFirstDate: customValue.startDate,
      initialLastDate: customValue.endDate,
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: now,
    );

    DateTime endDate;
    if (pickedRange.first == pickedRange.last) {
      // If only the start date was picked, or the start and end time are equal,
      // set the end date to a range of 1 day.
      endDate = pickedRange.first.add(Duration(days: 1));
    }

    DateRange dateRange = DateRange(
      startDate: pickedRange.first,
      endDate: endDate ?? pickedRange.last,
    );

    // Reset StatsDateRange.custom properties to return the picked DateRange.
    setState(() {
      _customDateRange = StatsDateRange(
        id: StatsDateRange.custom.id,
        getValue: (_) => dateRange,
        getTitle: (_) => formatDateRange(dateRange),
      );
    });

    return _customDateRange;
  }
}

@immutable
class StatsDateRange {
  static final allDates = StatsDateRange(
    id: "allDates",
    getValue: (DateTime now) => DateRange(
      startDate: DateTime.fromMicrosecondsSinceEpoch(0),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationAllDates,
  );

  static final today = StatsDateRange(
    id: "today",
    getValue: (DateTime now) => DateRange(
      startDate: dateTimeToDayAccuracy(now),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationToday,
  );

  static final yesterday = StatsDateRange(
    id: "yesterday",
    getValue: (DateTime now) => DateRange(
      startDate: dateTimeToDayAccuracy(now).subtract(Duration(days: 1)),
      endDate: dateTimeToDayAccuracy(now),
    ),
    getTitle: (context) => Strings.of(context).analysisDurationYesterday,
  );

  static final thisWeek = StatsDateRange(
    id: "thisWeek",
    getValue: (DateTime now) => DateRange(
      startDate: getStartOfWeek(now),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationThisWeek,
  );

  static final thisMonth = StatsDateRange(
    id: "thisMonth",
    getValue: (DateTime now) => DateRange(
      startDate: getStartOfMonth(now),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationThisMonth,
  );

  static final thisYear = StatsDateRange(
    id: "thisYear",
    getValue: (DateTime now) => DateRange(
      startDate: getStartOfYear(now),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationThisYear,
  );

  static final lastWeek = StatsDateRange(
    id: "lastWeek",
    getValue: (DateTime now) {
      DateTime endOfLastWeek = getStartOfWeek(now);
      DateTime startOfLastWeek = endOfLastWeek.subtract(Duration(
          days: DateTime.daysPerWeek),
      );
      return DateRange(startDate: startOfLastWeek, endDate: endOfLastWeek);
    },
    getTitle: (context) => Strings.of(context).analysisDurationLastWeek,
  );

  static final lastMonth = StatsDateRange(
    id: "lastMonth",
    getValue: (DateTime now) {
      DateTime endOfLastMonth = getStartOfMonth(now);
      int year = now.year;
      int month = now.month - 1;
      if (month < DateTime.january) {
        month = DateTime.december;
        year -= 1;
      }
      return DateRange(
        startDate: DateTime(year, month),
        endDate: endOfLastMonth,
      );
    },
    getTitle: (context) => Strings.of(context).analysisDurationLastMonth,
  );

  static final lastYear = StatsDateRange(
    id: "lastYear",
    getValue: (DateTime now) => DateRange(
      startDate: DateTime(now.year - 1),
      endDate: getStartOfYear(now),
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLastYear,
  );

  static final last7Days = StatsDateRange(
    id: "last7Days",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 7)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast7Days,
  );

  static final last14Days = StatsDateRange(
    id: "last14Days",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 14)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast14Days,
  );

  static final last30Days = StatsDateRange(
    id: "last30Days",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 30)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast30Days,
  );

  static final last60Days = StatsDateRange(
    id: "last60Days",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 60)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast60Days,
  );

  static final last12Months = StatsDateRange(
    id: "last12Months",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 365)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast12Months,
  );

  static final custom = StatsDateRange(
    id: "custom",
    getValue: (now) => StatsDateRange.thisMonth.getValue(now),
    getTitle: (context) => Strings.of(context).analysisDurationCustom,
  );

  final String id;
  final DateRange Function(DateTime now) getValue;
  final String Function(BuildContext context) getTitle;

  StatsDateRange({
    this.id, this.getValue, this.getTitle
  });

  DateRange get value => getValue(DateTime.now());

  @override
  bool operator ==(other) {
    return other is StatsDateRange && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}