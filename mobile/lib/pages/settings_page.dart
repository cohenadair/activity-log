import 'package:flutter/material.dart';
import 'package:mobile/widgets/page.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: "Settings",
      ),
      child: Text("SETTINGS"),
    );
  }
}