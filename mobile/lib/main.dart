import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/pages/activities_page.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/splash_page.dart';
import 'package:mobile/res/style.dart';

void main() => runApp(ActivityLog());

class ActivityLog extends StatelessWidget {
  final AppManager _app = AppManager();

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
      home: _app.authManager.getAuthStateListenerWidget(
        loading: SplashPage(),
        authenticate: LoginPage(_app),
        finished: ActivitiesPage(_app),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
