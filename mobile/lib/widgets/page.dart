import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

class PageAppBarStyle {
  final String _title;
  final List<Widget> _actions;
  final Widget _leading;

  PageAppBarStyle({
    String title,
    List<Widget> actions,
    Widget leading
  }) : _title = title,
       _actions = actions,
       _leading = leading;
}

class Page extends StatelessWidget {
  final Widget _child;
  final PageAppBarStyle _appBarStyle;

  Page({
    @required Widget child,
    PageAppBarStyle appBarStyle,
  }) : assert(child != null),
       _child = child,
       _appBarStyle = appBarStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarStyle == null ? null : AppBar(
        title: Text(_appBarStyle._title),
        actions: _appBarStyle._actions,
        leading: _appBarStyle._leading,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(
          left: Dimen.defaultPadding,
          right: Dimen.defaultPadding,
          top: Dimen.smallPadding,
          bottom: Dimen.smallPadding
        ),
        child: SafeArea(child: _child),
      ),
    );
  }
}