import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';

class Button extends StatelessWidget {
  final String _text;
  final VoidCallback _onPressed;
  final Icon? _icon;
  final Color? _color;

  const Button({
    required String text,
    required VoidCallback onPressed,
    Icon? icon,
    Color? color,
  })  : _text = text,
        _onPressed = onPressed,
        _icon = icon,
        _color = color;

  @override
  Widget build(BuildContext context) {
    return _icon == null
        ? ElevatedButton(
            onPressed: _onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _color,
              elevation: 0,
            ),
            child: _textWidget,
          )
        : ElevatedButton.icon(
            onPressed: _onPressed,
            icon: _icon!,
            label: _textWidget,
            style: ElevatedButton.styleFrom(
              backgroundColor: _color,
              elevation: 0,
            ),
          );
  }

  Widget get _textWidget => Text(_text.toUpperCase());
}

/// A [TextButton] wrapper meant to be used as an action in an [AppBar].
class ActionButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;

  final String? _stringId;

  const ActionButton({
    required this.text,
    required this.onPressed,
  }) : _stringId = null;

  const ActionButton.done({required this.onPressed})
      : _stringId = "done",
        text = null;

  const ActionButton.save({required this.onPressed})
      : _stringId = "save",
        text = null;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      child:
          Text((text ?? Strings.of(context).fromId(_stringId!)).toUpperCase()),
    );
  }
}
