import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
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
        title: _isEditing ? "Edit Activity" : "New Activity",
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: "Save activity",
            onPressed: _onPressedSaveButton,
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
                labelText: "Name",
              ),
              validator: (String value) => _nameValidatorValue,
            ),
            Container(
              padding: Dimen.defaultTopPadding,
              child: _isEditing ? Button(
                text: "Delete",
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

  void _onPressedSaveButton() {
    // Remove any trailing or leading spaces entered by the user.
    String nameCandidate = _nameController.text.trim();

    _validateNameField(nameCandidate, (String validationText) {
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
    DialogUtils.showDeleteDialog(
      context: context,
      description: "Are you sure you want to delete activity " +
                   "${_editingActivity.name}? This action cannot be" +
                   " undone.",
      onDelete: () {
        _app.dataManager.removeActivity(_editingActivity.id);
        Navigator.pop(context);
      }
    );
  }

  void _validateNameField(String name,
      Function(String validationString) onFinish)
  {
    // The name hasn't changed, and therefore is still valid.
    if (_isEditing &&
        StringUtils.isEqualTrimmedLowercase(_editingActivity.name, name))
    {
      onFinish(null);
      return;
    }

    if (name.trim().isEmpty) {
      onFinish("Enter a name for your activity");
      return;
    }

    _app.dataManager.activityNameExists(name).then((bool exists) {
      onFinish(exists ? "Activity name already exists" : null);
    });
  }
}
