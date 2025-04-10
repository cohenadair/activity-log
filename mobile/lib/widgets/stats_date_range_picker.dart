import 'dart:async';

import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/list_picker.dart';
import 'package:timezone/timezone.dart';

/// A [ListPicker] wrapper widget for selecting a date range, such as the
/// "Last 7 days" or "This week" from a list.
class StatsDateRangePicker extends StatefulWidget {
  final DisplayDateRange initialValue;
  final OnListPickerChanged<DisplayDateRange> onDurationPicked;

  const StatsDateRangePicker({
    required this.initialValue,
    required this.onDurationPicked,
  });

  @override
  StatsDateRangePickerState createState() => StatsDateRangePickerState();
}

class StatsDateRangePickerState extends State<StatsDateRangePicker> {
  DisplayDateRange _customDateRange = DisplayDateRange.custom;

  @override
  Widget build(BuildContext context) {
    return ListPicker<DisplayDateRange>(
      initialValues: {widget.initialValue},
      onChanged: (Set<DisplayDateRange> pickedDurations) {
        widget.onDurationPicked(pickedDurations.first);

        if (pickedDurations.first != _customDateRange) {
          // If anything other than the custom option is picked, reset the
          // custom text back to the default.
          setState(() {
            _customDateRange = DisplayDateRange.custom;
          });
        }
      },
      allItem: _buildItem(context, DisplayDateRange.allDates),
      items: [
        ListPickerItem.divider(),
        _buildItem(context, DisplayDateRange.today),
        _buildItem(context, DisplayDateRange.yesterday),
        ListPickerItem.divider(),
        _buildItem(context, DisplayDateRange.thisWeek),
        _buildItem(context, DisplayDateRange.thisMonth),
        _buildItem(context, DisplayDateRange.thisYear),
        ListPickerItem.divider(),
        _buildItem(context, DisplayDateRange.lastWeek),
        _buildItem(context, DisplayDateRange.lastMonth),
        _buildItem(context, DisplayDateRange.lastYear),
        ListPickerItem.divider(),
        _buildItem(context, DisplayDateRange.last7Days),
        _buildItem(context, DisplayDateRange.last14Days),
        _buildItem(context, DisplayDateRange.last30Days),
        _buildItem(context, DisplayDateRange.last60Days),
        _buildItem(context, DisplayDateRange.last12Months),
        ListPickerItem.divider(),
        ListPickerItem<DisplayDateRange>(
          popsListOnPicked: false,
          title: _customDateRange.onTitle(context),
          onTap: () => _onTapCustom(context),
          value: _customDateRange,
        ),
      ],
    );
  }

  ListPickerItem<DisplayDateRange> _buildItem(
    BuildContext context,
    DisplayDateRange duration,
  ) {
    return ListPickerItem<DisplayDateRange>(
      title: duration.onTitle(context),
      value: duration,
    );
  }

  Future<DisplayDateRange?> _onTapCustom(BuildContext context) async {
    var now = TimeManager.get.now();
    DateRange customValue = _customDateRange.onValue(now);

    var pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: customValue.startDate,
        end: customValue.endDate,
      ),
      firstDate: TimeManager.get.dateTime(0),
      lastDate: now,
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
      startDate: TimeManager.get.dateTimeToTz(pickedRange.start),
      endDate: TimeManager.get.dateTimeToTz(endDate ?? pickedRange.end),
    );

    // Reset StatsDateRange.custom properties to return the picked DateRange.
    setState(() => _customDateRange = DisplayDateRange.dateRange(dateRange));

    return _customDateRange;
  }
}
