import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/widgets/edit_page.dart';
import 'package:mobile/pages/edit_session_page.dart';
import 'package:mobile/pages/sessions_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/session_list_tile.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class EditActivityPage extends StatefulWidget {
  final AppManager _app;
  final Activity _editingActivity;

  EditActivityPage(this._app, [this._editingActivity]);

  @override
  _EditActivityPageState createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _recentSessionLimit = 3;

  AppManager get _app => widget._app;
  Activity get _editingActivity => widget._editingActivity;
  bool get _isEditing => _editingActivity != null;

  TextEditingController _nameController;
  StreamSubscription<List<Session>> _sessionsUpdatedSubscription;
  String _nameValidatorValue;

  @override
  void initState() {
    if (_isEditing) {
      _app.dataManager.getSessionsUpdatedStream(_editingActivity.id, (stream) {
        _sessionsUpdatedSubscription = stream.listen((List<Session> sessions) {
          setState(() {});
        });
        return false;
      });
    }

    _nameController = TextEditingController(
      text: _isEditing ? _editingActivity.name : null
    );

    super.initState();
  }

  @override
  void dispose() {
    if (_sessionsUpdatedSubscription != null) {
      _sessionsUpdatedSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditPage(
      title: _isEditing
          ? Strings.of(context).editActivityPageEditTitle
          : Strings.of(context).editActivityPageNewTitle,
      padding: insetsVerticalSmall,
      onSave: () => _onPressedSaveButton(),
      onDelete: () => _app.dataManager.removeActivity(_editingActivity.id),
      deleteDescription: _isEditing ? format(
          Strings.of(context).editActivityPageDeleteMessage,
          [_editingActivity.name]) : null,
      isEditingCallback: () => _isEditing,
      form: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: paddingDefault,
                right: paddingDefault,
                bottom: paddingDefault,
              ),
              child: TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: Strings.of(context).editActivityPageNameLabel,
                ),
                validator: (String value) => _nameValidatorValue,
              ),
            ),
            _isEditing ? _getRecentSessions() : Empty(),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<Session>> _getRecentSessions() {
    return FutureBuilder<List<Session>>(
      future: _app.dataManager
          .getRecentSessions(_editingActivity.id, _recentSessionLimit),
      builder: (BuildContext context, AsyncSnapshot<List<Session>> snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return Empty();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getRecentSessionsTitle(),
          ]
          ..addAll(snapshot.data.isNotEmpty ? snapshot.data.map((session) {
            return SessionListTile(
              app: _app,
              session: session,
              hasDivider: session != snapshot.data.last,
              onTap: (Session session) {
                push(context, EditSessionPage(
                  app: _app,
                  activity: _editingActivity,
                  editingSession: session,
                ));
              },
            );
          }) : [Empty()])
          ..add(snapshot.data.isNotEmpty
              ? _getViewAllButton() : Empty())
        );
      }
    );
  }

  Widget _getRecentSessionsTitle() {
    return Padding(
      padding: insetsLeftDefault,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BoldText(Strings.of(context).editActivityPageRecentSessions),
          IconButton(
            icon: Icon(Icons.add),
            padding: insetsZero,
            onPressed: () {
              push(
                context,
                EditSessionPage(
                  app: _app,
                  activity: _editingActivity
                ),
                fullscreenDialog: true
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getViewAllButton() {
    return FutureBuilder<int>(
      future: _app.dataManager.getSessionCount(_editingActivity.id),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data <= _recentSessionLimit)
        {
          return Empty();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              padding: insetsHorizontalDefault,
              onPressed: () {
                push(context, SessionsPage(_app, _editingActivity));
              },
              child: Text(
                Strings.of(context).editActivityPageMoreSessions.toUpperCase()
              ),
            ),
          ],
        );
      }
    );
  }

  void _onPressedSaveButton() {
    // Remove any trailing or leading spaces entered by the user.
    String nameCandidate = _nameController.text.trim();

    _validateNameField(nameCandidate, (String validationText) {
      _nameValidatorValue = validationText;

      if (!_formKey.currentState.validate()) {
        return;
      }

      if (_isEditing) {
        var builder = ActivityBuilder.fromActivity(_editingActivity)
            ..name = nameCandidate;
        _app.dataManager.updateActivity(builder.build);
      } else {
        _app.dataManager.addActivity(ActivityBuilder(nameCandidate).build);
      }

      Navigator.pop(context);
    });
  }

  void _validateNameField(String name, Function(String) onFinish) {
    // The name hasn't changed, and therefore is still valid.
    if (_isEditing &&
        isEqualTrimmedLowercase(_editingActivity.name, name))
    {
      onFinish(null);
      return;
    }

    if (name.trim().isEmpty) {
      onFinish(Strings.of(context).editActivityPageMissingName);
      return;
    }

    _app.dataManager.activityNameExists(name).then((bool exists) {
      onFinish(exists ? Strings.of(context).editActivityPageNameExists : null);
    });
  }
}
