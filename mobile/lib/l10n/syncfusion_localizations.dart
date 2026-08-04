import 'package:adair_flutter_lib/l10n/sf_localizations_en_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/localizations.dart';

/// Overrides the default English resource values used by Syncfusion widgets
/// (currently only [noEventsCalendarLabel], for [StatsCalendar]'s empty
/// agenda state). Activity Log is English-only, so unlike Anglers' Log this
/// doesn't need a per-locale delegate.
class SyncfusionLocalizationsDelegate
    extends LocalizationsDelegate<SfLocalizations> {
  const SyncfusionLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == "en";

  @override
  Future<SfLocalizations> load(Locale locale) =>
      SynchronousFuture<SfLocalizations>(const _SfLocalizationsEnOverride());

  @override
  bool shouldReload(LocalizationsDelegate<SfLocalizations> old) => false;
}

class _SfLocalizationsEnOverride extends SfLocalizationsEnBase {
  const _SfLocalizationsEnOverride();

  @override
  String get noEventsCalendarLabel => "No activity sessions";
}
