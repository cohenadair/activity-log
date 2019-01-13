import 'package:flutter/material.dart';

class Button extends RaisedButton {
  Button({
    String text,
    bool uppercase = true,
    @required VoidCallback onPressed,
    Color color,
  }) : super(
    child: Text(uppercase ? text.toUpperCase() : text),
    onPressed: onPressed,
    elevation: 0,
    color: color,
  );

  static Widget icon({
    String text,
    Icon icon,
    VoidCallback onPressed,
    Color color,
  }) {
    return RaisedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(text.toUpperCase()),
      elevation: 0,
      color: color,
    );
  }
}