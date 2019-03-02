import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/widgets/activity_picker.dart';
import 'package:mobile/widgets/stats_date_range_picker.dart';
import 'package:mobile/widgets/page.dart';

class StatsPage extends StatefulWidget {
  final AppManager app;

  StatsPage(this.app);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Activity _currentActivity;
  StatsDateRange _currentDuration;

  @override
  void initState() {
    super.initState();
    _currentActivity = null;
    _currentDuration = StatsDateRange.allDates;
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).statsPageTitle,
      ),
      child: ListView(
        children: <Widget>[
          ActivityPicker(
            app: widget.app,
            initialActivity: null,
            onActivityPicked: (Activity activity) {
              _currentActivity = activity;
            },
          ),
          StatsDateRangePicker(
            initialValue: _currentDuration,
            onDurationPicked: (StatsDateRange pickedDuration) {
              _currentDuration = pickedDuration;
            },
          )
        ],
      ),
    );
  }
}