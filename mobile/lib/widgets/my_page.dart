import 'dart:io';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/widgets/pro_chip_button.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/activity_log_pro_page.dart';

class MyPageAppBarStyle {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLeadingProButton;

  /// When set, replaces the default [Text] title widget. Takes precedence over
  /// [title] and [subtitle].
  final Widget? titleWidget;

  MyPageAppBarStyle({
    this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showLeadingProButton = false,
    this.titleWidget,
  });
}

class MyPage extends StatelessWidget {
  static const _leadingProButtonWidth = 98.0;

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
              leading: _appBarStyle.leading ?? _buildLeadingProButton(context),
              leadingWidth: _appBarStyle.showLeadingProButton
                  ? _leadingProButtonWidth
                  : null,
              elevation: 0,
              centerTitle: true,
            ),
      body: SafeArea(child: _child),
    );
  }

  Widget? _buildLeadingProButton(BuildContext context) {
    if (!_appBarStyle!.showLeadingProButton) {
      return null;
    }

    return ProChipButton(
      ActivityLogProPage(),
      isOnAppColor: !context.isDarkTheme,
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
