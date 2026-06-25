import 'dart:io';
import 'dart:isolate';

import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:intl/intl.dart';
import 'package:mobile/database/data_manager.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

const _xlsxFileName = "ActivityLogExport.xlsx";
const _maxFileNameLength = 31;
const _headerRow = 1;
const _dataRowStart = 2;

// Syncfusion adds extra blank columns beyond the data. Delete them
// right-to-left so indices stay stable. Activity sheets have 3 data columns;
// summary has 4.
const _activitySheetFirstExtraColumn = 4;
const _summarySheetFirstExtraColumn = 5;

final _dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

typedef _XlsxSession = ({
  String startTime,
  String? endTime,
  int millisecondsDuration,
});

typedef _XlsxActivity = ({
  String name,
  bool isArchived,
  bool isHiddenFromStats,
  List<_XlsxSession> sessions,
});

Future<List<_XlsxActivity>> _fetchXlsxData() async {
  final activities = await DataManager.get.activities;
  final result = <_XlsxActivity>[];

  for (final activity in activities) {
    final sessions = await DataManager.get.getSessions(activity.id);

    result.add((
      name: activity.name,
      isArchived: activity.isArchived,
      isHiddenFromStats: activity.isHiddenFromStats,
      sessions: sessions
          .map(
            (s) => (
              startTime: _dateFormat.format(s.startDateTime),
              endTime: s.endDateTime == null
                  ? null
                  : _dateFormat.format(s.endDateTime!),
              millisecondsDuration: s.millisecondsDuration,
            ),
          )
          .toList(),
    ));
  }

  return result;
}

List<int> _buildXlsx(List<_XlsxActivity> data) {
  final workbook = Workbook();

  final summarySheet = workbook.worksheets[0];
  summarySheet.name = "Activities";

  // Note that the English strings are hardcoded here because this code is run
  // in an Isolate. Should the app ever be translated, these values will need
  // to be passed in from the call site.
  _writeRow(summarySheet, _headerRow, [
    "Name",
    "Total Sessions",
    "Is Archived",
    "Is Hidden From Stats",
  ]);

  for (var i = 0; i < data.length; i++) {
    final activity = data[i];
    _writeRow(summarySheet, _dataRowStart + i, [
      activity.name,
      activity.sessions.length,
      activity.isArchived,
      activity.isHiddenFromStats,
    ]);

    final activitySheet = workbook.worksheets.addWithName(
      _sanitizeSheetName(activity.name),
    );
    _writeRow(activitySheet, _headerRow, [
      "Start Time",
      "End Time",
      "Duration",
    ]);

    for (var j = 0; j < activity.sessions.length; j++) {
      final s = activity.sessions[j];
      _writeRow(activitySheet, _dataRowStart + j, [
        s.startTime,
        s.endTime,
        DisplayDuration(
          Duration(milliseconds: s.millisecondsDuration),
          includesYears: false,
          includesDays: false,
        ).formatHoursMinutesSeconds(),
      ]);
    }

    // Remove extra columns Syncfusion adds by default (right to left).
    activitySheet.deleteColumn(_activitySheetFirstExtraColumn + 1);
    activitySheet.deleteColumn(_activitySheetFirstExtraColumn);
  }

  // Remove the extra column Syncfusion adds by default.
  summarySheet.deleteColumn(_summarySheetFirstExtraColumn);

  final bytes = workbook.saveAsStream();
  workbook.dispose();
  return bytes;
}

Future<String> exportXlsx() async {
  final data = await _fetchXlsxData();
  final tempPath = await PathProviderWrapper.get.temporaryPath;
  final path = "$tempPath/$_xlsxFileName";

  await Isolate.run(() async {
    await File(path).writeAsBytes(_buildXlsx(data), flush: true);
  });

  return path;
}

void _writeRow(Worksheet sheet, int row, List<Object?> values) {
  for (var col = 0; col < values.length; col++) {
    final cell = sheet.getRangeByIndex(row, col + 1);
    final value = values[col];

    if (value == null) {
      cell.setText("");
    } else if (value is int) {
      cell.setNumber(value.toDouble());
    } else if (value is bool) {
      cell.setText(value ? "Yes" : "No");
    } else {
      cell.setText(value.toString());
    }
  }
}

String _sanitizeSheetName(String name) {
  // Excel sheet names cannot exceed _maxFileNameLength chars or
  // contain: \ / ? * [ ]
  final sanitized = name.replaceAll(RegExp(r'[\\/?*\[\]]'), "_");
  return sanitized.length > _maxFileNameLength
      ? sanitized.substring(0, _maxFileNameLength)
      : sanitized;
}
