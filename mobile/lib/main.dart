import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/sqlite_open_helper.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/res/style.dart';

void main() => runApp(ActivityLog());

class ActivityLog extends StatefulWidget {
  @override
  _ActivityLogState createState() => _ActivityLogState();
}

class _ActivityLogState extends State<ActivityLog> {
  final AppManager _app = AppManager();
  Future<bool> _dbInitializedFuture;

  @override
  void initState() {
    super.initState();

    _dbInitializedFuture = Future(() async {
      _app.dataManager.initialize(await SQLiteOpenHelper.open());
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Colors.green;

    return MaterialApp(
      onGenerateTitle: (context) => Strings.of(context).appName,
      theme: ThemeData(
        primarySwatch: primaryColor,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        textTheme: TextTheme(
          title: styleTitle,
        ),
        errorColor: Colors.red,
      ),
      home: FutureBuilder<bool>(
        future: _dbInitializedFuture,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
              ),
            );
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
      supportedLocales: [
        Locale('en', 'US'),
        Locale('en', 'CA'),
      ],
    );
  }
}
