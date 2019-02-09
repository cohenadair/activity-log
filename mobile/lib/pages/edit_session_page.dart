import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/edit_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';

class EditSessionPage extends StatefulWidget {
  final AppManager _app;
  final Activity _activity;
  final Session _editingSession;

  EditSessionPage({
    @required AppManager app,
    @required Activity activity,
    Session editingSession
  }) : assert(app != null),
       assert(activity != null),
       _app = app,
       _activity = activity,
       _editingSession = editingSession;

  @override
  _EditSessionPageState createState() => _EditSessionPageState();
}

class _EditSessionPageState extends State<EditSessionPage> {
  final _formKey = GlobalKey<FormState>();

  AppManager get _app => widget._app;
  Activity get _activity => widget._activity;
  Session get _editingSession => widget._editingSession;
  bool get _isEditing => _editingSession != null;

  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now();

  @override
  void initState() {
    if (_isEditing) {
      _startDateTime = _editingSession.startDateTime;
      _endDateTime = _editingSession.endDateTime;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EditPage(
      title: _isEditing
          ? format(Strings.of(context).editSessionPageEditTitle,
              [_activity.name])
          : format(Strings.of(context).editSessionPageNewTitle,
              [_activity.name]),
      padding: insetsRowDefault,
      onSave: () => {},
      onDelete: () => _app.dataManager.removeSession(_editingSession),
      deleteDescription: Strings.of(context).sessionListDeleteMessage,
      isEditingCallback: () => _isEditing,
      form: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            DateTimePicker(
              padding: insetsBottomDefault,
              dateLabel: Strings.of(context).editSessionPageStartDate,
              timeLabel: Strings.of(context).editSessionPageStartTime,
              dateTime: _startDateTime,
            ),
            DateTimePicker(
              padding: insetsBottomDefault,
              dateLabel: Strings.of(context).editSessionPageEndDate,
              timeLabel: Strings.of(context).editSessionPageEndTime,
              dateTime: _endDateTime,
            ),
          ],
        ),
      ),
    );
  }
}