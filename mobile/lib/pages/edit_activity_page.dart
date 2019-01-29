import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/page.dart';

class EditActivityPage extends StatefulWidget {
  final AppManager _app;
  final Activity _editingActivity;

  EditActivityPage(this._app, [this._editingActivity]);

  @override
  _EditActivityPageState createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();

  AppManager get _app => widget._app;
  Activity get _editingActivity => widget._editingActivity;
  bool get _isEditing => widget._editingActivity != null;

  TextEditingController _nameController;
  String _nameValidatorValue;

  @override
  void initState() {
    _nameController = TextEditingController(
      text: _isEditing ? _editingActivity.name : null
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: _isEditing
            ? Strings.of(context).editActivityPageEditTitle
            : Strings.of(context).editActivityPageNewTitle,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _onPressedSaveButton(context);
            },
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: Strings.of(context).editActivityPageNameLabel,
              ),
              validator: (String value) => _nameValidatorValue,
            ),
            Container(
              padding: insetsTopDefault,
              child: _isEditing ? Button(
                text: Strings.of(context).delete,
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                color: Colors.red,
                onPressed: () {
                  _onPressedDeleteButton();
                },
              ) : Container(),
            ),
          ],
        ),
      ),
    );
  }

  void _onPressedSaveButton(BuildContext context) {
    // Remove any trailing or leading spaces entered by the user.
    String nameCandidate = _nameController.text.trim();

    _validateNameField(context, nameCandidate, (String validationText) {
      _nameValidatorValue = validationText;

      if (!_formKey.currentState.validate()) {
        return;
      }

      if (_isEditing) {
        var builder = ActivityBuilder.fromActivity(_editingActivity)
            ..name = nameCandidate;
        _app.dataManager.updateActivity(builder.build);
      } else {
        _app.dataManager.addActivity(ActivityBuilder(nameCandidate).build);
      }

      Navigator.pop(context);
    });
  }

  void _onPressedDeleteButton() {
    showDeleteDialog(
      context: context,
      description: format(Strings.of(context).editActivityPageDeleteMessage,
          [_editingActivity.name]),
      onDelete: () {
        _app.dataManager.removeActivity(_editingActivity.id);
        Navigator.pop(context);
      }
    );
  }

  void _validateNameField(BuildContext context, String name,
      Function(String validationString) onFinish)
  {
    // The name hasn't changed, and therefore is still valid.
    if (_isEditing &&
        isEqualTrimmedLowercase(_editingActivity.name, name))
    {
      onFinish(null);
      return;
    }

    if (name.trim().isEmpty) {
      onFinish(Strings.of(context).editActivityPageMissingName);
      return;
    }

    _app.dataManager.activityNameExists(name).then((bool exists) {
      onFinish(exists ? Strings.of(context).editActivityPageNameExists : null);
    });
  }
}
