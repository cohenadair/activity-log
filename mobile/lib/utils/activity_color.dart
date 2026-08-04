import 'package:adair_flutter_lib/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/activity.dart';

/// Returns a color for [activity] that is stable across app launches and
/// platforms. Unlike [Object.hashCode], which is not spec-guaranteed to be
/// stable across Dart/Flutter SDK versions, this uses an explicit hash so
/// the same activity always maps to the same color.
Color activityColor(Activity activity) {
  var colors = accentColors();
  return colors[_stableHash(activity.id) % colors.length];
}

int _stableHash(String input) =>
    input.codeUnits.fold(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);
