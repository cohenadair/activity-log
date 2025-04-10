import 'dart:async';

import 'package:adair_flutter_lib/widgets/empty.dart';
import 'package:flutter/material.dart';

/// A utility [Widget] capable of listening to multiple [Stream]s.
///
/// The value of each [Stream] is never used. When an event is added to a given
/// [Stream], each given [Future] callback is invoked, and its [Future]
/// updated.
class FutureListener extends StatefulWidget {
  /// The [Future]s that are updated when one of [Stream]s in [streams]
  /// receives an event.
  final List<Future<dynamic> Function()> futuresCallbacks;

  /// The [Stream]s to listen to.
  final List<Stream<dynamic>> streams;

  /// Invoked when the default constructor is used to instantiate a
  /// [FutureListener] object. The passed in [List] include the values returned
  /// by each future in [futuresCallbacks], in the order given.
  final Widget Function(BuildContext, List<dynamic>?)? builder;

  /// Invoked when the [FutureListener.single] constructor is used to
  /// instantiate a [FutureListener] object. The passed in `dynamic` value is
  /// equal to the value returned by [getFutureCallback].
  final Widget Function(BuildContext, dynamic)? singleBuilder;

  /// Values to show while the given [Future] objects are being executed.
  /// The types of values in this [List] should be the same as the return
  /// type of each given [Future].
  final List<dynamic> initialValues;

  /// Called when the given [Future] objects are finished retrieving data.
  final VoidCallback? onFuturesFinished;

  FutureListener({
    required this.futuresCallbacks,
    required this.streams,
    required this.builder,
    this.initialValues = const [],
    this.onFuturesFinished,
  })  : assert(futuresCallbacks.isNotEmpty),
        assert(streams.isNotEmpty),
        singleBuilder = null;

  FutureListener.single({
    required Future Function() getFutureCallback,
    required Stream stream,
    required Widget Function(BuildContext, dynamic) builder,
    this.initialValues = const [],
    this.onFuturesFinished,
  })  : futuresCallbacks = [getFutureCallback],
        streams = [stream],
        singleBuilder = builder,
        builder = null;

  @override
  FutureListenerState createState() => FutureListenerState();
}

class FutureListenerState extends State<FutureListener> {
  final List<StreamSubscription> _onUpdateEvents = [];
  final List<Future> _futures = [];

  @override
  void initState() {
    super.initState();

    for (var stream in widget.streams) {
      _onUpdateEvents.add(
        stream.listen((newValue) => setState(() => _updateFutures())),
      );
    }

    _updateFutures();
  }

  @override
  void dispose() {
    super.dispose();
    for (var event in _onUpdateEvents) {
      event.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(_futures),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          if (widget.initialValues.isEmpty) {
            return const Empty();
          }

          return _build(
            singleValue: widget.initialValues.first,
            multiValue: widget.initialValues,
          );
        }

        widget.onFuturesFinished?.call();

        return _build(
          singleValue: snapshot.data.first,
          multiValue: snapshot.data,
        );
      },
    );
  }

  Widget _build({dynamic singleValue, List<dynamic>? multiValue}) {
    if (widget.builder == null) {
      return widget.singleBuilder!(context, singleValue);
    } else {
      return widget.builder!(context, multiValue);
    }
  }

  void _updateFutures() {
    _futures.clear();
    for (var getFuture in widget.futuresCallbacks) {
      _futures.add(getFuture());
    }
  }
}
