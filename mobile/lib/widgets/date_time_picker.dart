import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/text.dart';
import 'package:timezone/timezone.dart';

/// A container for separate date and time pickers. Renders a horizontal [Flex]
/// widget with a 3:2 ratio for [DatePicker] and [TimePicker] respectively.
class DateTimePickerContainer extends StatelessWidget {
  final DatePicker datePicker;
  final TimePicker timePicker;
  final Widget? helper;

  const DateTimePickerContainer({
    required this.datePicker,
    required this.timePicker,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.horizontal,
          children: <Widget>[
            Flexible(
              flex: 3,
              child: Padding(padding: insetsRightDefault, child: datePicker),
            ),
            Flexible(flex: 2, child: timePicker),
          ],
        ),
        helper == null
            ? const Empty()
            : Padding(padding: insetsTopSmall, child: helper),
      ],
    );
  }
}

class DatePicker extends FormField<TZDateTime> {
  DatePicker({
    required String label,
    TZDateTime? initialDate,
    void Function(TZDateTime)? onChange,
    super.validator,
    bool enabled = true,
  }) : super(
          initialValue: initialDate,
          builder: (FormFieldState<TZDateTime> state) {
            return _Picker(
              label: label,
              errorText: state.errorText,
              enabled: enabled,
              type: _PickerType(
                getValue: () => DateText(state.value!, enabled: enabled),
                openPicker: () {
                  showDatePicker(
                    context: state.context,
                    initialDate: state.value!,
                    // Weird requirement of showDatePicker, but
                    // essentially let the user pick any date in the past.
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ).then((dateTime) {
                    if (dateTime == null) {
                      return;
                    }
                    var result = TimeManager.get.dateTimeToTz(dateTime);
                    state.didChange(result);
                    if (onChange != null) {
                      onChange(result);
                    }
                  });
                },
              ),
            );
          },
        );
}

class TimePicker extends FormField<TimeOfDay> {
  TimePicker({
    required String label,
    TimeOfDay? initialTime,
    Function(TimeOfDay)? onChange,
    super.validator,
    bool enabled = true,
  }) : super(
          initialValue: initialTime,
          builder: (FormFieldState<TimeOfDay> state) {
            return _Picker(
              label: label,
              errorText: state.errorText,
              enabled: enabled,
              type: _PickerType(
                getValue: () => TimeText(state.value!, enabled: enabled),
                openPicker: () {
                  showTimePicker(
                    context: state.context,
                    initialTime: state.value!,
                  ).then((TimeOfDay? time) {
                    if (time == null) {
                      return;
                    }
                    state.didChange(time);
                    if (onChange != null) {
                      onChange(time);
                    }
                  });
                },
              ),
            );
          },
        );
}

class _PickerType {
  final Widget Function() getValue;
  final VoidCallback openPicker;

  _PickerType({required this.getValue, required this.openPicker});
}

class _Picker extends StatelessWidget {
  final _PickerType type;
  final String label;
  final String? errorText;
  final bool enabled;

  const _Picker({
    required this.type,
    required this.label,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? type.openPicker : null,
      child: InputDecorator(
        decoration: InputDecoration(
          enabled: enabled,
          labelText: label,
          errorText: errorText,
          errorMaxLines: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            type.getValue(),
            Icon(
              Icons.arrow_drop_down,
              color: enabled ? null : Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}
