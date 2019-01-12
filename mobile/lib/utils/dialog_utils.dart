import 'package:flutter/material.dart';

class DialogUtils {
  static showDeleteDialog({@required BuildContext context, String title,
      String description, VoidCallback onDelete})
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: title == null ? null : Text(title),
        content: description == null ? null : Text(description),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'.toUpperCase()),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Delete'.toUpperCase()),
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
}
