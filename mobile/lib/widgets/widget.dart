import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

const defaultAnimationDuration = Duration(milliseconds: 200);

class Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class MinDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}

/// A wrapper for an [AnimatedOpacity] widget.
class FadeIn<T> extends StatefulWidget {
  final Widget Function(T) childBuilder;
  final Duration? duration;
  final bool visible;
  final T value;

  const FadeIn({
    required this.childBuilder,
    this.duration,
    this.visible = true,
    required this.value,
  });

  @override
  FadeInState createState() => FadeInState<T>();
}

class FadeInState<T> extends State<FadeIn<T>> {
  late T _lastValue;

  @override
  Widget build(BuildContext context) {
    _lastValue = widget.value;

    return AnimatedOpacity(
      opacity: widget.visible ? 1.0 : 0.0,
      duration: widget.duration ?? defaultAnimationDuration,
      child: widget.childBuilder(_lastValue),
    );
  }
}

/// A [Widget] meant to be displays when a page is "empty", such as a [ListView]
/// with no elements.
class EmptyPageHelp extends StatelessWidget {
  final double _opacity = 0.4;
  final double _containerSizeMultiplier = 0.5;
  final double _verticalCenterOffset = 40;

  final IconData icon;
  final String message;

  const EmptyPageHelp({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double iconSize = min(constraints.maxWidth, constraints.maxHeight);

            return Container(
              padding: insetsHorizontalDefault,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    size: iconSize * _containerSizeMultiplier,
                    color: Theme.of(context).disabledColor,
                  ),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  // Offset centering to account for icon padding.
                  SizedBox.fromSize(
                    size: Size.square(_verticalCenterOffset),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
