import 'package:flutter/material.dart';

void push(BuildContext context, Widget page, {bool fullscreenDialog = false}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => page,
      fullscreenDialog: fullscreenDialog,
    ),
  );
}

void present(BuildContext context, Widget page) {
  push(context, page, fullscreenDialog: true);
}
