import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String _text;
  final VoidCallback _onPressed;
  final Icon _icon;
  final Color _color;

  Button({
    @required String text,
    @required VoidCallback onPressed,
    Icon icon,
    Color color,
  }) : assert(text != null),
       assert(onPressed != null),
       _text = text,
       _onPressed = onPressed,
       _icon = icon,
       _color = color;

  @override
  Widget build(BuildContext context) {
    return _icon == null ? RaisedButton(
      child: _textWidget,
      onPressed: _onPressed,
      color: _color,
      elevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
    ) : RaisedButton.icon(
      onPressed: _onPressed,
      icon: _icon,
      label: _textWidget,
      color: _color,
      elevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
    );
  }

  Widget get _textWidget => Text(_text.toUpperCase());
}