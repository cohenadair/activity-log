import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/sqlite_data_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/widgets/activity_list_tile.dart';
import 'package:mobile/widgets/list_page.dart';
import 'package:mobile/widgets/widget.dart';

class ActivitiesPage extends StatefulWidget {
  final AppManager app;

  const ActivitiesPage(this.app);

  @override
  ActivitiesPageState createState() => ActivitiesPageState();
}

class ActivitiesPageState extends State<ActivitiesPage> {
  @override
  Widget build(BuildContext context) {
    return ActivityListModelBuilder(
      app: widget.app,
      builder: (BuildContext context, List<ActivityListTileModel> models) {
        return ListPage<ActivityListTileModel>(
          items: models,
          empty: EmptyPageHelp(
            icon: Icons.home,
            message: Strings.of(context).activitiesPageNoActivitiesMessage,
          ),
          title: Strings.of(context).activitiesPageTitle,
          getEditPageCallback: (ActivityListTileModel? model) {
            return EditActivityPage(
              widget.app,
              model?.activity,
            );
          },
          buildTileCallback: (ActivityListTileModel model, onTapTile) {
            return ActivityListTile(
              app: widget.app,
              model: model,
              onTap: (_) => onTapTile(model),
              onTapStartSession: () => _startSession(model.activity),
              onTapEndSession: () => _endSession(model.activity),
            );
          },
        );
      },
    );
  }

  void _startSession(Activity activity) {
    widget.app.dataManager.startSession(activity).then((_) => _update());
  }

  void _endSession(Activity activity) {
    widget.app.dataManager.endSession(activity).then((_) => _update());
  }

  void _update() {
    setState(() {});
  }
}
