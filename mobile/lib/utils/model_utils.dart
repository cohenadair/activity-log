import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/utils/string_utils.dart';

const String monthFormatDefault = "MMM.";

String formatTotalDuration(BuildContext context, List<Session> sessions) {
  int totalMillis = 0;

  // Add all previous sessions.
  sessions.forEach((Session session) {
    totalMillis += session.millisecondsDuration;
  });

  Duration duration = Duration(milliseconds: totalMillis);

  String days =
      format(Strings.of(context).daysFormat, [duration.inDays]);
  String hours =
      format(Strings.of(context).hoursFormat, [_getHours(duration)]);
  String minutes =
      format(Strings.of(context).minutesFormat, [_getMinutes(duration)]);
  String seconds =
      format(Strings.of(context).secondsFormat, [_getSeconds(duration)]);

  return "$days $hours $minutes $seconds";
}

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
  } else if (_getWeekNumber(sessionDateTime) == _getWeekNumber(now)) {
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
  Duration duration = session.duration;
  String formattedDuration = "";

  if (duration.inHours > 0) {
    formattedDuration +=
        format(Strings.of(context).hoursFormat, [duration.inHours]);
    formattedDuration += " ";
  }

  if (duration.inMinutes > 0 || formattedDate.isNotEmpty) {
    formattedDuration +=
        format(Strings.of(context).minutesFormat, [duration.inMinutes]);
  }

  return format(Strings.of(context).sessionListTitleFormat,
      [formattedDate, formattedDuration]);
}

/// Formats the given session's duration as HH:MM:SS.
String formatRunningSessionDuration(Session session) {
  Duration duration = session.duration;

  // Modified from Duration.toString() implementation.
  String twoDigits(int n) {
    return (n >= 10) ? "$n" : "0$n";
  }

  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(_getMinutes(duration));
  String seconds = twoDigits(_getSeconds(duration));

  return "$hours:$minutes:$seconds";
}

int _getHours(Duration duration) {
  return duration.inHours.remainder(Duration.hoursPerDay);
}

int _getMinutes(Duration duration) {
  return duration.inMinutes.remainder(Duration.minutesPerHour);
}

int _getSeconds(Duration duration) {
  return duration.inSeconds.remainder(Duration.secondsPerMinute);
}

/// Calculates week number from a date as per
/// https://en.wikipedia.org/wiki/ISO_week_date#Calculation.
int _getWeekNumber(DateTime dateTime) {
  int dayOfYear = int.parse(DateFormat("D").format(dateTime));
  return ((dayOfYear - dateTime.weekday + 10) / 7).floor();
}