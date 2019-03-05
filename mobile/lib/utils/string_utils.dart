import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/text.dart';

/// A trimmed, case-insensitive string comparison.
bool isEqualTrimmedLowercase(String s1, String s2) {
  return s1.trim().toLowerCase() == s2.trim().toLowerCase();
}

/// Supported formats:
///   - %s
/// For each argument, toString() is called to replace %s.
String format(String s, List<dynamic> args) {
  int index = 0;
  return s.replaceAllMapped(RegExp(r'%s'), (Match match) {
    return args[index++].toString();
  });
}

/// Returns a formatted [String] for a time of day. The format depends on a
/// combination of the current locale and the user's system time format setting.
///
/// Example:
///   21:35, or
///   9:35 PM
String formatTimeOfDay(BuildContext context, TimeOfDay time) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    time,
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat
  );
}

/// Returns a formatted [DateRange] to be displayed to the user.
///
/// Example:
///   Dec. 8, 2018 - Dec. 29, 2018
String formatDateRange(DateRange dateRange) {
  return DateFormat(monthDayYearFormat).format(dateRange.startDate)
      + " - "
      + DateFormat(monthDayYearFormat).format(dateRange.endDate);
}

/// Returns formatted text to display the total duration of list of [Duration]
/// objects, in the format Dd Hh Mm Ss.
///
/// Example:
///   - 0d 5h 30m 0s
String formatTotalDuration({
  BuildContext context,
  List<Duration> durations,
  bool includesDays = true,
  bool includesHours = true,
  bool includesMinutes = true,
  bool includesSeconds = true,

  /// If `true`, values equal to 0 will not be included.
  bool condensed = false,

  /// If `true`, only the largest 2 quantities will be shown.
  ///
  /// Examples:
  ///   - 1d 12h
  ///   - 12h 30m
  ///   - 30m 45s
  bool showHighestTwoOnly = false,
}) {
  int totalMillis = 0;

  durations.forEach((Duration duration) {
    totalMillis += duration.inMilliseconds;
  });

  DisplayDuration duration = DisplayDuration(
    Duration(milliseconds: totalMillis),
    includesDays: includesDays,
    includesHours: includesHours,
    includesMinutes: includesMinutes,
  );

  String result = "";

  maybeAddSpace() {
    if (result.isNotEmpty) {
      result += " ";
    }
  }

  int numberIncluded = 0;

  bool shouldAdd(bool include, int value) {
    return include
        && (!condensed || value > 0)
        && (!showHighestTwoOnly || numberIncluded < 2);
  }

  if (shouldAdd(includesDays, duration.days)) {
    result += format(Strings.of(context).daysFormat, [duration.days]);
    numberIncluded++;
  }

  if (shouldAdd(includesHours, duration.hours)) {
    maybeAddSpace();
    result += format(Strings.of(context).hoursFormat, [duration.hours]);
    numberIncluded++;
  }

  if (shouldAdd(includesMinutes, duration.minutes)) {
    maybeAddSpace();
    result += format(Strings.of(context).minutesFormat, [duration.minutes]);
    numberIncluded++;
  }

  if (shouldAdd(includesSeconds, duration.seconds)) {
    maybeAddSpace();
    result += format(Strings.of(context).secondsFormat, [duration.seconds]);
  }

  return result;
}