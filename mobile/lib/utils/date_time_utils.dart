import 'package:intl/intl.dart';

/// A representation of a Duration object meant to be shown to the user. Units
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

/// Calculates week number from a date as per
/// https://en.wikipedia.org/wiki/ISO_week_date#Calculation.
int getWeekNumber(DateTime dateTime) {
  int dayOfYear = int.parse(DateFormat("D").format(dateTime));
  return ((dayOfYear - dateTime.weekday + 10) / 7).floor();
}