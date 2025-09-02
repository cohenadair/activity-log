import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/widgets/pro_chip_button.dart';
import 'package:flutter/material.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';
import 'package:mobile/widgets/future_listener.dart';
import 'package:mobile/widgets/my_page.dart';
import 'package:mobile/wrappers/wakelock_wrapper.dart';

import '../model/session.dart';
import '../widgets/future_timer.dart';
import '../widgets/text.dart';

class FullscreenActivityPage extends StatefulWidget {
  final String activityId;

  const FullscreenActivityPage(this.activityId);

  @override
  State<FullscreenActivityPage> createState() => _FullscreenActivityPageState();
}

class _FullscreenActivityPageState extends State<FullscreenActivityPage> {
  static const _titleSize = 48.0;
  static const _playPauseButtonSize = 120.0;

  String get _activityId => widget.activityId;

  @override
  void dispose() {
    super.dispose();
    WakelockWrapper.get.disable();
  }

  @override
  Widget build(BuildContext context) {
    return MyPage(
      child: OrientationBuilder(
        builder: (context, orientation) => FutureListener(
          streams: [DataManager.get.activitiesUpdatedStream],
          futuresCallbacks: [
            () => DataManager.get.activity(_activityId),
            () => DataManager.get.inProgressSession(_activityId),
          ],
          builder: (context, values) {
            var activity = values?[0];
            var session = values?[1];

            _handleWakelock(session != null);

            return Stack(
              children: [
                Align(alignment: Alignment.topLeft, child: CloseButton()),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: insetsHorizontalDefault,
                    child: ProChipButton(ActivityLogProPage()),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(activity),
                      _buildSessionContainer(activity, session, orientation),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(Activity activity) {
    return Padding(
      padding: insetsBottomDefault,
      child: Text(
        activity.name,
        style: const TextStyle(fontSize: _titleSize, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSessionContainer(
    Activity activity,
    Session? session,
    Orientation orientation,
  ) {
    return Flex(
      direction: orientation == Orientation.landscape
          ? Axis.horizontal
          : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimer(activity, session),
        _buildPlayPauseButton(activity),
      ],
    );
  }

  Widget _buildTimer(Activity activity, Session? session) {
    return Timer(
      shouldUpdateCallback: () => activity.isRunning,
      childBuilder: () => Container(
        width: double.infinity,
        padding: insetsHorizontalDefault,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.shortestSide,
        ),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: RunningDurationText(session?.duration ?? Duration()),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(Activity activity) {
    var isRunning = activity.isRunning;

    return IconButton(
      iconSize: _playPauseButtonSize,
      icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
      color: isRunning ? Colors.red : Colors.green,
      onPressed: () =>
          (isRunning
                  ? DataManager.get.endSession(activity)
                  : DataManager.get.startSession(activity))
              .then((_) => setState(() {})),
    );
  }

  void _handleWakelock(bool isEnabled) {
    if (SubscriptionManager.get.isFree) {
      return;
    }

    if (isEnabled) {
      WakelockWrapper.get.enable();
    } else {
      WakelockWrapper.get.disable();
    }
  }
}
