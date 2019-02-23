import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/pages/activities_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/pages/stats_page.dart';

class MainPage extends StatefulWidget {
  final AppManager _app;

  MainPage(this._app);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<_BarItemData> _navItems;
  int _currentItemIndex = 0;

  @override
  void initState() {
    super.initState();
    _navItems = [
      _BarItemData(
        page: ActivitiesPage(widget._app),
        item: BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text("Home"),
        ),
      ),

      _BarItemData(
        page: StatsPage(),
        item: BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          title: Text("Stats"),
        ),
      ),

      _BarItemData(
        page: SettingsPage(),
        item: BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text("Settings"),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navItems[_currentItemIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentItemIndex,
        items: _navItems.map((_BarItemData data) {
          return data.item;
        }).toList(),
        onTap: (int index) {
          setState(() {
            _currentItemIndex = index;
          });
        },
      ),
    );
  }
}

class _BarItemData {
  final Widget page;
  final BottomNavigationBarItem item;

  _BarItemData({
    @required this.page,
    @required this.item,
  });
}