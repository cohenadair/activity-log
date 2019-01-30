import 'package:flutter/material.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';

class SessionListTile extends StatelessWidget {
  final Session _session;
  final bool _hasDivider;

  SessionListTile(this._session, {bool hasDivider}) : _hasDivider = hasDivider;

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
              print("Delete session");
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