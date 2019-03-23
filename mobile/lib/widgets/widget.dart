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

/// A wrapper around a [FutureBuilder] with an [AnimatedOpacity] child.
class FadeInFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(AsyncSnapshot<T>) builder;
  final Duration duration;

  FadeInFutureBuilder({
    @required this.future,
    @required this.builder,
    this.duration = const Duration(milliseconds: 200),
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (_, AsyncSnapshot<T> snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.hasData ? 1.0 : 0.0,
          duration: duration,
          child: builder(snapshot),
        );
      },
    );
  }
}