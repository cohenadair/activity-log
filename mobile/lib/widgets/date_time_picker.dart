import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/text.dart';

class DateTimePicker extends StatefulWidget {
  final String dateLabel;
  final String timeLabel;
  final DateTime dateTime;
  final EdgeInsets padding;

  DateTimePicker({
    @required this.dateLabel,
    @required this.timeLabel,
    @required this.dateTime,
    this.padding = insetsZero,
  });

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime _date;
  TimeOfDay _time;

  @override
  void initState() {
    _date = widget.dateTime;
    _time = TimeOfDay.fromDateTime(widget.dateTime);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: _Picker(
              type: _PickerType(
                getValue: () => DateText(_date),
                openPicker: () {
                  showDatePicker(
                    context: context,
                    initialDate: _date,
                    // Weird requirement of showDatePicker, but essentially
                    // let the user pick any date.
                    firstDate: DateTime(1900),
                    lastDate: DateTime(3000)
                  ).then((DateTime dateTime) {
                    if (dateTime == null) {
                      return;
                    }
                    _date = dateTime;
                    setState(() {});
                  });
                }
              ),
              label: widget.dateLabel,
            ),
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding: insetsLeftDefault,
              child: _Picker(
                type: _PickerType(
                  getValue: () => TimeText(_time),
                  openPicker: () {
                    showTimePicker(
                      context: context,
                      initialTime: _time,
                    ).then((TimeOfDay time) {
                      if (time == null) {
                        return;
                      }
                      _time = time;
                      setState(() {});
                    });
                  }
                ),
                label: widget.timeLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerType {
  final Widget Function() getValue;
  final VoidCallback openPicker;

  _PickerType({
    @required this.getValue,
    @required this.openPicker
  });
}

class _Picker extends StatefulWidget {
  final _PickerType type;
  final String label;

  _Picker({
    @required this.type,
    @required this.label,
  });

  @override
  _PickerState createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.type.openPicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            widget.type.getValue(),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}