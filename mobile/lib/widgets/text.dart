import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:quiver/time.dart';

class ErrorText extends StatelessWidget {
  final String _text;

  ErrorText(this._text);

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: styleError,
    );
  }
}

class BoldText extends StatelessWidget {
  final String _text;

  BoldText(this._text);

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: styleHeading,
    );
  }
}

/// A Text widget that displays the total duration of list of Duration objects,
/// in the format Dd Hh Mm Ss.
///
/// Example:
///   - 0d 5h 30m 0s
class TotalDurationText extends StatelessWidget {
  final List<Duration> _durations;

  TotalDurationText(this._durations);

  @override
  Widget build(BuildContext context) {
    return Text(_format(context));
  }

  String _format(BuildContext context) {
    int totalMillis = 0;

    _durations.forEach((Duration duration) {
      totalMillis += duration.inMilliseconds;
    });

    DisplayDuration duration =
        DisplayDuration(Duration(milliseconds: totalMillis));

    String days =
        format(Strings.of(context).daysFormat, [duration.days]);
    String hours =
        format(Strings.of(context).hoursFormat, [duration.hours]);
    String minutes =
        format(Strings.of(context).minutesFormat, [duration.minutes]);
    String seconds =
        format(Strings.of(context).secondsFormat, [duration.seconds]);

    return "$days $hours $minutes $seconds";
  }
}

/// A Text widget for displaying a formatted date and a duration to the user.
///
/// Examples:
///   Today (3h 5m)
///   Yesterday (3h 5m)
///   Monday (15m)
///   Jan. 8 (30m)
///   Dec. 8, 2018 (5h)
class DateDurationText extends StatelessWidget {
  final Clock _clock;
  final DateTime _startDateTime;
  final Duration _duration;

  DateDurationText(this._startDateTime, this._duration, {
    Clock clock = const Clock()
  }) : _clock = clock;

  @override
  Widget build(BuildContext context) {
    return Text(_format(context));
  }

  String _format(BuildContext context) {
    final DateTime now = _clock.now();

    // Format the date.
    final String monthFormat = "MMM.";
    String formattedDate = "";

    if (isSameDate(_startDateTime, now)) {
      // Today.
      formattedDate = Strings.of(context).today;
    } else if (isYesterday(now, _startDateTime)) {
      // Yesterday.
      formattedDate = Strings.of(context).yesterday;
    } else if (isWithinOneWeek(_startDateTime, now)) {
      // 2 days ago to 6 days ago.
      formattedDate = DateFormat("EEEE").format(_startDateTime);
    } else if (isSameYear(_startDateTime, now)) {
      // Same year.
      formattedDate = DateFormat("$monthFormat d").format(_startDateTime);
    } else {
      // Different year.
      formattedDate =
          DateFormat("$monthFormat d, yyyy").format(_startDateTime);
    }

    // Format the duration.
    DisplayDuration duration = DisplayDuration(_duration, includesDays: false);
    String formattedDuration = "";

    if (duration.hours > 0) {
      formattedDuration +=
          format(Strings.of(context).hoursFormat, [duration.hours]);
      formattedDuration += " ";
    }

    if (duration.minutes >= 0) {
      formattedDuration +=
          format(Strings.of(context).minutesFormat, [duration.minutes]);
    }

    return format(Strings.of(context).sessionListTitleFormat,
        [formattedDate, formattedDuration]);
  }
}