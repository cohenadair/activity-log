import 'package:quiver/time.dart';

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

bool isSameYear(DateTime a, DateTime b) {
  return a.year == b.year;
}

bool isSameMonth(DateTime a, DateTime b) {
  return a.month == b.month;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.day == b.day;
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