import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/text.dart';

/// A container for separate date and time pickers. Renders a horizontal [Flex]
/// widget with a 3:2 ratio for [DatePicker] and [TimePicker] respectively.
class DateTimePickerContainer extends StatelessWidget {
  final DatePicker datePicker;
  final TimePicker timePicker;

  DateTimePickerContainer({
    @required this.datePicker,
    @required this.timePicker
  }) : assert(datePicker != null),
       assert(timePicker != null);

  @override
  Widget build(BuildContext context) {
    return Flex(
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
    );
  }
}

class DatePicker extends FormField<DateTime> {
  DatePicker({
    String label,
    DateTime initialDate,
    void Function(DateTime) onChange,
    String Function(DateTime) validator,
  }) : super(
    initialValue: initialDate,
    validator: validator,
    builder: (FormFieldState<DateTime> state) {
      return _Picker(
        errorText: state.errorText,
        label: label,
        type: _PickerType(
          getValue: () => DateText(state.value),
          openPicker: () {
            showDatePicker(
              context: state.context,
              initialDate: state.value,
              // Weird requirement of showDatePicker, but essentially
              // let the user pick any date.
              firstDate: DateTime(1900),
              lastDate: DateTime(3000)
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
  }) : super(
    initialValue: initialTime,
    validator: validator,
    builder: (FormFieldState<TimeOfDay> state) {
      return _Picker(
        label: label,
        errorText: state.errorText,
        type: _PickerType(
          getValue: () => TimeText(state.value),
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

  _Picker({
    @required this.type,
    @required this.label,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: type.openPicker,
      child: InputDecorator(
        decoration: InputDecoration(
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
            ),
          ],
        ),
      ),
    );
  }
}