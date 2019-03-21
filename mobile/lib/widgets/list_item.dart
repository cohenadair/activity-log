import 'package:flutter/material.dart';

/// A [ListTile] wrapper with app default properties.
class ListItem extends StatelessWidget {
  final EdgeInsets contentPadding;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  ListItem({
    this.contentPadding,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        contentPadding: contentPadding,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}