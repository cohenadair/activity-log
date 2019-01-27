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
  final EdgeInsets _padding;

  Page({
    @required Widget child,
    PageAppBarStyle appBarStyle,
    EdgeInsets padding,
  }) : assert(child != null),
       _child = child,
       _appBarStyle = appBarStyle,
       _padding = padding;

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
        padding: _padding == null ? insetsRowDefault : _padding,
        child: SafeArea(child: _child),
      ),
    );
  }
}