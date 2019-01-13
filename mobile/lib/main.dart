import 'package:flutter/material.dart';
import 'package:mobile/activity_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/pages/activities_page.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/splash_page.dart';
import 'package:mobile/res/style.dart';

void main() => runApp(ActivityLog());

class ActivityLog extends StatelessWidget {
  final ActivityManager _activityManager = ActivityManager();
  final AuthManager _authManager = AuthManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Log',
      theme: ThemeData(
        primarySwatch: Colors.green,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
        textTheme: TextTheme(
          title: Style.textTitle,
        ),
        errorColor: Colors.red,
      ),
      home: _authManager.getAuthStateListenerWidget(
        loading: SplashPage(),
        authenticate: LoginPage(_authManager),
        finished: ActivitiesPage(_activityManager, _authManager)
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
