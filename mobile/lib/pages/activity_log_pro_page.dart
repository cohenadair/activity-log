import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:adair_flutter_lib/utils/device.dart';
import 'package:adair_flutter_lib/widgets/safe_future_builder.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/l10n_extension.dart';
import 'package:mobile/live_activities_manager.dart';

class ActivityLogProPage extends StatefulWidget {
  @override
  State<ActivityLogProPage> createState() => _ActivityLogProPageState();
}

class _ActivityLogProPageState extends State<ActivityLogProPage> {
  late final Future<(String, String?)> _textFutures;

  @override
  void initState() {
    super.initState();

    _textFutures = (
      _buildAppleLiveActivitiesText(),
      _buildLiveActivitiesSubtext(),
    ).wait;
  }

  @override
  Widget build(BuildContext context) {
    return SafeFutureBuilder<(String, String?)>(
      future: _textFutures,
      errorReason: "Fetching live activities subtext",
      builder: (context, texts) => ProPage(
        features: [
          ProPageFeatureRow(L10n.get.app.proPageWakeLock),
          ProPageFeatureRow(
            IoWrapper.get.isAndroid
                ? L10n.get.app.proPageLiveActivitiesAndroid
                : texts?.$1 ?? "",
            subtext: texts?.$2,
          ),
        ],
      ),
    );
  }

  Future<String> _buildAppleLiveActivitiesText() async {
    return await hasDynamicIsland()
        ? L10n.get.app.proPageLiveActivitiesAppleDynamicIsland
        : L10n.get.app.proPageLiveActivitiesApple;
  }

  Future<String?> _buildLiveActivitiesSubtext() async {
    if (!await LiveActivitiesManager.get.isSupported()) {
      return IoWrapper.get.isAndroid
          ? L10n.get.app.proPageLiveActivitiesAndroidUnsupported
          : L10n.get.app.proPageLiveActivitiesAppleUnsupported;
    }
    return null;
  }
}
