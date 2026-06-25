import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/xlsx_export.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mockito/mockito.dart';

import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  // Resolve the real temp path so the Isolate and the test agree on the
  // canonical form (macOS: /var/... is a symlink to /private/var/...).
  final tempPath = Directory.systemTemp.resolveSymbolicLinksSync();

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.lib.pathProviderWrapper.temporaryPath,
    ).thenAnswer((_) async => tempPath);

    managers.lib.stubCurrentTime(DateTime(2024, 1, 1));
  });

  test("exportXlsx with no activities produces a non-empty file", () async {
    when(managers.dataManager.activities).thenAnswer((_) async => []);

    final path = await exportXlsx();
    final file = File(path);

    expect(path, endsWith("ActivityLogExport.xlsx"));
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(0));
  });

  test(
    "exportXlsx with activities and sessions produces a non-empty file",
    () async {
      final activity = (ActivityBuilder("Running")..id = "A1").build;
      when(managers.dataManager.activities).thenAnswer((_) async => [activity]);

      final session =
          (SessionBuilder("S1")
                ..id = "S1"
                ..startTimestamp = 1000
                ..endTimestamp = 61000)
              .build;
      when(
        managers.dataManager.getSessions("A1"),
      ).thenAnswer((_) async => [session]);

      final path = await exportXlsx();
      final file = File(path);

      expect(path, endsWith("ActivityLogExport.xlsx"));
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(0));
    },
  );
}
