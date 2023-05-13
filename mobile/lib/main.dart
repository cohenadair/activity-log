import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';

import 'res/theme.dart';

void main() {
  runApp(ActivityLog());
}

class ActivityLog extends StatefulWidget {
  @override
  ActivityLogState createState() => ActivityLogState();
}

class ActivityLogState extends State<ActivityLog> {
  final AppManager _app = AppManager();
  late Future<bool> _appInitializedFuture;

  @override
  void initState() {
    super.initState();

    // Wait for all app initializations before showing the app as "ready".
    _appInitializedFuture = Future.wait([
      _app.preferencesManager.initialize(),
      _app.dataManager.initialize(_app),
    ]).then((_) => true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => Strings.of(context).appName,
      theme: ThemeData(
        primarySwatch: colorAppTheme,
        buttonTheme: const ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
        iconTheme: const IconThemeData(color: colorAppTheme),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: colorAppTheme,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: MaterialStateTextStyle.resolveWith((states) {
            return TextStyle(
              color:
                  states.contains(MaterialState.focused) ? colorAppTheme : null,
            );
          }),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorAppTheme,
              width: 2.0,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
                MaterialStateColor.resolveWith((_) => colorAppTheme),
          ),
        ),
        iconTheme: const IconThemeData(color: colorAppTheme),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateColor.resolveWith((_) => colorAppTheme),
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          textColor: colorAppTheme,
          iconColor: colorAppTheme,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: colorAppTheme,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: colorAppTheme,
        ),
      ),
      themeMode: themeMode,
      home: FutureBuilder<bool>(
        future: _appInitializedFuture,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const Scaffold(backgroundColor: colorAppTheme);
          }
          return MainPage(_app);
        },
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        StringsDelegate(),
        DefaultMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'CA'),
      ],
    );
  }
}
