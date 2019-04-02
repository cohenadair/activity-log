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
  final List<Future Function()> getFutureCallbacks;

  /// The [Stream]s to listen to.
  final List<Stream> streams;

  /// Invoked when the default constructor is used to instantiate a
  /// [FutureListener] object. The passed in [List] include the values returned
  /// by each future in [getFutureCallbacks], in the order given.
  final Widget Function(BuildContext, List<dynamic>) builder;

  /// Invoked when the [FutureListener.single] constructor is used to
  /// instantiate a [FutureListener] object. The passed in `dynamic` value is
  /// equal to the value returned by [getFutureCallback].
  final Widget Function(BuildContext, dynamic) singleBuilder;

  FutureListener({
    @required this.getFutureCallbacks,
    @required this.streams,
    @required this.builder,
  }) : assert(getFutureCallbacks != null),
       assert(getFutureCallbacks.isNotEmpty),
       assert(streams != null),
       assert(streams.isNotEmpty),
       assert(builder != null),
       singleBuilder = null;

  FutureListener.single({
    @required Future Function() getFutureCallback,
    @required Stream stream,
    @required Widget Function(BuildContext, dynamic) builder,
  }) : getFutureCallbacks = [ getFutureCallback ],
       streams = [ stream ],
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

    widget.streams.forEach((stream) =>
        _onUpdateEvents.add(stream.listen((newValue) {
          setState(() {
            _updateFutures();
          });
        })));

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
          return Empty();
        }

        if (widget.builder == null) {
          return widget.singleBuilder(context, snapshot.data.first);
        } else {
          return widget.builder(context, snapshot.data);
        }
      },
    );
  }

  void _updateFutures() {
    _futures.clear();
    widget.getFutureCallbacks.forEach((getFuture) {
      _futures.add(getFuture());
    });
  }
}