import 'package:flutter/material.dart';

import 'package:mobile/timer_manager.dart';
import 'package:mobile/widgets/timer_list_view.dart';
import 'package:mobile/model/timer.dart';
import 'package:mobile/res/res.dart';

import 'new_timer_page.dart';

class TimersPage extends StatefulWidget {
  final TimerManager _timerManager;

  TimersPage(this._timerManager);

  @override
  _TimersPageState createState() => _TimersPageState(_timerManager);
}

class _TimersPageState extends State<TimersPage>
    implements TimerManagerListener
{
  final TimerManager _timerManager;
  List<Timer> _timers;

  _TimersPageState(this._timerManager) {
    _timers = _timerManager.timers;
    _timerManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timers'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add timer',
            onPressed: _onPressAddButton,
          )
        ],
        elevation: 0,
      ),
      body: ListView(
        children: TimerListView.getTimerViews(_timers, (Timer timer) {
          print('Tapped timer: ${timer.name}');
        }),
      )
    );
  }

  void _onPressAddButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTimerPage(),
        fullscreenDialog: true,
      )
    );
  }

  @override
  void onTimerAdded() {
    setState(() {
      _timers = widget._timerManager.timers;
    });
  }
}
