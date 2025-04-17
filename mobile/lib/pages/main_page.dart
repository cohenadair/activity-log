import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/activities_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/pages/stats_page.dart';

class MainPage extends StatefulWidget {
  const MainPage();

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentItemIndex = 0;

  List<_BarItemData> get _navItems {
    return [
      _BarItemData(
        page: ActivitiesPage(),
        item: BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: Strings.of(context).navigationBarHome,
        ),
      ),
      _BarItemData(
        page: StatsPage(),
        item: BottomNavigationBarItem(
          icon: const Icon(Icons.show_chart),
          label: Strings.of(context).navigationBarStats,
        ),
      ),
      _BarItemData(
        page: SettingsPage(),
        item: BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
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
        items: navItems.map((_BarItemData data) => data.item).toList(),
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

  _BarItemData({required this.page, required this.item});
}
