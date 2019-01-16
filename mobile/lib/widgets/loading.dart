import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final EdgeInsets _padding;

  Loading({EdgeInsets padding}) : _padding = padding;

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