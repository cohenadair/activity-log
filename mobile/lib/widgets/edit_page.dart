import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class EditPage extends StatelessWidget {
  final String _title;
  final VoidCallback _onPressedSaveButton;
  final VoidCallback _onPressedDeleteButton;
  final String _deleteDescription;
  final bool Function() _isEditingCallback;
  final Form _form;
  final EdgeInsets _padding;

  EditPage({
    String title,
    VoidCallback onSave,
    VoidCallback onDelete,
    String deleteDescription,
    @required isEditingCallback,
    @required form,
    EdgeInsets padding,
  }) : assert(form != null),
       _title = title,
       _onPressedSaveButton = onSave,
       _onPressedDeleteButton = onDelete,
        _deleteDescription = deleteDescription,
       _isEditingCallback = isEditingCallback,
       _form = form,
       _padding = padding;

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: _title,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _onPressedSaveButton,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: _padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _form,
                _isEditingCallback() ? Container(
                  padding: EdgeInsets.only(
                    top: paddingDefault,
                    left: _padding.left == 0 ? paddingDefault : 0,
                    right: _padding.right == 0 ? paddingDefault : 0,
                  ),
                  child: _getDeleteButton(context),
                ) : MinContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getDeleteButton(BuildContext context) {
    return Button(
      text: Strings.of(context).delete,
      icon: Icon(
        Icons.delete,
        color: Colors.white,
      ),
      color: Colors.red,
      onPressed: () {
        if (_deleteDescription == null) {
          _onPressedDeleteButton();
        } else {
          // If a delete confirmation description is provided,
          // show a confirmation dialog.
          showDeleteDialog(
            context: context,
            description: _deleteDescription,
            onDelete: () {
              _onPressedDeleteButton();
              Navigator.pop(context);
            }
          );
        }
      },
    );
  }
}