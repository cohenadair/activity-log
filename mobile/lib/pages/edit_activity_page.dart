import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  StreamSubscription<QuerySnapshot> _nameValidationListener;
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
              textCapitalization: TextCapitalization.words,
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

  void _onPressedSaveButton() {
    _validateNameField(_nameController.text, (String validationText) {
      _nameValidatorValue = validationText;

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

      if (_nameValidationListener != null) {
        _nameValidationListener.cancel();
      }

      _app.dataManager.addOrUpdateActivity(builder.build);
      Navigator.pop(context);
    });
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

  void _validateNameField(String name,
      Function(String validationString) onFinish)
  {
    // The name hasn't changed, and therefore is still valid.
    if (widget.isEditing &&
        StringUtils.isEqualTrimmedLowercase(widget._editingActivity.name, name))
    {
      onFinish(null);
      return;
    }

    if (name.trim().isEmpty) {
      onFinish("Enter a name for your activity");
      return;
    }

    _nameValidationListener = _app.dataManager.activityNameExists(name,
        (bool exists)
    {
      onFinish(exists ? "Activity name already exists" : null);
    });
  }
}
