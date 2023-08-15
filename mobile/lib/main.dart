import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';

import 'res/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Analytics.
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // Crashlytics. See https://firebase.flutter.dev/docs/crashlytics/usage for
  // error handling guidelines.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(kReleaseMode);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter
  // framework to Crashlytics.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
      _app.propertiesManager.initialize(),
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
              color: (states.contains(MaterialState.focused) &&
                      !states.contains(MaterialState.error))
                  ? colorAppTheme
                  : null,
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
            foregroundColor: _appThemeColor(),
          ),
        ),
        iconTheme: const IconThemeData(color: colorAppTheme),
        checkboxTheme: CheckboxThemeData(
          fillColor: _appThemeColor(),
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
        timePickerTheme: TimePickerThemeData(
          dialHandColor: colorAppTheme,
          hourMinuteTextColor: _timePickerTextColor(),
          hourMinuteColor: _timePickerTimeColor(),
          dayPeriodTextColor: _timePickerTextColor(),
          dayPeriodColor: _timePickerTimeColor(),
        ),
        datePickerTheme: DatePickerThemeData(
          dayOverlayColor: _appThemeColor(),
          dayBackgroundColor: _selectedBackgroundColor(),
          todayForegroundColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Colors.white
                  : colorAppTheme),
          todayBackgroundColor: _selectedBackgroundColor(),
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

  MaterialStateColor _timePickerTextColor() {
    return MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected) ? colorAppTheme : Colors.white);
  }

  MaterialStateColor _timePickerTimeColor() {
    return MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? colorAppTheme.withOpacity(0.24)
            : ThemeData.dark().colorScheme.onSurface.withOpacity(0.12));
  }

  MaterialStateColor _appThemeColor() {
    return MaterialStateColor.resolveWith((_) => colorAppTheme);
  }

  MaterialStateColor _selectedBackgroundColor() {
    return MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? colorAppTheme
            : Colors.transparent);
  }
}
