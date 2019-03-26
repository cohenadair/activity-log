import 'package:flutter/material.dart';

const defaultAnimationDuration = Duration(milliseconds: 200);

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
class FadeIn<T> extends StatefulWidget {
  final Widget Function(T) childBuilder;
  final Duration duration;
  final bool visible;
  final T value;

  FadeIn({
    @required this.childBuilder,
    this.duration = defaultAnimationDuration,
    this.visible = true,
    @required this.value,
  }) : assert(childBuilder != null);

  @override
  _FadeInState createState() => _FadeInState<T>();
}

class _FadeInState<T> extends State<FadeIn<T>> {
  T _lastValue;

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) {
      _lastValue = widget.value;
    }

    return AnimatedOpacity(
      opacity: widget.visible ? 1.0 : 0.0,
      duration: widget.duration,
      child: widget.childBuilder(_lastValue),
    );
  }
}