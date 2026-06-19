import 'package:adair_flutter_lib/widgets/pro_chip_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/my_page.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  testWidgets("No leading widget when showLeadingProButton is false", (
    tester,
  ) async {
    await pumpContext(
      tester,
      (_) => MyPage(
        appBarStyle: MyPageAppBarStyle(
          title: "Test",
          showLeadingProButton: false,
        ),
        child: const SizedBox(),
      ),
    );

    expect(find.byType(ProChipButton), findsNothing);
  });

  testWidgets(
    "Leading ProChipButton shown when showLeadingProButton is true and user is free",
    (tester) async {
      when(managers.subscriptionManager.isPro).thenReturn(false);

      await pumpContext(
        tester,
        (_) => MyPage(
          appBarStyle: MyPageAppBarStyle(
            title: "Test",
            showLeadingProButton: true,
          ),
          child: const SizedBox(),
        ),
      );

      expect(find.byType(ProChipButton), findsOneWidget);
    },
  );

  testWidgets("Leading uses provided widget and ignores showLeadingProButton", (
    tester,
  ) async {
    await pumpContext(
      tester,
      (_) => MyPage(
        appBarStyle: MyPageAppBarStyle(
          title: "Test",
          showLeadingProButton: true,
          leading: const Icon(Icons.close),
        ),
        child: const SizedBox(),
      ),
    );

    expect(find.byType(ProChipButton), findsNothing);
  });
}
