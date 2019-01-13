import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

/// A default widget to be used in a ListView. Includes:
///   - default padding
///   - InkWell tap animation
///   - safe area support
///   - divider
///   - a single Widget child
class ListItemView extends StatelessWidget {
  final VoidCallback _onTap;
  final Widget _child;

  ListItemView({@required Widget child, VoidCallback onTap})
    : _child = child,
      _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            if (_onTap != null) {
              _onTap();
            }
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(Dimen.defaultPadding),
              child: _child
            ),
          ),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}