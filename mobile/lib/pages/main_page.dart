import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
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
  int _currentItemIndex = 0;

  List<_BarItemData> get _navItems {
    return [
      _BarItemData(
        page: ActivitiesPage(widget._app),
        item: BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: Strings.of(context).navigationBarHome,
        ),
      ),
      _BarItemData(
        page: StatsPage(widget._app),
        item: BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: Strings.of(context).navigationBarStats,
        ),
      ),
      _BarItemData(
        page: SettingsPage(widget._app),
        item: BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: Strings.of(context).navigationBarSettings,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _navItems;

    return Scaffold(
      // An IndexedStack is an easy way to keep page states while navigating
      // the app.
      body: IndexedStack(
        index: _currentItemIndex,
        children: navItems.map((barItem) => barItem.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentItemIndex,
        items: navItems.map((_BarItemData data) {
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
    required this.page,
    required this.item,
  });
}
