import 'package:mobile/model/session.dart';

String formatTotalDuration(List<Session> sessions) {
  int totalMillis = 0;

  // Add all previous sessions.
  sessions.forEach((Session session) {
    totalMillis += session.millisecondsDuration;
  });

  Duration duration = Duration(milliseconds: totalMillis);
  int hours = duration.inHours.remainder(Duration.hoursPerDay);
  int minutes = _getMinutes(duration);
  int seconds = _getSeconds(duration);

  return "${duration.inDays}d ${hours}h ${minutes}m ${seconds}s";
}

String formatSessionDuration(Session session) {
  Duration duration = Duration(milliseconds: session.millisecondsDuration);

  // Modified from Duration.toString() implementation.
  String twoDigits(int n) {
    return (n >= 10) ? "$n" : "0$n";
  }

  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(_getMinutes(duration));
  String seconds = twoDigits(_getSeconds(duration));

  return "$hours:$minutes:$seconds";
}

int _getMinutes(Duration duration) {
  return duration.inMinutes.remainder(Duration.minutesPerHour);
}

int _getSeconds(Duration duration) {
  return duration.inSeconds.remainder(Duration.secondsPerMinute);
}