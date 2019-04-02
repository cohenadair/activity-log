import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker.dart';
import 'package:mobile/widgets/loading.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:package_info/package_info.dart';

class SettingsPage extends StatefulWidget {
  final AppManager app;

  SettingsPage(this.app);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).settingsPageTitle,
      ),
      child: ListView(
        children: <Widget>[
          _buildHeading(Strings.of(context).settingsPageHeadingOther),
          _buildLargestDurationPicker(),
          _buildHomeDateRangePicker(),
          MinDivider(),
          _buildHeading(Strings.of(context).settingsPageHeadingAbout),
          ListItem(
            title: Text(Strings.of(context).settingsPageVersion),
            trailing: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
                if (snapshot.hasData) {
                  return SecondaryText(snapshot.data.version);
                } else {
                  return Loading();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: paddingDefault,
        left: paddingDefault,
        right: paddingDefault,
      ),
      child: SafeArea(
        child: HeadingText(title),
      ),
    );
  }

  Widget _buildLargestDurationPicker() {
    return LargestDurationBuilder(
      app: widget.app,
      builder: (BuildContext context, DurationUnit durationUnit) {
        return ListPicker<DurationUnit>(
          pageTitle: Strings.of(context).settingsPageLargestDurationLabel,
          initialValues: Set.of([durationUnit]),
          showsValueOnTrailing: true,
          onChanged: (selectedValues) {
            widget.app.preferencesManager
                .setLargestDurationUnit(selectedValues.first);
          },
          titleBuilder: (_) =>
              Text(Strings.of(context).settingsPageLargestDurationLabel),
          items: [
            ListPickerItem<DurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationDays,
              subtitle: _getLargestDurationUnitSubtitle(DurationUnit.days),
              value: DurationUnit.days,
            ),
            ListPickerItem<DurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationHours,
              subtitle: _getLargestDurationUnitSubtitle(DurationUnit.hours),
              value: DurationUnit.hours,
            ),
            ListPickerItem<DurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationMinutes,
              subtitle: _getLargestDurationUnitSubtitle(DurationUnit.minutes),
              value: DurationUnit.minutes,
            ),
          ],
        );
      }
    );
  }

  String _getLargestDurationUnitSubtitle(DurationUnit unit) {
    return formatTotalDuration(
      largestDurationUnit: unit,
      context: context, durations: [
        Duration(days: 3, hours: 15, minutes: 30, seconds: 55),
      ],
    );
  }

  Widget _buildHomeDateRangePicker() {
    return HomeDateRangeBuilder(
      app: widget.app,
      builder: (BuildContext context, DisplayDateRange dateRange) {
        return ListPicker<DisplayDateRange>(
          pageTitle: Strings.of(context).settingsPageHomeDateRangeLabel,
          initialValues: Set.of([dateRange]),
          showsValueOnTrailing: true,
          onChanged: (selectedValues) {
            widget.app.preferencesManager
                .setHomeDateRange(selectedValues.first);
          },
          titleBuilder: (_) => Text(Strings.of(context)
              .settingsPageHomeDateRangeLabel),
          listHeader: Text(Strings.of(context)
              .settingsPageHomeDateRangeDescription),
          items: [
            _buildDisplayDateRangeItem(DisplayDateRange.allDates),
            ListPickerItem.divider(),
            _buildDisplayDateRangeItem(DisplayDateRange.today),
            ListPickerItem.divider(),
            _buildDisplayDateRangeItem(DisplayDateRange.thisWeek),
            _buildDisplayDateRangeItem(DisplayDateRange.thisMonth),
            _buildDisplayDateRangeItem(DisplayDateRange.thisYear),
            ListPickerItem.divider(),
            _buildDisplayDateRangeItem(DisplayDateRange.last7Days),
            _buildDisplayDateRangeItem(DisplayDateRange.last30Days),
            _buildDisplayDateRangeItem(DisplayDateRange.last12Months),
          ],
        );
      }
    );
  }

  ListPickerItem<DisplayDateRange> _buildDisplayDateRangeItem(
      DisplayDateRange dateRange)
  {
    return ListPickerItem<DisplayDateRange>(
      title: dateRange.getTitle(context),
      value: dateRange,
    );
  }
}