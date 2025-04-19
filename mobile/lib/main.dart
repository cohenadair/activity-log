import 'dart:async';
import 'dart:ui';
import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/l10n/gen/adair_flutter_lib_localizations.dart';
import 'package:adair_flutter_lib/managers/properties_manager.dart';
import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/gen/custom_icons.dart';

import 'database/data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Analytics.
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // Crashlytics. See https://firebase.flutter.dev/docs/crashlytics/usage for
  // error handling guidelines.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    kReleaseMode,
  );

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
  late Future<bool> _appInitializedFuture;

  @override
  void initState() {
    super.initState();

    AppConfig.get.init(
      appName: (context) => Strings.of(context).appName,
      appIcon: CustomIcons.app,
      colorAppTheme: Colors.green,
    );

    // Wait for all app initializations before showing the app as "ready".
    _appInitializedFuture = Future.wait([
      _initManagers(),
    ]).then((_) => true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: AppConfig.get.appName,
      theme: AdairFlutterLibTheme.light().copyWith(
        buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        iconTheme: IconThemeData(color: AppConfig.get.colorAppTheme),
        listTileTheme: ListTileThemeData(
          iconColor: AppConfig.get.colorAppTheme,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppConfig.get.colorAppTheme,
        ),
        checkboxTheme: _checkboxThemeData(),
      ),
      darkTheme: AdairFlutterLibTheme.dark().copyWith(
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
            return TextStyle(
              color: (states.contains(WidgetState.focused) &&
                      !states.contains(WidgetState.error))
                  ? AppConfig.get.colorAppTheme
                  : null,
            );
          }),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppConfig.get.colorAppTheme,
              width: 2.0,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(foregroundColor: _appThemeColor()),
        ),
        iconTheme: IconThemeData(color: AppConfig.get.colorAppTheme),
        checkboxTheme: _checkboxThemeData(),
        expansionTileTheme: ExpansionTileThemeData(
          textColor: AppConfig.get.colorAppTheme,
          iconColor: AppConfig.get.colorAppTheme,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: AppConfig.get.colorAppTheme,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppConfig.get.colorAppTheme,
        ),
        timePickerTheme: TimePickerThemeData(
          dialHandColor: AppConfig.get.colorAppTheme,
          hourMinuteTextColor: _timePickerTextColor(),
          hourMinuteColor: _timePickerTimeColor(),
          dayPeriodTextColor: _timePickerTextColor(),
          dayPeriodColor: _timePickerTimeColor(),
        ),
        datePickerTheme: DatePickerThemeData(
          dayOverlayColor: _appThemeColor(),
          dayBackgroundColor: _selectedBackgroundColor(),
          todayForegroundColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : AppConfig.get.colorAppTheme,
          ),
          todayBackgroundColor: _selectedBackgroundColor(),
        ),
      ),
      themeMode: themeMode,
      home: FutureBuilder<bool>(
        future: _appInitializedFuture,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(backgroundColor: AppConfig.get.colorAppTheme);
          }
          return MainPage();
        },
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        StringsDelegate(),
        AdairFlutterLibLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('en', 'CA')],
    );
  }

  WidgetStateColor _timePickerTextColor() {
    return WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppConfig.get.colorAppTheme
          : Colors.white,
    );
  }

  WidgetStateColor _timePickerTimeColor() {
    return WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppConfig.get.colorAppTheme.withValues(alpha: 0.24)
          : ThemeData.dark().colorScheme.onSurface.withValues(alpha: 0.12),
    );
  }

  WidgetStateColor _appThemeColor() {
    return WidgetStateColor.resolveWith((_) => AppConfig.get.colorAppTheme);
  }

  WidgetStateColor _selectedBackgroundColor() {
    return WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppConfig.get.colorAppTheme
          : Colors.transparent,
    );
  }

  CheckboxThemeData _checkboxThemeData() {
    return CheckboxThemeData(
      fillColor: _selectedBackgroundColor(),
      side: BorderSide(color: AppConfig.get.colorAppTheme, width: 2.0),
    );
  }

  Future<void> _initManagers() async {
    // Lib managers.
    await TimeManager.get.init();
    await PropertiesManager.get.init();
    await SubscriptionManager.get.init();

    // App managers.
    await PreferencesManager.get.init();
    await DataManager.get.init();
  }
}
