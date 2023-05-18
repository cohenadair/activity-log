import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';

/// A widget that wraps a child in default localizations.
class Testable extends StatelessWidget {
  late final Widget Function(BuildContext) _builder;

  Testable(Widget child) {
    _builder = (_) => child;
  }

  // ignore: prefer_const_constructors_in_immutables
  Testable.builder(this._builder);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        StringsDelegate(),
        DefaultMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: const Locale("en", "CA"),
      home: _builder(context),
    );
  }
}

Future<BuildContext> pumpContext(
  WidgetTester tester,
  Widget Function(BuildContext) builder, {
  MediaQueryData mediaQueryData = const MediaQueryData(),
  ThemeMode? themeMode,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    Testable.builder(
      (buildContext) {
        context = buildContext;
        return builder(context);
      },
    ),
  );
  return context;
}

DisplayDateRange stubDateRange(DateRange dateRange) {
  return DisplayDateRange.newCustom(
    getValue: (_) => dateRange,
    getTitle: (_) => "",
  );
}

/// Different from [Finder.widgetWithText] in that it works for widgets with
/// generic arguments.
T findFirstWithText<T>(WidgetTester tester, String text) =>
    tester.firstWidget(find.ancestor(
      of: find.text(text),
      matching: find.byWidgetPredicate((widget) => widget is T),
    )) as T;

Future<void> enterTextFieldAndSettle(
    WidgetTester tester, String textFieldTitle, String text) async {
  await tester.enterText(find.widgetWithText(TextField, textFieldTitle), text);
  await tester.pumpAndSettle();
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder,
    [int? durationMillis]) async {
  await tester.tap(finder);
  if (durationMillis == null) {
    await tester.pumpAndSettle();
  } else {
    await tester.pumpAndSettle(Duration(milliseconds: durationMillis));
  }
}
