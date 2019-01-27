import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

/// A default widget to be used in a ListView where ListTile isn't sufficient.
/// Includes:
///   - default padding
///   - InkWell tap animation
///   - safe area support
///   - a single Widget child
class CustomListTile extends StatelessWidget {
  final VoidCallback _onTap;
  final Widget _child;

  CustomListTile({@required Widget child, VoidCallback onTap})
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
              padding: insetsRowDefault,
              child: _child
            ),
          ),
        ),
      ],
    );
  }
}