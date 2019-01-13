import 'package:flutter/material.dart';

class Button extends RaisedButton {
  Button({
    String text,
    bool uppercase = true,
    @required VoidCallback onPressed
  }) : super(
    child: Text(uppercase ? text.toUpperCase() : text),
    onPressed: onPressed,
    elevation: 0,
  );
}