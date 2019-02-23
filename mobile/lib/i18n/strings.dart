import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/english_strings.dart';

class Strings {
  static const List<String> _supportedLanguages = ["en"];

  static Map<String, Map<String, Map<String, String>>> _values = {
    "en" : englishStrings,
  };

  static Strings of(BuildContext context) =>
      Localizations.of<Strings>(context, Strings);

  final Locale _locale;

  Strings(this._locale);

  /// If a specific string for a language and country exists, use it, otherwise
  /// use the default.
  String _getString(String key) {
    String value = _values[_locale.languageCode][_locale.countryCode][key];
    if (value == null) {
      return _values[_locale.languageCode]["default"][key];
    }
    return value;
  }

  String get appName => _getString("appName");

  String get cancel => _getString("cancel");
  String get delete => _getString("delete");
  String get today => _getString("today");
  String get yesterday => _getString("yesterday");

  String get navigationBarHome => _getString("navigationBar_home");
  String get navigationBarStats => _getString("navigationBar_stats");
  String get navigationBarSettings => _getString("navigationBar_settings");

  String get activitiesPageTitle => _getString("activitiesPage_title");

  String get editActivityPageNewTitle => _getString("editActivityPage_newTitle");
  String get editActivityPageEditTitle => _getString("editActivityPage_editTitle");
  String get editActivityPageNameLabel => _getString("editActivityPage_nameLabel");
  String get editActivityPageDeleteMessage => _getString("editActivityPage_deleteMessage");
  String get editActivityPageNameExists => _getString("editActivityPage_nameExists");
  String get editActivityPageMissingName => _getString("editActivityPage_missingName");
  String get editActivityPageRecentSessions => _getString("editActivityPage_recentSessions");
  String get editActivityPageMoreSessions => _getString("editActivityPage_moreSessions");

  String get editSessionPageNewTitle => _getString("editSessionPage_newTitle");
  String get editSessionPageEditTitle => _getString("editSessionPage_editTitle");
  String get editSessionPageStartDate => _getString("editSessionPage_startDate");
  String get editSessionPageStartTime => _getString("editSessionPage_startTime");
  String get editSessionPageEndDate => _getString("editSessionPage_endDate");
  String get editSessionPageEndTime => _getString("editSessionPage_endTime");
  String get editSessionPageInvalidStartDate => _getString("editSessionPage_invalidStartDate");
  String get editSessionPageInvalidStartTime => _getString("editSessionPage_invalidStartTime");
  String get editSessionPageInvalidEndTime => _getString("editSessionPage_invalidEndTime");
  String get editSessionPageFutureStartTime => _getString("editSessionPage_futureStartTime");
  String get editSessionPageFutureEndTime => _getString("editSessionPage_futureEndTime");
  String get editSessionPageInProgress => _getString("editSessionPage_inProgress");

  String get editSessionPageOverlap => _getString("editSessionPage_overlap");

  String get sessionListDeleteMessage => _getString("sessionList_deleteMessage");
  String get sessionListInProgress => _getString("sessionList_inProgress");
  String get sessionListTitleFormat => _getString("sessionList_titleFormat");

  String get settingsPageTitle => _getString("settingsPage_title");
  String get settingsPageVersion => _getString("settingsPage_version");
  String get settingsPageHeadingAbout => _getString("settingsPage_headingAbout");

  String get daysFormat => _getString("daysFormat");
  String get hoursFormat => _getString("hoursFormat");
  String get minutesFormat => _getString("minutesFormat");
  String get secondsFormat => _getString("secondsFormat");
}

class StringsDelegate extends LocalizationsDelegate<Strings> {
  @override
  bool isSupported(Locale locale) =>
      Strings._supportedLanguages.contains(locale.languageCode);

  @override
  Future<Strings> load(Locale locale) =>
      SynchronousFuture<Strings>(Strings(locale));

  @override
  bool shouldReload(LocalizationsDelegate<Strings> old) => false;
}