import 'package:adair_flutter_lib/l10n/gen/adair_flutter_lib_localizations.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/my_page.dart' as p;

class EditPage extends StatelessWidget {
  final String _title;
  final VoidCallback _onPressedSaveButton;
  final VoidCallback _onPressedDeleteButton;
  final String? _deleteDescription;
  final bool Function() _isEditingCallback;
  final Form _form;
  final EdgeInsets _padding;

  const EditPage({
    required String title,
    required VoidCallback onSave,
    required VoidCallback onDelete,
    String? deleteDescription,
    required isEditingCallback,
    required form,
    required EdgeInsets padding,
  })  : assert(form != null),
        _title = title,
        _onPressedSaveButton = onSave,
        _onPressedDeleteButton = onDelete,
        _deleteDescription = deleteDescription,
        _isEditingCallback = isEditingCallback,
        _form = form,
        _padding = padding;

  @override
  Widget build(BuildContext context) {
    return p.MyPage(
      appBarStyle: p.MyPageAppBarStyle(
        title: _title,
        actions: <Widget>[ActionButton.save(onPressed: _onPressedSaveButton)],
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: _padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _form,
                _isEditingCallback()
                    ? Container(
                        padding: EdgeInsets.only(
                          top: paddingDefault,
                          left: _padding.left == 0 ? paddingDefault : 0,
                          right: _padding.right == 0 ? paddingDefault : 0,
                        ),
                        child: _getDeleteButton(context),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getDeleteButton(BuildContext context) {
    return Button(
      text: AdairFlutterLibLocalizations.of(context).delete,
      icon: const Icon(Icons.delete, color: Colors.white),
      color: Colors.red,
      onPressed: () {
        if (_deleteDescription == null) {
          _onPressedDeleteButton();
        } else {
          // If a delete confirmation description is provided,
          // show a confirmation dialog.
          showDeleteDialog(
            context: context,
            description: Text(_deleteDescription),
            onDelete: () {
              _onPressedDeleteButton();
              Navigator.pop(context);
            },
          );
        }
      },
    );
  }
}
