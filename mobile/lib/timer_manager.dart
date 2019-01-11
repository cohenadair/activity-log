import 'model/timer.dart';

class TimerManager {
  List<Timer> _timers = [];
  List<Timer> get timers => _timers;

  List<TimerManagerListener> _listeners = [];

  TimerManager() {
    addTimer(Timer('Test 1'));
    addTimer(Timer('Test 2'));
    addTimer(Timer('Test 3'));
    addTimer(Timer('Test 4'));
  }

  void addTimer(Timer timer) {
    _timers.add(timer);
    _notifyTimerAdded();
  }

  void addListener(TimerManagerListener listener) {
    _listeners.add(listener);
  }

  void _notifyTimerAdded() {
    for (var listener in _listeners) {
      listener.onTimerAdded();
    }
  }
}

class TimerManagerListener {
  void onTimerAdded() {}
}
