import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/widget.dart';

void main() => runApp(ActivityLog());

class ActivityLog extends StatelessWidget {
  final AppManager _app = AppManager();

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
        future: _app.dataManager.initialize(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(),
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
