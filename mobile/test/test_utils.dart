import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/i18n/strings.dart';

import '../../../adair-flutter-lib/test/test_utils/testable.dart' as t;

class Testable extends StatelessWidget {
  final WidgetBuilder builder;
  final MediaQueryData mediaQueryData;

  const Testable(this.builder, {this.mediaQueryData = const MediaQueryData()});

  @override
  Widget build(BuildContext context) {
    return t.Testable(
      builder,
      mediaQueryData: mediaQueryData,
      localizations: [StringsDelegate()],
    );
  }
}

Future<BuildContext> buildContext(WidgetTester tester) =>
    t.buildContext(tester, localizations: [StringsDelegate()]);
