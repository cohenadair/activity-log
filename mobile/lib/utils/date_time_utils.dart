import 'package:flutter/material.dart';
import 'package:quiver/time.dart';

/// A representation of a [Duration] object meant to be shown to the user. Units
/// are split by largest possible. For example, the hours property is the
/// number of hours in the duration, minus the number of days.
class DisplayDuration {
  final Duration _duration;
  final bool _includesDays;
  final bool _includesHours;
  final bool _includesMinutes;

  DisplayDuration(this._duration, {
    bool includesDays = true,
    bool includesHours = true,
    bool includesMinutes = true,
  }) : _includesDays = includesDays,
       _includesHours = includesHours,
       _includesMinutes = includesMinutes;

  int get days => _duration.inDays;

  int get hours {
    if (_includesDays) {
      return _duration.inHours.remainder(Duration.hoursPerDay);
    } else {
      return _duration.inHours;
    }
  }

  int get minutes {
    if (_includesHours) {
      return _duration.inMinutes.remainder(Duration.minutesPerHour);
    } else {
      return _duration.inMinutes;
    }
  }

  int get seconds {
    if (_includesMinutes) {
      return _duration.inSeconds.remainder(Duration.secondsPerMinute);
    } else {
      return _duration.inSeconds;
    }
  }
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({this.startDate, this.endDate});

  int get startMs => startDate.millisecondsSinceEpoch;
  int get endMs => endDate.millisecondsSinceEpoch;
}

bool isSameYear(DateTime a, DateTime b) {
  return a.year == b.year;
}

bool isSameMonth(DateTime a, DateTime b) {
  return a.month == b.month;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.day == b.day;
}

bool isSameTimeOfDay(DateTime a, DateTime b) {
  return TimeOfDay.fromDateTime(a) == TimeOfDay.fromDateTime(b);
}

/// Returns `true` if `a` is later in the day than `b`.
bool isLater(TimeOfDay a, TimeOfDay b) {
  return a.hour > b.hour || (a.hour == b.hour && a.minute > b.minute);
}

/// Returns `true` if the given [DateTime] comes after `now`, to minute
/// accuracy.
bool isInFutureWithMinuteAccuracy(DateTime dateTime, DateTime now) {
  DateTime newDateTime = dateTimeToMinuteAccuracy(dateTime);
  DateTime newNow = dateTimeToMinuteAccuracy(now);
  return newDateTime.isAfter(newNow);
}

/// Returns `true` if the given [DateTime] comes after `now`, to day
/// accuracy.
bool isInFutureWithDayAccuracy(DateTime dateTime, DateTime now) {
  DateTime newDateTime = dateTimeToDayAccuracy(dateTime);
  DateTime newNow = dateTimeToDayAccuracy(now);
  return newDateTime.isAfter(newNow);
}

/// Returns true if the given DateTime objects are equal. Compares
/// only year, month, and day.
bool isSameDate(DateTime a, DateTime b) {
  return isSameYear(a, b) && isSameMonth(a, b) && isSameDay(a, b);
}

bool isYesterday(DateTime today, DateTime yesterday) {
  return isSameDate(yesterday, today.subtract(aDay));
}

/// Returns true of the  given DateTime objects are within one week of one
/// another.
bool isWithinOneWeek(DateTime a, DateTime b) {
  return a.difference(b).inMilliseconds.abs() <= aWeek.inMilliseconds;
}

/// Returns a [DateTime] object with the given [DateTime] and [TimeOfDay]
/// combined.  Accurate to the minute.
DateTime combine(DateTime dateTime, TimeOfDay timeOfDay) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day, timeOfDay.hour,
      timeOfDay.minute);
}

/// Returns a new [DateTime] object, with time properties more granular than
/// minutes set to 0.
DateTime dateTimeToMinuteAccuracy(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      dateTime.minute);
}

/// Returns a new [DateTime] object, with time properties more granular than
/// day set to 0.
DateTime dateTimeToDayAccuracy(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

/// Returns a [DateTime] representing the start of the week to which `now`
/// belongs.
DateTime getStartOfWeek(DateTime now) {
  return dateTimeToDayAccuracy(now).subtract(Duration(days: now.weekday - 1));
}

/// Returns a [DateTime] representing the start of the month to which `now`
/// belongs.
DateTime getStartOfMonth(DateTime now) {
  return DateTime(now.year, now.month);
}

/// Returns a [DateTime] representing the start of the year to which `now`
/// belongs.
DateTime getStartOfYear(DateTime now) {
  return DateTime(now.year);
}