import 'dart:async';

import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/list_picker.dart';
import 'package:timezone/timezone.dart';

/// A [ListPicker] wrapper widget for selecting a date range, such as the
/// "Last 7 days" or "This week" from a list.
class StatsDateRangePicker extends StatefulWidget {
  final DateRange initialValue;
  final OnListPickerChanged<DateRange> onDurationPicked;

  const StatsDateRangePicker({
    required this.initialValue,
    required this.onDurationPicked,
  });

  @override
  StatsDateRangePickerState createState() => StatsDateRangePickerState();
}

class StatsDateRangePickerState extends State<StatsDateRangePicker> {
  DateRange _customDateRange = DateRange(period: DateRange_Period.custom);

  @override
  Widget build(BuildContext context) {
    return ListPicker<DateRange>(
      initialValues: {widget.initialValue},
      onChanged: (Set<DateRange> pickedDurations) {
        widget.onDurationPicked(pickedDurations.first);

        if (pickedDurations.first != _customDateRange) {
          // If anything other than the custom option is picked, reset the
          // custom text back to the default.
          setState(() {
            _customDateRange = DateRange(period: DateRange_Period.custom);
          });
        }
      },
      allItem:
          _buildItem(context, DateRange(period: DateRange_Period.allDates)),
      items: [
        ListPickerItem.divider(),
        _buildItem(context, DateRange(period: DateRange_Period.today)),
        _buildItem(context, DateRange(period: DateRange_Period.yesterday)),
        ListPickerItem.divider(),
        _buildItem(context, DateRange(period: DateRange_Period.thisWeek)),
        _buildItem(context, DateRange(period: DateRange_Period.thisMonth)),
        _buildItem(context, DateRange(period: DateRange_Period.thisYear)),
        ListPickerItem.divider(),
        _buildItem(context, DateRange(period: DateRange_Period.lastWeek)),
        _buildItem(context, DateRange(period: DateRange_Period.lastMonth)),
        _buildItem(context, DateRange(period: DateRange_Period.lastYear)),
        ListPickerItem.divider(),
        _buildItem(context, DateRange(period: DateRange_Period.last7Days)),
        _buildItem(context, DateRange(period: DateRange_Period.last14Days)),
        _buildItem(context, DateRange(period: DateRange_Period.last30Days)),
        _buildItem(context, DateRange(period: DateRange_Period.last60Days)),
        _buildItem(context, DateRange(period: DateRange_Period.last12Months)),
        ListPickerItem.divider(),
        ListPickerItem<DateRange>(
          popsListOnPicked: false,
          title: _customDateRange.displayName,
          onTap: () => _onTapCustom(context),
          value: _customDateRange,
        ),
      ],
    );
  }

  ListPickerItem<DateRange> _buildItem(
    BuildContext context,
    DateRange duration,
  ) {
    return ListPickerItem<DateRange>(
      title: duration.displayName,
      value: duration,
    );
  }

  Future<DateRange?> _onTapCustom(BuildContext context) async {
    var pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _customDateRange.startDate,
        end: _customDateRange.endDate,
      ),
      firstDate: TimeManager.get.dateTime(0),
      lastDate: TimeManager.get.now(),
    );

    if (pickedRange == null) {
      return null;
    }

    TZDateTime? endDate;
    if (pickedRange.start == pickedRange.end) {
      // If only the start date was picked, or the start and end time are equal,
      // set the end date to a range of 1 day.
      endDate = TimeManager.get.dateTimeToTz(
        pickedRange.start.add(const Duration(days: 1)),
      );
    }

    var dateRange = DateRange(
      startTimestamp: Int64(TimeManager.get
          .dateTimeToTz(pickedRange.start)
          .millisecondsSinceEpoch),
      endTimestamp: Int64(TimeManager.get
          .dateTimeToTz(endDate ?? pickedRange.end)
          .millisecondsSinceEpoch),
    );

    // Reset StatsDateRange.custom properties to return the picked DateRange.
    setState(() => _customDateRange = dateRange.deepCopy());

    return _customDateRange;
  }
}
