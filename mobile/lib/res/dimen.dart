import 'package:flutter/material.dart';

class Dimen {
  static const defaultPadding = 16.0;
  static const smallPadding = 8.0;
  static const widgetSpacing = defaultPadding;
  static const smallWidgetSpacing = smallPadding;

  static const defaultVerticalPadding = EdgeInsets.only(
      left: 0,
      top: defaultPadding,
      right: 0,
      bottom: defaultPadding
  );

  static const defaultTopPadding = EdgeInsets.only(
    left: 0,
    top: defaultPadding,
    right: 0,
    bottom: 0
  );

  static const defaultBottomPadding = EdgeInsets.only(
    left: 0,
    top: 0,
    right: 0,
    bottom: defaultPadding
  );

  static const defaultLeftPadding = EdgeInsets.only(
    left: defaultPadding,
    top: 0,
    right: 0,
    bottom: 0
  );

  static const rightWidgetSpacing = EdgeInsets.only(right: widgetSpacing);
  static const smallLeftWidgetSpacing = EdgeInsets.only(
    left: smallWidgetSpacing
  );
}