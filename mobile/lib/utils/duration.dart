import 'package:adair_flutter_lib/utils/duration.dart';

// TODO: Migrate preference to the lib's DurationUnit.
enum AppDurationUnit { days, hours, minutes }

DurationUnit toLibDurationUnit(AppDurationUnit unit) {
  switch (unit) {
    case AppDurationUnit.days:
      return DurationUnit.days;
    case AppDurationUnit.hours:
      return DurationUnit.hours;
    case AppDurationUnit.minutes:
      return DurationUnit.minutes;
  }
}
