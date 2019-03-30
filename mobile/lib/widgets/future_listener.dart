import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

/// A generic [FutureBuilder] wrapper that invokes `getFutureCallback`when
/// events are added to the given [Stream].
class FutureListener<T> extends StatefulWidget {
  final Future<T> Function() getFutureCallback;
  final Stream<T> stream;
  final Widget Function(T) builder;

  FutureListener({
    @required this.getFutureCallback,
    @required this.stream,
    @required this.builder,
  }) : assert(getFutureCallback != null),
       assert(stream != null),
       assert(builder != null);

  @override
  _FutureListenerState<T> createState() => _FutureListenerState<T>();
}

class _FutureListenerState<T> extends State<FutureListener<T>> {
  StreamSubscription<T> _onUpdate;
  Future<T> _future;

  @override
  void initState() {
    super.initState();

    _onUpdate = widget.stream.listen((_) {
      setState(() {
        _updateFuture();
      });
    });

    _updateFuture();
  }

  @override
  void dispose() {
    super.dispose();
    _onUpdate.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (!snapshot.hasData) {
          return Empty();
        }

        return widget.builder(snapshot.data);
      },
    );
  }

  void _updateFuture() {
    _future = widget.getFutureCallback();
  }
}