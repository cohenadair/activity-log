import 'package:flutter/material.dart';
import 'package:mobile/model/activity.dart';

/// A class that stores summarized data for an [Activity]. Used for analysis.
class SummarizedActivity {
  final Activity value;
  final Duration totalDuration;

  SummarizedActivity({
    @required this.value,
    @required this.totalDuration,
  });

  @override
  String toString() {
    return "{activity=${value.name}; duration=${totalDuration.toString()}}";
  }
}