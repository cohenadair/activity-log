import 'package:flutter/material.dart';

class PageUtils {
  static void push(BuildContext context, Widget page, {
    bool fullscreenDialog = false
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
        fullscreenDialog: fullscreenDialog,
      )
    );
  }
}