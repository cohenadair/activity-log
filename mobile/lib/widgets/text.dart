import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';
import 'package:quiver/time.dart';

const monthDayFormat = "MMM. d";
const monthDayYearFormat = "MMM. d, yyyy";

/// An animated Text widget, styled as an error.  When the text changes from
/// null or empty to !empty or !null, the text is animated to show in the same
/// way [InputDecorator] animates errors into view (slide in from the top with
/// opacity).
class AnimatedErrorText extends StatefulWidget {
  final String text;
  final EdgeInsets padding;

  AnimatedErrorText(this.text, {EdgeInsets padding = insetsZero})
      : padding = padding;

  @override
  _AnimatedErrorTextState createState() => _AnimatedErrorTextState();
}

class _AnimatedErrorTextState extends State<AnimatedErrorText>
    with TickerProviderStateMixin {
  // Animation settings are copied from InputDecorator in order to stay
  // consistent with Material form widgets.
  final animationDuration = defaultAnimationDuration;
  final yStartOffset = -0.25;

  AnimationController _controller;
  Animation<Offset> _animationOffset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    _animationOffset = Tween<Offset>(
      begin: Offset(0.0, yStartOffset),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(AnimatedErrorText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Text goes from null to !null or vise-versa.
    bool textStateChanged = isEmpty(widget.text) != isEmpty(oldWidget.text);

    if (textStateChanged && isNotEmpty(widget.text)) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmpty(widget.text)) {
      return Empty();
    } else {
      return _buildText();
    }
  }

  Widget _buildText() {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _animationOffset,
        child: Padding(
          padding: widget.padding,
          child: ErrorText(widget.text),
        ),
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  final String text;

  ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: styleError,
    );
  }
}

class WarningText extends StatelessWidget {
  final String text;

  WarningText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.orange,
      ),
    );
  }
}

class HeadingText extends StatelessWidget {
  final String _text;

  HeadingText(this._text);

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: Theme.of(context).textTheme.bodyText1.copyWith(
            color: Theme.of(context).primaryColor,
          ),
    );
  }
}

class LargeHeadingText extends StatelessWidget {
  final String _text;

  LargeHeadingText(this._text);

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }
}

/// A [Text] widget meant to be used with secondary emphasis, normally on the
/// right side of [ListItem].
class SecondaryText extends StatelessWidget {
  final String text;

  SecondaryText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      // Same style used in ListTile.title.
      style: Theme.of(context).textTheme.subtitle1.copyWith(
            color: Theme.of(context).disabledColor,
          ),
    );
  }
}

/// A [Text] widget with an enabled state. If `enabled = false`, the [Text] is
/// rendered with a `Theme.of(context).disabledColor` color.
class EnabledText extends StatelessWidget {
  final String text;
  final bool enabled;

  EnabledText(this.text, {this.enabled = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: enabled ? null : Theme.of(context).disabledColor,
      ),
    );
  }
}

/// A Text widget that displays the total duration of list of [Duration]
/// objects. This widget is basically a wrapper for the String utility method,
/// [formatTotalDuration].
class TotalDurationText extends StatelessWidget {
  final List<Duration> durations;
  final bool includesDays;
  final bool includesHours;
  final bool includesMinutes;
  final bool includesSeconds;
  final bool condensed;
  final bool showHighestTwoOnly;
  final DurationUnit largestDurationUnit;

  TotalDurationText(
    this.durations, {
    this.includesDays = true,
    this.includesHours = true,
    this.includesMinutes = true,
    this.includesSeconds = true,
    this.condensed = false,
    this.showHighestTwoOnly = false,
    this.largestDurationUnit = DurationUnit.days,
  });

  @override
  Widget build(BuildContext context) {
    return Text(formatTotalDuration(
      context: context,
      durations: durations,
      includesDays: includesDays,
      includesHours: includesHours,
      includesMinutes: includesMinutes,
      includesSeconds: includesSeconds,
      condensed: condensed,
      showHighestTwoOnly: showHighestTwoOnly,
      largestDurationUnit: largestDurationUnit,
    ));
  }
}

