import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

class Loading extends StatelessWidget {
  static Widget centered() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Loading(padding: insetsDefault),
      ],
    );
  }

  final EdgeInsets _padding;

  const Loading({EdgeInsets padding = insetsZero}) : _padding = padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: SizedBox.fromSize(
        size: const Size(20, 20),
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
