import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

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

/// A [Widget] meant to be displays when a page is "empty", such as a [ListView]
/// with no elements.
class EmptyPageHelp extends StatelessWidget {
  final double _opacity = 0.4;
  final double _containerSizeMultiplier = 0.5;
  final double _verticalCenterOffset = 40;

  final IconData icon;
  final String message;

  EmptyPageHelp({this.icon, this.message});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity,
      child: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
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
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  // Offset centering to account for icon padding.
                  SizedBox.fromSize(
                    size: Size.square(_verticalCenterOffset),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}