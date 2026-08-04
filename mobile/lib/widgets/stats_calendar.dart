import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/style.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/date_format.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/widgets/month_year_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/session.dart';
import 'package:mobile/model/summarized_activity.dart';
import 'package:mobile/pages/edit_session_page.dart';
import 'package:mobile/utils/activity_color.dart';
import 'package:mobile/widgets/text.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final _log = Log("StatsCalendar");

/// A month-view calendar showing the sessions from [summarizedActivities] —
/// the same, already-filtered data driving the rest of the Stats page.
class StatsCalendar extends StatefulWidget {
  final List<SummarizedActivity> summarizedActivities;

  const StatsCalendar({required this.summarizedActivities});

  @override
  State<StatsCalendar> createState() => _StatsCalendarState();
}

class _StatsCalendarState extends State<StatsCalendar> {
  static const _agendaItemHeight = 50.0;
  static const _agendaRadius = 6.0;

  late final CalendarController _controller;
  late final _SessionDataSource _dataSource;

  @override
  void initState() {
    super.initState();

    _controller = CalendarController()
      ..displayDate = TimeManager.get.currentDateTime
      ..selectedDate = TimeManager.get.currentDateTime;

    _dataSource = _SessionDataSource(_buildEvents());
  }

  @override
  void didUpdateWidget(StatsCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.summarizedActivities == widget.summarizedActivities) {
      return;
    }

    var events = _buildEvents();
    _dataSource.appointments = events;
    _dataSource.notifyListeners(CalendarDataSourceAction.reset, events);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: context.colorApp),
            ),
            child: SfCalendar(
              controller: _controller,
              dataSource: _dataSource,
              view: CalendarView.month,
              headerHeight: 0,
              appointmentBuilder: _buildEvent,
              monthViewSettings: const MonthViewSettings(
                showAgenda: true,
                agendaItemHeight: _agendaItemHeight,
              ),
              onViewChanged: _onViewChanged,
            ),
          ),
        ),
      ],
    );
  }

  // TODO: This header (today/prev/next buttons + month/year picker) is
  // similar to anglers-log's CalendarPage._buildHeader. Consider extracting
  // a shared widget into adair-flutter-lib if a third consumer appears.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _showDatePicker,
            child: Padding(
              padding: insetsLeftDefault,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormats.localized(
                      L10n.get.lib.dateFormatMonthYearFull,
                    ).format(
                      _controller.displayDate ??
                          TimeManager.get.currentDateTime,
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            setState(() {
              _controller.selectedDate = _controller.displayDate =
                  TimeManager.get.currentDateTime;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            _controller.backward?.call();
            setState(() {});
          },
        ),
        // Matches RightChevronIcon's trailing inset (ListTile's default
        // 16dp content padding) instead of IconButton's larger default tap
        // target, so this lines up with the picker rows above it.
        Padding(
          padding: insetsRightDefault,
          child: IconButton(
            icon: const Icon(Icons.chevron_right),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              _controller.forward?.call();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEvent(BuildContext context, CalendarAppointmentDetails details) {
    if (details.appointments.length != 1) {
      _log.d("Invalid appointment count: ${details.appointments.length}");
      return const SizedBox();
    }

    var event = details.appointments.first as _SessionEvent;

    return InkWell(
      onTap: () => push(
        context,
        EditSessionPage(
          activity: event.activity,
          editingSession: event.session,
        ),
      ),
      child: Container(
        padding: insetsSmall,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(_agendaRadius)),
          color: event.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event.activity.name,
              style: const TextStyle(fontWeight: fontWeightBold),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Flexible(
                  child: event.session.inProgress
                      ? Text(
                          Strings.of(context).sessionListInProgress,
                          overflow: TextOverflow.ellipsis,
                        )
                      : TimeRangeText(
                          startTime: event.session.startTimeOfDay,
                          endTime: event.session.endTimeOfDay,
                        ),
                ),
                const Text(" · "),
                TotalDurationText(
                  [event.session.duration],
                  includesDays: false,
                  includesSeconds: false,
                  condensed: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_SessionEvent> _buildEvents() {
    var events = <_SessionEvent>[];
    for (var summarized in widget.summarizedActivities) {
      var color = activityColor(summarized.value);
      for (var session in summarized.sessions) {
        events.add(_SessionEvent(session, summarized.value, color));
      }
    }
    return events;
  }

  void _onViewChanged(ViewChangedDetails details) {
    // SfCalendar invokes this callback synchronously while it's still being
    // built/laid out (e.g. on its initial mount), so setState must be
    // deferred until after the current frame. This only exists to refresh
    // the header's month/year label as the user swipes between months.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _showDatePicker() async {
    var pickedDateTime = await showMonthYearPicker(
      context,
      initialDate: _controller.displayDate,
    );
    if (pickedDateTime == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _controller.selectedDate = _controller.displayDate = pickedDateTime;
    });
  }
}

class _SessionDataSource extends CalendarDataSource {
  _SessionDataSource(List<_SessionEvent> source) {
    appointments = source;
  }

  _SessionEvent _eventAt(int index) => appointments![index] as _SessionEvent;

  @override
  DateTime getStartTime(int index) => _eventAt(index).session.startDateTime;

  @override
  DateTime getEndTime(int index) => _eventAt(index).endDateTime;

  @override
  String getSubject(int index) => _eventAt(index).activity.name;

  @override
  Color getColor(int index) => _eventAt(index).color;

  @override
  bool isAllDay(int index) => false;
}

class _SessionEvent {
  final Session session;
  final Activity activity;
  final Color color;

  _SessionEvent(this.session, this.activity, this.color);

  DateTime get endDateTime =>
      session.endDateTime ?? TimeManager.get.currentDateTime;
}
