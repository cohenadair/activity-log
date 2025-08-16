import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';

import '../database/data_manager.dart';

typedef OnTapSessionListTile = Function(Session);

class SessionListTile extends StatelessWidget {
  final Session _session;
  final bool _hasDivider;
  final OnTapSessionListTile? _onTap;

  const SessionListTile({
    required Session session,
    bool hasDivider = false,
    OnTapSessionListTile? onTap,
  }) : _session = session,
       _hasDivider = hasDivider,
       _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListItem(
          contentPadding: insetsLeftDefault,
          onTap: () {
            _onTap?.call(_session);
          },
          title: DateDurationText(
            _session.startDateTime,
            _session.duration,
            suffix: _session.isBanked
                ? Strings.of(context).sessionListItemBankedAddition
                : "",
          ),
          subtitle: _getSubtitle(context),
          trailing: IconButton(
            color: Colors.red,
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDeleteDialog(
                context: context,
                description: Text(Strings.of(context).sessionListDeleteMessage),
                onDelete: () {
                  DataManager.get.removeSession(_session);
                },
              );
            },
          ),
        ),
        _hasDivider ? const Divider(height: 1) : const SizedBox(),
      ],
    );
  }

  Widget _getSubtitle(BuildContext context) {
    if (_session.inProgress) {
      return Text(Strings.of(context).sessionListInProgress);
    }

    return TimeRangeText(
      startTime: _session.startTimeOfDay,
      endTime: _session.endTimeOfDay,
    );
  }
}
