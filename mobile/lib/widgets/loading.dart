import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

class Loading extends StatelessWidget {
  final EdgeInsets _padding;

  // ignore: missing_identifier
  Loading({
    EdgeInsets padding = insetsZero
  }) : _padding = padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: SizedBox.fromSize(
        size: Size(20, 20),
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}