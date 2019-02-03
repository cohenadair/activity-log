import 'package:mobile/model/session.dart';
import 'package:mobile/utils/date_time_utils.dart';

/// Formats the given session's duration as HH:MM:SS.
/// TODO: rename formatRunningDuration(Duration duration) and move to string_utils.
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