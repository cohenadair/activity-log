class StringUtils {
  /// A trimmed, case-insensitive string comparison.
  static bool isEqualTrimmedLowercase(String s1, String s2) {
    return s1.trim().toLowerCase() == s2.trim().toLowerCase();
  }
}