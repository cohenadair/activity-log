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
import 'package:mobile/widgets/future_listener.dart';
import 'package:mobile/widgets/session_list_tile.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class EditActivityPage extends StatefulWidget {
  final AppManager app;
  final Activity? editingActivity;

  const EditActivityPage(this.app, [this.editingActivity]);

  @override
  EditActivityPageState createState() => EditActivityPageState();
}

class EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _recentSessionLimit = 3;

  bool get _isEditing => widget.editingActivity != null;

  late TextEditingController _nameController;
  String? _nameValidatorValue;

  @override
  void initState() {
    _nameController = TextEditingController(
        text: _isEditing ? widget.editingActivity!.name : null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EditPage(
      title: _isEditing
          ? Strings.of(context).editActivityPageEditTitle
          : Strings.of(context).editActivityPageNewTitle,
      padding: insetsVerticalSmall,
      onSave: () => _onPressedSaveButton(),
      onDelete: () =>
          widget.app.dataManager.removeActivity(widget.editingActivity!.id),
      deleteDescription: _isEditing
          ? format(Strings.of(context).editActivityPageDeleteMessage,
              [widget.editingActivity!.name])
          : null,
      isEditingCallback: () => _isEditing,
      form: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: paddingDefault,
                right: paddingDefault,
                bottom: paddingDefault,
              ),
              child: TextFormField(
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.words,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: Strings.of(context).editActivityPageNameLabel,
                ),
                validator: (value) => _nameValidatorValue,
              ),
            ),
            _isEditing ? _buildRecentSessions() : Empty(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions() {
    return RecentSessionsBuilder(
      app: widget.app,
      activityId: widget.editingActivity!.id,
      limit: _recentSessionLimit,
      builder: (context, sessions, sessionCount) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecentSessionsTitle(),
            ...sessions.isNotEmpty
                ? sessions.map((session) {
                    return SessionListTile(
                      app: widget.app,
                      session: session,
                      hasDivider: session != sessions.last,
                      onTap: (Session session) {
                        push(
                          context,
                          EditSessionPage(
                            app: widget.app,
                            activity: widget.editingActivity!,
                            editingSession: session,
                          ),
                        );
                      },
                    );
                  })
                : [Empty()],
            sessions.isNotEmpty ? _buildViewAllButton(sessionCount) : Empty()
          ],
        );
      },
    );
  }

  Widget _buildRecentSessionsTitle() {
    return Padding(
      padding: insetsLeftDefault,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          HeadingText(Strings.of(context).editActivityPageRecentSessions),
          IconButton(
            icon: const Icon(Icons.add),
            padding: insetsZero,
            onPressed: () {
              push(
                context,
                EditSessionPage(
                    app: widget.app, activity: widget.editingActivity!),
                fullscreenDialog: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(int sessionCount) {
    return sessionCount <= _recentSessionLimit
        ? Empty()
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: insetsHorizontalDefault,
                child: TextButton(
                  onPressed: () => push(context,
                      SessionsPage(widget.app, widget.editingActivity!)),
                  child: Text(Strings.of(context)
                      .editActivityPageMoreSessions
                      .toUpperCase()),
                ),
              ),
            ],
          );
  }

  void _onPressedSaveButton() {
    // Remove any trailing or leading spaces entered by the user.
    String nameCandidate = _nameController.text.trim();

    _validateNameField(nameCandidate, (String? validationText) {
      _nameValidatorValue = validationText;

      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        return;
      }

      if (_isEditing) {
        var builder = ActivityBuilder.fromActivity(widget.editingActivity!)
          ..name = nameCandidate;
        widget.app.dataManager.updateActivity(builder.build);
      } else {
        widget.app.dataManager
            .addActivity(ActivityBuilder(nameCandidate).build);
      }

      Navigator.pop(context);
    });
  }

  void _validateNameField(String name, Function(String?) onFinish) {
    // The name hasn't changed, and therefore is still valid.
    if (_isEditing &&
        isEqualTrimmedLowercase(widget.editingActivity!.name, name)) {
      onFinish(null);
      return;
    }

    if (name.trim().isEmpty) {
      onFinish(Strings.of(context).editActivityPageMissingName);
      return;
    }

    widget.app.dataManager.activityNameExists(name).then((bool exists) {
      onFinish(exists ? Strings.of(context).editActivityPageNameExists : null);
    });
  }
}

/// A [FutureListener] wrapper for listening for the necessary [Session]
/// updates for a the [EditActivityPage].
class RecentSessionsBuilder extends StatelessWidget {
  final AppManager app;
  final String activityId;
  final int? limit;
  final Widget Function(BuildContext, List<Session>, int) builder;

  const RecentSessionsBuilder({
    required this.app,
    required this.activityId,
    this.limit,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureListener(
      futuresCallbacks: [
        () => app.dataManager.getRecentSessions(activityId, limit),
        () => app.dataManager.getSessionCount(activityId),
      ],
      streams: [app.dataManager.getSessionsUpdatedStream(activityId)],
      builder: (context, values) =>
          builder(context, values?[0] as List<Session>, values?[1] as int),
    );
  }
}
