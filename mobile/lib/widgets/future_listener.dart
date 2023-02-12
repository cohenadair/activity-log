import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

/// A utility [Widget] capable of listening to multiple [Stream]s.
///
/// The value of each [Stream] is never used. When an event is added to a given
/// [Stream], each given [Future] callback is invoked, and its [Future]
/// updated.
class FutureListener extends StatefulWidget {
  /// The [Future]s that are updated when their corresponding [Stream]
  /// receives an event.
  final List<Future<dynamic> Function()> getFutureCallbacks;

  /// The [Stream]s to listen to.
  final List<Stream<dynamic>> streams;

  /// Invoked when the default constructor is used to instantiate a
  /// [FutureListener] object. The passed in [List] include the values returned
  /// by each future in [getFutureCallbacks], in the order given.
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
  final VoidCallback? futuresHaveDataCallback;

  FutureListener({
    required this.getFutureCallbacks,
    required this.streams,
    required this.builder,
    this.initialValues = const [],
    this.futuresHaveDataCallback,
  })  : assert(getFutureCallbacks.isNotEmpty),
        assert(streams.isNotEmpty),
        singleBuilder = null;

  FutureListener.single({
    required Future Function() getFutureCallback,
    required Stream stream,
    required Widget Function(BuildContext, dynamic) builder,
    this.initialValues = const [],
    this.futuresHaveDataCallback,
  })  : getFutureCallbacks = [getFutureCallback],
        streams = [stream],
        singleBuilder = builder,
        builder = null;

  @override
  _FutureListenerState createState() => _FutureListenerState();
}

class _FutureListenerState extends State<FutureListener> {
  List<StreamSubscription> _onUpdateEvents = [];
  List<Future> _futures = [];

  @override
  void initState() {
    super.initState();

    widget.streams.forEach((stream) => _onUpdateEvents
        .add(stream.listen((newValue) => setState(() => _updateFutures()))));

    _updateFutures();
  }

  @override
  void dispose() {
    super.dispose();
    _onUpdateEvents.forEach((event) => event.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(_futures),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          if (widget.initialValues.isEmpty) {
            return Empty();
          }

          return _build(
            singleValue: widget.initialValues.first,
            multiValue: widget.initialValues,
          );
        }

        widget.futuresHaveDataCallback?.call();

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
    widget.getFutureCallbacks.forEach((getFuture) {
      _futures.add(getFuture());
    });
  }
}
