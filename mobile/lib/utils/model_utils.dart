import 'package:mobile/model/session.dart';
import 'package:mobile/utils/time_utils.dart';

class ModelUtils {
  static String getDisplayDuration(List<Session> sessions) {
    int totalMillis = 0;

    // Add all previous sessions.
    sessions.forEach((Session session) {
      totalMillis += session.millisecondsDuration;
    });

    int hours = (totalMillis / TimeUtils.msInHour).floor();
    totalMillis -= hours * TimeUtils.msInHour;
    int minutes = (totalMillis / TimeUtils.msInMinute).floor();
    totalMillis -= minutes * TimeUtils.msInMinute;
    int seconds = (totalMillis / TimeUtils.msInSecond).floor();

    return _formatDisplayDuration(hours, minutes, seconds);
  }

  static String getZeroDisplayDuration() {
    return _formatDisplayDuration(0, 0, 0);
  }

  static String _formatDisplayDuration(int hours, int minutes, int seconds) {
    return hours.toString() + "h " +
           minutes.toString() + "m " +
           seconds.toString() + "s";
  }
}