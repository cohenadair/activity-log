import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/pages/edit_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return EditPage(
      title: _isEditing
          ? format(Strings.of(context).editSessionPageEditTitle,
              [_activity.name])
          : format(Strings.of(context).editSessionPageNewTitle,
              [_activity.name]),
      padding: insetsZero,
      onSave: () => {},
      onDelete: () => _app.dataManager.removeSession(_editingSession),
      deleteDescription: Strings.of(context).sessionListDeleteMessage,
      isEditingCallback: () => _isEditing,
      form: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            MinContainer(),
          ],
        ),
      ),
    );
  }
}