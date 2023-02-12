import 'package:flutter/foundation.dart';

class Log {
  final String _className;
  final bool _isDebug;

  const Log(
    this._className, {
    bool isDebug = kDebugMode,
  }) : _isDebug = isDebug;

  String get _prefix => "AL-$_className: ";

  void d(String msg) {
    _log("D/$_prefix$msg");
  }

  void e(StackTrace stackTrace, String msg) {
    _log("E/$_prefix$msg", stackTrace);
  }

  void w(String msg) {
    _log("W/$_prefix$msg");
  }

  void _log(String msg, [StackTrace? stackTrace]) {
    if (_isDebug) {
      // ignore: avoid_print
      print(msg);
    }
  }
}
