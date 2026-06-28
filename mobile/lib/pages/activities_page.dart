import 'package:adair_flutter_lib/res/anim.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/pages/edit_activity_page.dart';
import 'package:mobile/preferences_manager.dart';
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
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: PreferencesManager.get.activitySortOptionStream,
      builder: (context, _) {
        return ActivityListModelBuilder(
          builder: (BuildContext context, List<ActivityListTileModel> models) {
            final active = _sort(
              models.where((m) => !m.activity.isArchived).toList(),
            );
            final archived = _sort(
              models.where((m) => m.activity.isArchived).toList(),
            );

            return MyPage(
              appBarStyle: MyPageAppBarStyle(
                title: Strings.of(context).activitiesPageTitle,
                showLeadingProButton: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => present(context, const EditActivityPage()),
                  ),
                  _buildSortButton(context),
                ],
              ),
              child: _buildList(context, active, archived),
            );
          },
        );
      },
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final current = PreferencesManager.get.activitySortOption;
    final strings = Strings.of(context);

    PopupMenuItem<ActivitySortOption> menuItem(
      ActivitySortOption option,
      String label,
    ) {
      return PopupMenuItem<ActivitySortOption>(
        value: option,
        child: Row(
          children: [
            Expanded(child: Text(label)),
            if (current == option) Icon(Icons.check, color: context.colorApp),
          ],
        ),
      );
    }

    return PopupMenuButton<ActivitySortOption>(
      icon: const Icon(Icons.more_vert),
      onSelected: (option) =>
          PreferencesManager.get.setActivitySortOption(option),
      itemBuilder: (context) => <PopupMenuEntry<ActivitySortOption>>[
        PopupMenuItem<ActivitySortOption>(
          enabled: false,
          child: HeadingText(strings.activitiesPageSortBy),
        ),
        menuItem(.totalTime, strings.activitiesPageSortTotalTime),
        menuItem(
          .mostRecentSession,
          strings.activitiesPageSortMostRecentSession,
        ),
        menuItem(.creationDate, strings.activitiesPageSortCreationDate),
        menuItem(.alphabetical, strings.activitiesPageSortAlphabetical),
      ],
    );
  }

  List<ActivityListTileModel> _sort(List<ActivityListTileModel> models) {
    final sorted = List<ActivityListTileModel>.from(models);

    switch (PreferencesManager.get.activitySortOption) {
      case .totalTime:
        sorted.sort(
          (a, b) => (b.duration?.inMilliseconds ?? -1).compareTo(
            a.duration?.inMilliseconds ?? -1,
          ),
        );
      case .mostRecentSession:
        sorted.sort(
          (a, b) => (b.mostRecentSessionTimestamp ?? -1).compareTo(
            a.mostRecentSessionTimestamp ?? -1,
          ),
        );
      case .creationDate:
        sorted.sort(
          (a, b) => b.activity.createdAt.compareTo(a.activity.createdAt),
        );
      case .alphabetical:
        sorted.sort((a, b) => a.activity.name.compareTo(b.activity.name));
    }

    return sorted;
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
      controller: _scrollController,
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

  Future<void> _startSession(Activity activity) async {
    await DataManager.get.startSession(context, activity);

    if (!mounted) {
      return;
    }

    setState(() {});

    // When sorted by most recent sessions, starting a new one causes the
    // activity to go to the top of the list. Make sure we scroll to it, so
    // users know the session actually started.
    if (PreferencesManager.get.activitySortOption == .mostRecentSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: animDurationDefault,
          curve: Curves.easeOut,
        );
      });
    }
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
