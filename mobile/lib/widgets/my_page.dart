import 'dart:io';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';

class MyPageAppBarStyle {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  MyPageAppBarStyle({this.title, this.subtitle, this.actions, this.leading});
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
              title: _appBarStyle.subtitle == null
                  ? Text(
                      _appBarStyle.title == null ? "" : _appBarStyle.title!,
                    )
                  : _buildTitleWithSubtitle(context),
              actions: _appBarStyle.actions,
              leading: _appBarStyle.leading,
              elevation: 0,
            ),
      body: SafeArea(child: _child),
    );
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
