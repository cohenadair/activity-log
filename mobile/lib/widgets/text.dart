import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';

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

/// A Text widget that displays the total duration of list of Session objects,
/// in the format Dd Hh Mm Ss.
///
/// Example:
///   - 0d 5h 30m 0s
class TotalDurationText extends StatelessWidget {
  final List<Session> _sessions;

  TotalDurationText(this._sessions);

  @override
  Widget build(BuildContext context) {
    return Text(_format(context));
  }

  String _format(BuildContext context) {
    int totalMillis = 0;

    _sessions.forEach((Session session) {
      totalMillis += session.millisecondsDuration;
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