import 'package:flutter/material.dart';

import '../activity_manager.dart';
import '../model/activity.dart';
import '../res/res.dart';
import '../utils/dialog_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/page_container.dart';

class EditActivityPage extends StatefulWidget {
  final ActivityManager _activityManager;
  final Activity _editingActivity;

  EditActivityPage(this._activityManager, [this._editingActivity]);

  bool get isEditing => _editingActivity != null;

  @override
  _EditActivityPageState createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController(
      text: widget.isEditing ? widget._editingActivity.name : null
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text(widget.isEditing ? 'Edit Activity' : 'New Activity'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Save activity',
            onPressed: _onPressedSaveButton,
          )
        ],
      ),
      body: PageContainer(
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (String value) => _validateNameField(value),
              ),
              Container(
                padding: Dimen.defaultTopPadding,
                child: widget.isEditing ? FlatButton.icon(
                  label: Text('Delete'.toUpperCase()),
                  textColor: Colors.white,
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
      ),
    );
  }

  void _onPressedSaveButton() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (widget.isEditing) {
      widget._activityManager.updateActivity(
        widget._editingActivity,
        newActivity: (ActivityBuilder.fromActivity(widget._editingActivity)
            ..name = _nameController.text)
            .build
      );
    } else {
      widget._activityManager.addActivity(
          ActivityBuilder(_nameController.text).build);
    }

    Navigator.pop(context);
  }

  void _onPressedDeleteButton() {
    DialogUtils.showDeleteDialog(
      context: context,
      description: 'Are you sure you want to delete activity '
          + '${widget._editingActivity.name}? This action cannot be undone.',
      onDelete: () {
        widget._activityManager.deleteActivity(widget._editingActivity);
        Navigator.pop(context);
      }
    );
  }

  String _validateNameField(String name) {
    // The name hasn't changed, and therefore is still valid.
    if (widget.isEditing &&
        StringUtils.isEqualTrimmedLowercase(widget._editingActivity.name, name))
    {
      return null;
    }

    if (name.trim().isEmpty) {
      return "Enter a name for your activity";
    }

    if (widget._activityManager.activityNameExists(name)) {
      return "Activity name already exists";
    }

    return null;
  }
}
