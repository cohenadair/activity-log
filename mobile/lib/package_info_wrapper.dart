import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoWrapper {
  static var _instance = PackageInfoWrapper._();

  static PackageInfoWrapper get get => _instance;

  @visibleForTesting
  static void set(PackageInfoWrapper manager) => _instance = manager;

  @visibleForTesting
  static void suicide() => _instance = PackageInfoWrapper._();

  PackageInfoWrapper._();

  Future<PackageInfo> fromPlatform() => PackageInfo.fromPlatform();
}
