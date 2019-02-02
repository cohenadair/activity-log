import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';

const String monthFormatDefault = "MMM.";

/// Returns a formatted String for the given session, to be displayed to the
/// user.
///
/// Examples:
///   Today (3h 5m)
///   Yesterday (3h 5m)
///   Monday (15m)
///   Jan 8 (30m)
///   Dec 8, 2018 (5h)
String formatSessionTitle(BuildContext context, Session session) {
  DateTime now = DateTime.now();

  // Format the date.
  DateTime sessionDateTime = session.startDateTime;
  String formattedDate = "";

  if (sessionDateTime.weekday == now.weekday) {
    // Today
    formattedDate = Strings.of(context).today;
  } else if (sessionDateTime.weekday == now.weekday - 1) {
    // Yesterday
    formattedDate = Strings.of(context).yesterday;
  } else if (getWeekNumber(sessionDateTime) == getWeekNumber(now)) {
    // Same week
    formattedDate = DateFormat("EEEE").format(sessionDateTime);
  } else if (sessionDateTime.year == now.year) {
    // Same year
    formattedDate = DateFormat("$monthFormatDefault d").format(sessionDateTime);
  } else {
    // Different year
    formattedDate =
        DateFormat("$monthFormatDefault d, yyyy").format(sessionDateTime);
  }

  // Format the duration.
  DisplayDuration duration =
      DisplayDuration(session.duration, includesDays: false);
  String formattedDuration = "";

  if (duration.hours > 0) {
    formattedDuration +=
        format(Strings.of(context).hoursFormat, [duration.hours]);
    formattedDuration += " ";
  }

  if (duration.minutes > 0 || formattedDate.isNotEmpty) {
    formattedDuration +=
        format(Strings.of(context).minutesFormat, [duration.minutes]);
  }

  return format(Strings.of(context).sessionListTitleFormat,
      [formattedDate, formattedDuration]);
}

/// Formats the given session's duration as HH:MM:SS.
String formatRunningSessionDuration(Session session) {
  DisplayDuration duration =
      DisplayDuration(session.duration, includesDays: false);

  // Modified from Duration.toString() implementation.
  String twoDigits(int n) {
    return (n >= 10) ? "$n" : "0$n";
  }

  String hours = twoDigits(duration.hours);
  String minutes = twoDigits(duration.minutes);
  String seconds = twoDigits(duration.seconds);

  return "$hours:$minutes:$seconds";
}