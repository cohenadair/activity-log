import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';

class ErrorText extends StatelessWidget {
  final String _text;

  ErrorText(this._text);

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: styleError,
    );
  }
}