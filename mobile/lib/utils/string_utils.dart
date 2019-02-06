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