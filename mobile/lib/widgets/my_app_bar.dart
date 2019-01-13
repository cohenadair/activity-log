import 'package:flutter/material.dart';

class MyAppBar extends AppBar {
  MyAppBar({Widget title, List<Widget> actions, Widget leading}) : super(
    title: title,
    actions: actions,
    elevation: 0.0,
    leading: leading,
  );
}