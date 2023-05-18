import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

class Loading extends StatelessWidget {
  static Widget centered({Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Loading(
          padding: insetsDefault,
          color: color,
        ),
      ],
    );
  }

  final EdgeInsets padding;
  final Color? color;

  const Loading({
    this.padding = insetsZero,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox.fromSize(
        size: const Size(20, 20),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      ),
    );
  }
}
