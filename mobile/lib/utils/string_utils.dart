import 'package:flutter/material.dart';

/// A trimmed, case-insensitive string comparison.
bool isEqualTrimmedLowercase(String s1, String s2) {
  return s1.trim().toLowerCase() == s2.trim().toLowerCase();
}

/// Returns true if the given string is null, empty, or empty when trimmed.
bool isEmpty(String s) {
  return s == null || s.trim().isEmpty;
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

/// Formats a time of day from the given milliseconds since Epoch. The format
/// depends on a combination of the current locale and the user's system time
/// format setting.
String formatTime(BuildContext context, int millis) {
  DateTime time = DateTime.fromMillisecondsSinceEpoch(millis);
  return DefaultMaterialLocalizations().formatTimeOfDay(
    TimeOfDay.fromDateTime(time),
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat
  );
}