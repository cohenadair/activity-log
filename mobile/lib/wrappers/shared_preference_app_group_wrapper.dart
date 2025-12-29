import 'package:flutter/material.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';

class SharedPreferenceAppGroupWrapper {
  static var _instance = SharedPreferenceAppGroupWrapper._();

  static SharedPreferenceAppGroupWrapper get get => _instance;

  @visibleForTesting
  static void set(SharedPreferenceAppGroupWrapper manager) =>
      _instance = manager;

  @visibleForTesting
  static void reset() => _instance = SharedPreferenceAppGroupWrapper._();

  SharedPreferenceAppGroupWrapper._();

  Future<void> setAppGroup(String appGroup) =>
      SharedPreferenceAppGroup.setAppGroup(appGroup);

  Future<List<String>?> getStringList(String key) =>
      SharedPreferenceAppGroup.getStringList(key);

  Future<void> setStringList(String key, List<String>? value) =>
      SharedPreferenceAppGroup.setStringList(key, value);
}
