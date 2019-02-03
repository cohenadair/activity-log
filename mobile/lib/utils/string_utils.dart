import 'package:flutter/material.dart';

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

/// Formats a time of day from the given DateTime object. The format
/// depends on a combination of the current locale and the user's system time
/// format setting.
///
/// Example:
///   21:35, or
///   9:35 PM
String formatTime(BuildContext context, DateTime dateTime) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay.fromDateTime(dateTime),
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat
  );
}