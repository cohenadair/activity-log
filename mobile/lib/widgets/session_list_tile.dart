import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/string_utils.dart';

class SessionListTile extends StatelessWidget {
  final Session _session;
  final bool _hasDivider;
  final VoidCallback _confirmedDeleteCallback;

  SessionListTile(
    this._session,
  {
    bool hasDivider,
    VoidCallback confirmedDeleteCallback,
  }) : _hasDivider = hasDivider,
       _confirmedDeleteCallback = confirmedDeleteCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: insetsLeftDefault,
          onTap: () {
          },
          title: Text(_titleText),
          subtitle: Text(_subtitleText),
          trailing: IconButton(
            color: Colors.red,
            icon: Icon(Icons.delete),
            onPressed: () {
              showDeleteDialog(
                context: context,
                description: Strings.of(context).sessionListDeleteMessage,
                onDelete: () {
                  _confirmedDeleteCallback();
                }
              );
            }
          ),
        ),
        _hasDivider ? Divider(height: 1) : Container(),
      ],
    );
  }

  String get _titleText {
    return "Title";
  }

  String get _subtitleText {
    if (_session.inProgress) {
      return "In progress";
    }

    return "${formatTime(_session.startTimestamp)} - "
           "${formatTime(_session.startTimestamp)}";
  }
}