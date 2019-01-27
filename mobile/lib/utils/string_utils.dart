/// A trimmed, case-insensitive string comparison.
bool isEqualTrimmedLowercase(String s1, String s2) {
  return s1.trim().toLowerCase() == s2.trim().toLowerCase();
}

/// Returns true if the given string is null, empty, or empty when trimmed.
bool isEmpty(String s) {
  return s == null || s.trim().isEmpty;
}