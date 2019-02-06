import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

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
          title: DateDurationText(_session.startDateTime, _session.duration),
          subtitle: _getSubtitle(context),
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
        _hasDivider ? Divider(height: 1) : MinContainer(),
      ],
    );
  }

  Widget _getSubtitle(BuildContext context) {
    if (_session.inProgress) {
      return Text(Strings.of(context).sessionListInProgress);
    }

    return Row(
      children: <Widget>[
        TimeText(_session.startDateTime),
        Text(" - "),
        TimeText(_session.endDateTime),
      ],
    );
  }
}