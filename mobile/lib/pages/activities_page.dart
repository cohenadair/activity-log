import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/widgets/list_page.dart';
import 'package:mobile/widgets/activity_list_tile.dart';

class ActivitiesPage extends StatefulWidget {
  final AppManager app;

  ActivitiesPage(this.app);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  StreamSubscription<List<Activity>> _onActivitiesUpdated;
  StreamController<List<ActivityListTileModel>> _modelUpdatedController;

  @override
  void initState() {
    _modelUpdatedController = StreamController.broadcast();

    widget.app.dataManager.getActivitiesUpdateStream((stream) {
      _onActivitiesUpdated = stream.listen((_) async {
        _updateModel();
      });

      return true;
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _onActivitiesUpdated.cancel();
    _modelUpdatedController.close();
  }

  @override
  Widget build(BuildContext context) {
    return ListPage<ActivityListTileModel>(
      title: Strings.of(context).activitiesPageTitle,
      onGetEditPageCallback: (ActivityListTileModel model) {
        return EditActivityPage(widget.app, model.activity);
      },
      onBuildTileCallback: (ActivityListTileModel model, onTapTile) {
        return ActivityListTile(
          model: model,
          onTap: (Activity activity) {
            onTapTile(model);
          },
          onTapStartSession: () {
            widget.app.dataManager.startSession(model.activity).then((_) {
              _updateModel();
            });
          },
          onTapEndSession: () {
            widget.app.dataManager.endSession(model.activity).then((_) {
              _updateModel();
            });
          },
        );
      },
      stream: _modelUpdatedController.stream,
    );
  }

  void _updateModel() {
    setState(() {
      widget.app.dataManager.getActivityListModel()
          .then((model) => _modelUpdatedController.add(model));
    });
  }
}
