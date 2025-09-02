import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/l10n_extension.dart';

class ActivityLogProPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProPage(features: [ProPageFeatureRow(L10n.get.app.proPageWakeLock)]);
  }
}
