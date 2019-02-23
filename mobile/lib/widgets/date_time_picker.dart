import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

/// A container for separate date and time pickers. Renders a horizontal [Flex]
/// widget with a 3:2 ratio for [DatePicker] and [TimePicker] respectively.
class DateTimePickerContainer extends StatelessWidget {
  final DatePicker datePicker;
  final TimePicker timePicker;
  final Widget helper;

  DateTimePickerContainer({
    @required this.datePicker,
    @required this.timePicker,
    this.helper,
  }) : assert(datePicker != null),
       assert(timePicker != null);

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
              child: Padding(
                padding: insetsRightWidget,
                child: datePicker,
              )
            ),
            Flexible(
              flex: 2,
              child: timePicker,
            ),
          ],
        ),
        helper == null ? Empty() : Padding(
          padding: insetsTopSmall,
          child: helper,
        ),
      ],
    );
  }
}

class DatePicker extends FormField<DateTime> {
  DatePicker({
    String label,
    DateTime initialDate,
    void Function(DateTime) onChange,
    String Function(DateTime) validator,
    bool enabled = true,
  }) : super(
    initialValue: initialDate,
    validator: validator,
    builder: (FormFieldState<DateTime> state) {
      return _Picker(
        label: label,
        errorText: state.errorText,
        enabled: enabled,
        type: _PickerType(
          getValue: () => DateText(
            state.value,
            enabled: enabled,
          ),
          openPicker: () {
            showDatePicker(
              context: state.context,
              initialDate: state.value,
              // Weird requirement of showDatePicker, but essentially
              // let the user pick any date in the past.
              firstDate: DateTime(1900),
              lastDate: DateTime.now()
            ).then((DateTime dateTime) {
              if (dateTime == null) {
                return;
              }
              state.didChange(dateTime);
              if (onChange != null) {
                onChange(dateTime);
              }
            });
          }
        ),
      );
    }
  );
}

class TimePicker extends FormField<TimeOfDay> {
  TimePicker({
    String label,
    TimeOfDay initialTime,
    Function(TimeOfDay) onChange,
    String Function(TimeOfDay) validator,
    bool enabled = true,
  }) : super(
    initialValue: initialTime,
    validator: validator,
    builder: (FormFieldState<TimeOfDay> state) {
      return _Picker(
        label: label,
        errorText: state.errorText,
        enabled: enabled,
        type: _PickerType(
          getValue: () => TimeText(
            state.value,
            enabled: enabled,
          ),
          openPicker: () {
            showTimePicker(
              context: state.context,
              initialTime: state.value,
            ).then((TimeOfDay time) {
              if (time == null) {
                return;
              }
              state.didChange(time);
              if (onChange != null) {
                onChange(time);
              }
            });
          }
        ),
      );
    }
  );
}

class _PickerType {
  final Widget Function() getValue;
  final VoidCallback openPicker;

  _PickerType({
    @required this.getValue,
    @required this.openPicker
  });
}

class _Picker extends StatelessWidget {
  final _PickerType type;
  final String label;
  final String errorText;
  final bool enabled;

  _Picker({
    @required this.type,
    @required this.label,
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