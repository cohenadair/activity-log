import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/pages/fullscreen_activity_page.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/widgets/future_timer.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../utils/duration.dart';

class ActivityListTileModel {
  final Activity activity;
  Session? currentSession;
  Duration? duration;

  ActivityListTileModel(this.activity);
}

class ActivityListTile extends StatelessWidget {
  final ActivityListTileModel model;
  final Function(Activity) onTap;
  final Function() onTapStartSession;
  final Function() onTapEndSession;

  const ActivityListTile({
    required this.model,
    required this.onTap,
    required this.onTapStartSession,
    required this.onTapEndSession,
  });

  @override
  Widget build(BuildContext context) {
    return LargestDurationBuilder(
      builder: (BuildContext context, AppDurationUnit largestDurationUnit) {
        return ListItem(
          contentPadding: const EdgeInsets.only(
            right: paddingTiny,
            left: paddingDefault,
          ),
          title: Text(model.activity.name),
          subtitle: TotalDurationText(
            model.duration == null ? [] : [model.duration!],
            largestDurationUnit: toLibDurationUnit(largestDurationUnit),
          ),
          onTap: () => onTap.call(model.activity),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildRunningDuration(model.currentSession),
              model.activity.isRunning
                  ? _buildStopButton()
                  : _buildStartButton(),
              _buildExpandButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartButton() {
    return _buildButton(Icons.play_arrow, Colors.green, insetsRightTiny, () {
      onTapStartSession.call();
    });
  }

  Widget _buildStopButton() {
    return _buildButton(Icons.stop, Colors.red, insetsRightTiny, () {
      onTapEndSession.call();
    });
  }

  Widget _buildExpandButton(BuildContext context) {
    return _buildButton(
      Icons.fullscreen,
      AppConfig.get.colorAppTheme,
      insetsZero,
      () => present(context, FullscreenActivityPage(model.activity.id)),
    );
  }

  Widget _buildButton(
    IconData icon,
    Color color,
    EdgeInsets padding,
    VoidCallback onPressed,
  ) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildRunningDuration(Session? session) {
    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingMedium,
      ),
      child: Timer(
        shouldUpdateCallback: () => model.activity.isRunning,
        childBuilder: () {
          bool visible = session != null;
          return FadeIn<Duration>(
            visible: visible,
            value: visible ? session.duration : const Duration(),
            childBuilder: (Duration value) => RunningDurationText(value),
          );
        },
      ),
    );
  }
}
