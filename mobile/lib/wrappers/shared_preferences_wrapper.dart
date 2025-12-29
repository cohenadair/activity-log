import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesWrapper {
  static var _instance = SharedPreferencesWrapper._();

  static SharedPreferencesWrapper get get => _instance;

  @visibleForTesting
  static void set(SharedPreferencesWrapper manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = SharedPreferencesWrapper._();

  SharedPreferencesWrapper._();

  SharedPreferencesAsync sharedPreferencesAsync({
    SharedPreferencesOptions options = const SharedPreferencesOptions(),
  }) {
    return SharedPreferencesAsync(options: options);
  }
}
