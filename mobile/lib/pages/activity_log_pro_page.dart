import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:adair_flutter_lib/widgets/safe_future_builder.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/l10n_extension.dart';
import 'package:mobile/live_activities_manager.dart';

class ActivityLogProPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeFutureBuilder<String?>(
      future: _buildSubtext(),
      errorReason: "Fetching live activities subtext",
      builder: (context, subtext) => ProPage(
        features: [
          ProPageFeatureRow(L10n.get.app.proPageWakeLock),
          ProPageFeatureRow(
            IoWrapper.get.isAndroid
                ? L10n.get.app.proPageLiveActivitiesAndroid
                : L10n.get.app.proPageLiveActivitiesApple,
            subtext: subtext,
          ),
        ],
      ),
    );
  }

  Future<String?> _buildSubtext() async {
    if (!await LiveActivitiesManager.get.isSupported) {
      return IoWrapper.get.isAndroid
          ? L10n.get.app.proPageLiveActivitiesAndroidUnsupported
          : L10n.get.app.proPageLiveActivitiesAppleUnsupported;
    }
    return null;
  }
}
