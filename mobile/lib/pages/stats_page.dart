import 'package:flutter/material.dart';
import 'package:mobile/widgets/page.dart';

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: "Stats",
      ),
      child: Text("STATS"),
    );
  }
}