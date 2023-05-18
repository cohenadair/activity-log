import 'package:flutter/material.dart';

const themeMode = ThemeMode.system;
const colorAppTheme = Colors.green;

extension BuildContexts on BuildContext {
  bool get isDarkTheme {
    switch (themeMode) {
      case ThemeMode.system:
        return MediaQuery.of(this).platformBrightness == Brightness.dark;
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
    }
  }

  Color get colorText => isDarkTheme ? Colors.white : Colors.black;

  Color get colorBarChartLines => isDarkTheme ? Colors.white12 : Colors.black12;

  Color get colorSecondaryText => isDarkTheme ? Colors.white54 : Colors.black54;
}