/// A Text widget for displaying a formatted date and a duration to the user.
///
/// Examples:
///   - Today (3h 5m)
///   - Yesterday (3h 5m)
///   - Monday (15m)
///   - Jan. 8 (30m)
///   - Dec. 8, 2018 (5h)
class DateDurationText extends StatelessWidget {
  final Clock clock;
  final DateTime startDateTime;
  final Duration duration;
  final TextStyle style;
  final String suffix;

  DateDurationText(
    this.startDateTime,
    this.duration, {
    this.clock = const Clock(),
    this.style,
    this.suffix = "",
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(context),
      style: style,
    );
  }

  String _format(BuildContext context) {
    // Format the date.
    String formattedDate = formatDateAsRecent(
      context: context,
      dateTime: startDateTime,
      clock: clock,
    );

    // Format the duration.
    DisplayDuration displayDuration =
        DisplayDuration(duration, includesDays: false);
    String formattedDuration = "";

    if (displayDuration.hours == 0 &&
        displayDuration.minutes == 0 &&
        displayDuration.seconds > 0) {
      formattedDuration +=
          format(Strings.of(context).secondsFormat, [displayDuration.seconds]);
    } else {
      if (displayDuration.hours > 0) {
        formattedDuration +=
            format(Strings.of(context).hoursFormat, [displayDuration.hours]);
        formattedDuration += " ";
      }

      if (displayDuration.minutes >= 0) {
        formattedDuration += format(
            Strings.of(context).minutesFormat, [displayDuration.minutes]);
      }

      if (isEmpty(formattedDuration)) {
        formattedDuration += format(
            Strings.of(context).secondsFormat, [displayDuration.seconds]);
      }
    }

    return format(Strings.of(context).dateDurationFormat,
            [formattedDate, formattedDuration]) +
        suffix;
  }
}

/// A Text widget that formats a Duration object as if it were running.
///
/// Examples:
///   - 05:44:58
///   - 00:21:05
///   - 00:00:37
class RunningDurationText extends StatelessWidget {
  final Duration _duration;

  RunningDurationText(this._duration);

  @override
  Widget build(BuildContext context) {
    return Text(_format());
  }

  String _format() {
    DisplayDuration duration = DisplayDuration(_duration, includesDays: false);

    String twoDigits(int n) {
      return (n >= 10) ? "$n" : "0$n";
    }

    String hours = twoDigits(duration.hours);
    String minutes = twoDigits(duration.minutes);
    String seconds = twoDigits(duration.seconds);

    return "$hours:$minutes:$seconds";
  }
}

/// A formatted Text widget for a time of day. The display format depends on a
/// combination of the current locale and the user's system time format setting.
///
/// Example:
///   21:35, or
///   9:35 PM
class TimeText extends StatelessWidget {
  final TimeOfDay time;
  final bool enabled;

  TimeText(
    this.time, {
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnabledText(
      _format(context),
      enabled: enabled,
    );
  }

  String _format(BuildContext context) {
    return formatTimeOfDay(context, time);
  }
}

/// Two [TimeText] widgets in a row, separated by a dash.
class TimeRangeText extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool enabled;

  TimeRangeText({
    @required this.startTime,
    @required this.endTime,
    this.enabled = false,
  }) : assert(startTime != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TimeText(startTime, enabled: enabled),
        EnabledText(" - ", enabled: enabled),
        endTime == null
            ? EnabledText(Strings.of(context).now, enabled: enabled)
            : TimeText(endTime, enabled: enabled),
      ],
    );
  }
}

/// A formatted Text widget for a date.
///
/// Example:
///   Dec. 8, 2018
class DateText extends StatelessWidget {
  final DateTime date;
  final bool enabled;

  DateText(
    this.date, {
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnabledText(
      DateFormat(monthDayYearFormat).format(date),
      enabled: enabled,
    );
  }
}
