import 'package:flutter/material.dart';
import 'package:mobile/model/activity.dart';

/// A class that stores summarized data for an [Activity]. Used for analysis.
@immutable
class SummarizedActivity {
  final Activity value;
  final Duration totalDuration;
  final int numberOfSessions;

  SummarizedActivity({
    @required this.value,
    @required this.totalDuration,
    @required this.numberOfSessions,
  }) : assert(value != null),
       assert(totalDuration != null),
       assert(numberOfSessions != null);

  @override
  String toString() {
    return "{activity=${value.name}; duration=$totalDuration; "
        + "numberOfSessions=$numberOfSessions}";
  }
}