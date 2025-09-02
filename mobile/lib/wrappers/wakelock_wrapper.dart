import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockWrapper {
  static var _instance = WakelockWrapper._();

  static WakelockWrapper get get => _instance;

  @visibleForTesting
  static void set(WakelockWrapper manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = WakelockWrapper._();

  WakelockWrapper._();

  void enable() => WakelockPlus.enable();

  void disable() => WakelockPlus.disable();
}
