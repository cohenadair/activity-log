import 'dart:io';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';

class MyPageAppBarStyle {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  /// When set, replaces the default [Text] title widget. Takes precedence over
  /// [title] and [subtitle].
  final Widget? titleWidget;

  MyPageAppBarStyle({
    this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.titleWidget,
  });
}

class MyPage extends StatelessWidget {
  final Widget _child;
  final MyPageAppBarStyle? _appBarStyle;

  const MyPage({required Widget child, MyPageAppBarStyle? appBarStyle})
    : _child = child,
      _appBarStyle = appBarStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarStyle == null
          ? null
          : AppBar(
              title: _buildTitle(context),
              actions: _appBarStyle.actions,
              leading: _appBarStyle.leading,
              elevation: 0,
              centerTitle: true,
            ),
      body: SafeArea(child: _child),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final style = _appBarStyle!;

    if (style.titleWidget != null) {
      return style.titleWidget!;
    }

    if (style.subtitle != null) {
      return _buildTitleWithSubtitle(context);
    }

    return Text(style.title ?? "");
  }

  Widget _buildTitleWithSubtitle(BuildContext context) {
    return Padding(
      padding: insetsTopSmall,
      child: Column(
        crossAxisAlignment: Platform.isAndroid
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: <Widget>[
          Text(_appBarStyle!.title ?? ""),
          Text(
            _appBarStyle.subtitle ?? "",
            style: Theme.of(
              context,
            ).textTheme.titleSmall!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
