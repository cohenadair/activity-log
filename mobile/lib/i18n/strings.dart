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

  /// Should only be used in utility widgets or methods for common strings.
  /// See [ActionButton] for an example.
  String fromId(String id) => _getString(id);

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
  String get done => _getString("done");
  String get save => _getString("save");
  String get delete => _getString("delete");
  String get today => _getString("today");
  String get yesterday => _getString("yesterday");
  String get none => _getString("none");

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

  String get settingsPageTitle => _getString("settingsPage_title");
  String get settingsPageVersion => _getString("settingsPage_version");
  String get settingsPageHeadingAbout => _getString("settingsPage_headingAbout");

  String get statsPageTitle => _getString("statsPage_title");
  String get statsPageNoDataMessage => _getString("statsPage_noDataMessage");
  String get statsPageDurationTitle => _getString("statsPage_durationTitle");
  String get statsPageNumberOfSessionsTitle => _getString("statsPage_numberOfSessionsTitle");
  String get statsPageLongestSessionLabel => _getString("statsPage_longestSessionLabel");
  String get statsPageMostFrequentActivityLabel => _getString("statsPage_mostFrequentActivityLabel");
  String get statsPageMostFrequentActivityValue => _getString("statsPage_mostFrequentActivityValue");

  String get activitySummarySessionTitle => _getString("activitySummary_sessionTitle");
  String get activitySummaryNumberOfSessions => _getString("activitySummary_numberOfSessions");
  String get activitySummaryTotalDuration => _getString("activitySummary_totalDuration");
  String get activitySummaryAverageOverall => _getString("activitySummary_averageOverall");
  String get activitySummaryAveragePerDay => _getString("activitySummary_averagePerDay");
  String get activitySummaryAveragePerWeek => _getString("activitySummary_averagePerWeek");
  String get activitySummaryAveragePerMonth => _getString("activitySummary_averagePerMonth");
  String get activitySummaryShortestSession => _getString("activitySummary_shortestSession");
  String get activitySummaryLongestSession => _getString("activitySummary_longestSession");
  String get activitySummaryStreak => _getString("activitySummary_streak");
  String get activitySummaryStreakDescription => _getString("activitySummary_streakDescription");

  String get summaryDefaultTitle => _getString("summary_defaultTitle");

  String get activityDropdownAllActivities => _getString("activityDropdown_allActivities");

  String get analysisDurationAllDates => _getString("analysisDuration_allDates");
  String get analysisDurationToday => _getString("analysisDuration_today");
  String get analysisDurationYesterday => _getString("analysisDuration_yesterday");
  String get analysisDurationThisWeek => _getString("analysisDuration_thisWeek");
  String get analysisDurationThisMonth => _getString("analysisDuration_thisMonth");
  String get analysisDurationThisYear => _getString("analysisDuration_thisYear");
  String get analysisDurationLastWeek => _getString("analysisDuration_lastWeek");
  String get analysisDurationLastMonth => _getString("analysisDuration_lastMonth");
  String get analysisDurationLastYear => _getString("analysisDuration_lastYear");
  String get analysisDurationLast7Days => _getString("analysisDuration_last7Days");
  String get analysisDurationLast14Days => _getString("analysisDuration_last14Days");
  String get analysisDurationLast30Days => _getString("analysisDuration_last30Days");
  String get analysisDurationLast60Days => _getString("analysisDuration_last60Days");
  String get analysisDurationLast12Months => _getString("analysisDuration_last12Months");
  String get analysisDurationCustom => _getString("analysisDuration_custom");

  String get daysFormat => _getString("daysFormat");
  String get hoursFormat => _getString("hoursFormat");
  String get minutesFormat => _getString("minutesFormat");
  String get secondsFormat => _getString("secondsFormat");
  String get dateTimeFormat => _getString("dateTimeFormat");
  String get dateDurationFormat => _getString("dateDurationFormat");
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