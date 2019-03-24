import 'dart:async';

import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class MinDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1);
  }
}

/// A wrapper for an [AnimatedOpacity] widget.
class FadeIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final bool visible;

  FadeIn({
    @required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.visible = true,
  }) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      child: child,
    );
  }
}