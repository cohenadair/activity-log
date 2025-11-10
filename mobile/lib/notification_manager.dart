import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/managers/notification_manager_base.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/l10n_extension.dart';

class NotificationManager extends NotificationManagerBase {
  static var _instance = NotificationManager._();

  static NotificationManager get get => _instance;

  @visibleForTesting
  static void set(NotificationManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = NotificationManager._();

  NotificationManager._();

  Future<bool> requestPermission(BuildContext context) {
    assert(IoWrapper.get.isAndroid);
    return super.requestPermissionIfNeeded(
      context,
      L10n.get.app.notificationPermissionPageDescAndroid,
    );
  }
}
