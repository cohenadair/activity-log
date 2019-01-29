import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';

showDeleteDialog({
  @required BuildContext context,
  String title,
  String description,
  VoidCallback onDelete
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: description == null ? null : Text(description),
      actions: <Widget>[
        FlatButton(
          child: Text(Strings.of(context).cancel.toUpperCase()),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text(Strings.of(context).delete.toUpperCase()),
          textColor: Colors.red,
          onPressed: () {
            if (onDelete != null) {
              onDelete();
            }
            Navigator.pop(context);
          },
        )
      ],
    )
  );
}
