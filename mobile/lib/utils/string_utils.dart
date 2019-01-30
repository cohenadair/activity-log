import 'package:intl/intl.dart';

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
String format(String s, List<dynamic> args) {
  int index = 0;
  return s.replaceAllMapped(RegExp(r'%s'), (Match match) {
    return args[index++].toString();
  });
}

String formatTime(int millis) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(millis);
  return DateFormat().add_jm().format(date);
}