import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/widgets/activity_list_tile.dart';
import 'package:mobile/widgets/my_page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage();

  @override
  ActivitiesPageState createState() => ActivitiesPageState();
}

class ActivitiesPageState extends State<ActivitiesPage> {
  @override
  Widget build(BuildContext context) {
    return ActivityListModelBuilder(
      builder: (BuildContext context, List<ActivityListTileModel> models) {
        final active = models.where((m) => !m.activity.isArchived).toList();
        final archived = models.where((m) => m.activity.isArchived).toList();

        return MyPage(
          appBarStyle: MyPageAppBarStyle(
            title: Strings.of(context).activitiesPageTitle,
            showLeadingProButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => present(context, const EditActivityPage()),
              ),
            ],
          ),
          child: _buildList(context, active, archived),
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    List<ActivityListTileModel> active,
    List<ActivityListTileModel> archived,
  ) {
    if (active.isEmpty && archived.isEmpty) {
      return EmptyPageHelp(
        icon: Icons.home,
        message: Strings.of(context).activitiesPageNoActivitiesMessage,
      );
    }

    return ListView(
      children: [
        ..._buildTilesWithDividers(
          active,
          trailingDivider: archived.isNotEmpty,
        ),
        ..._buildArchivedSection(archived),
      ],
    );
  }

  List<Widget> _buildArchivedSection(List<ActivityListTileModel> archived) {
    if (archived.isEmpty) {
      return const [];
    }

    return [
      Padding(
        padding: insetsDefault,
        child: HeadingText(Strings.of(context).archived),
      ),
      ..._buildTilesWithDividers(archived),
    ];
  }

  List<Widget> _buildTilesWithDividers(
    List<ActivityListTileModel> models, {
    bool trailingDivider = false,
  }) {
    final items = <Widget>[];

    for (var i = 0; i < models.length; i++) {
      items.add(_buildTile(models[i]));
      if (i < models.length - 1 || trailingDivider) {
        items.add(MinDivider());
      }
    }

    return items;
  }

  Widget _buildTile(ActivityListTileModel model) {
    return ActivityListTile(
      model: model,
      onTap: (_) => push(
        context,
        EditActivityPage(model.activity),
        fullscreenDialog: false,
      ),
      onTapStartSession: () => _startSession(model.activity),
      onTapEndSession: () => _endSession(model.activity),
    );
  }

  void _startSession(Activity activity) {
    DataManager.get.startSession(context, activity).then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _endSession(Activity activity) {
    DataManager.get.endSession(activity).then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }
}
