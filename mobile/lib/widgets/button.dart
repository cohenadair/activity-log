import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';

/// A [TextButton] wrapper meant to be used as an action in an [AppBar].
class ActionButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;

  final String? _stringId;

  const ActionButton({required this.text, required this.onPressed})
    : _stringId = null;

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
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: Text(
        (text ?? Strings.of(context).fromId(_stringId!)).toUpperCase(),
      ),
    );
  }
}
