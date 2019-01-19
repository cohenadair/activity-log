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

  bool get isEditing => _editingActivity != null;

  @override
  _EditActivityPageState createState() => _EditActivityPageState(_app);
}

class _EditActivityPageState extends State<EditActivityPage> {
  final AppManager _app;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  String _nameValidatorValue;

  _EditActivityPageState(this._app);

  @override
  void initState() {
    _nameController = TextEditingController(
      text: widget.isEditing ? widget._editingActivity.name : null
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: widget.isEditing ? 'Edit Activity' : 'New Activity',
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Save activity',
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
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              validator: (String value) => _nameValidatorValue,
            ),
            Container(
              padding: Dimen.defaultTopPadding,
              child: widget.isEditing ? Button(
                text: 'Delete',
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

  void _onPressedSaveButton() async {
    // Validate name manually since it requires an async call to the database.
    _nameValidatorValue = await _validateNameField(_nameController.text);

    if (!_formKey.currentState.validate()) {
      return;
    }

    ActivityBuilder builder;
    if (widget._editingActivity == null) {
      builder = ActivityBuilder(_nameController.text);
    } else {
      builder = ActivityBuilder
          .fromActivity(widget._editingActivity)..name = _nameController.text;
    }

    _app.dataManager.addOrUpdateActivity(builder.build);
    Navigator.pop(context);
  }

  void _onPressedDeleteButton() {
    DialogUtils.showDeleteDialog(
      context: context,
      description: 'Are you sure you want to delete activity ' +
                   '${widget._editingActivity.name}? This action cannot be' +
                   ' undone.',
      onDelete: () {
        _app.dataManager.removeActivity(widget._editingActivity.id);
        Navigator.pop(context);
      }
    );
  }

  Future<String> _validateNameField(String name) async {
    // The name hasn't changed, and therefore is still valid.
    if (widget.isEditing &&
        StringUtils.isEqualTrimmedLowercase(widget._editingActivity.name, name))
    {
      return null;
    }

    if (name.trim().isEmpty) {
      return "Enter a name for your activity";
    }

    if (await _app.dataManager.activityNameExists(name)) {
      return "Activity name already exists";
    }

    return null;
  }
}
