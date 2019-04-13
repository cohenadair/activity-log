import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/style.dart';

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
      titleTextStyle: styleTitleAlert,
      content: description == null ? null : Text(description),
      actions: <Widget>[
        buildDialogButton(
          context: context,
          name: Strings.of(context).cancel,
        ),
        buildDialogButton(
          context: context,
          name: Strings.of(context).delete,
          textColor: Colors.red,
          onTap: onDelete,
        ),
      ],
    )
  );
}

showWarning({
  @required BuildContext context,
  VoidCallback onContinue,
  String description,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(Strings.of(context).warning),
      titleTextStyle: styleTitleAlert,
      content: description == null ? null : Text(description),
      actions: <Widget>[
        buildDialogButton(
          context: context,
          name: Strings.of(context).cancel,
        ),
        buildDialogButton(
          context: context,
          name: Strings.of(context).continueString,
          textColor: Colors.red,
          onTap: onContinue,
        ),
      ],
    ),
  );
}

showError({
  @required BuildContext context,
  String description,
}) {
  showOk(
    context: context,
    title: Strings.of(context).error,
    description: description,
  );
}

showOk({
  @required BuildContext context,
  String title,
  String description,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title == null ? null : Text(title),
      titleTextStyle: styleTitleAlert,
      content: description == null ? null : Text(description),
      actions: <Widget>[
        buildDialogButton(context: context, name: Strings.of(context).ok),
      ],
    ),
  );
}

Widget buildDialogButton({
  @required BuildContext context,
  @required String name,
  Color textColor,
  VoidCallback onTap,
}) {
  return FlatButton(
    child: Text(name.toUpperCase()),
    textColor: textColor,
    onPressed: () {
      onTap?.call();
      Navigator.pop(context);
    },
  );
}
