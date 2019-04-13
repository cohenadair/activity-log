import 'dart:async';
import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/database/backup.dart';
import 'package:mobile/res/style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker.dart';
import 'package:mobile/widgets/loading.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:package_info/package_info.dart';

class SettingsPage extends StatefulWidget {
  final AppManager app;

  SettingsPage(this.app);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static final _supportEmail = "cohenadair@gmail.com";
  static final _rateAppStoreUrl =
      "itms-apps://itunes.apple.com/app/id1458926666?action=write-review";
  static final _playStoreUrl = "market://details?id=";
  static final _backupFileExtension = "dat";
  static final _backupFileName = "ActivityLogBackup.$_backupFileExtension";

  bool _isCreatingBackup = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).settingsPageTitle,
      ),
      child: ListView(
        children: <Widget>[
          _buildHeading(Strings.of(context).settingsPageHeadingOther),
          _buildLargestDurationPicker(),
          _buildHomeDateRangePicker(),
          MinDivider(),
          _buildHeading(Strings.of(context).settingsPageHeadingBackup),
          _buildExport(),
          _buildImport(),
          MinDivider(),
          _buildHeading(Strings.of(context).settingsPageHeadingHelpAndFeedback),
          _buildContact(),
          _buildRate(),
          MinDivider(),
          _buildHeading(Strings.of(context).settingsPageHeadingAbout),
          _buildAbout(),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: paddingDefault,
        bottom: paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      child: SafeArea(
        child: HeadingText(title),
      ),
    );
  }

  Widget _buildLargestDurationPicker() {
    return LargestDurationBuilder(
      app: widget.app,
      builder: (BuildContext context, DurationUnit durationUnit) {
        return ListPicker<DurationUnit>(
          pageTitle: Strings.of(context).settingsPageLargestDurationLabel,
          initialValues: Set.of([durationUnit]),
          showsValueOnTrailing: true,
          onChanged: (selectedValues) {
            widget.app.preferencesManager
                .setLargestDurationUnit(selectedValues.first);
          },
          titleBuilder: (_) =>
              Text(Strings.of(context).settingsPageLargestDurationLabel),
          items: [
            ListPickerItem<DurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationDays,
              subtitle: _getLargestDurationUnitSubtitle(DurationUnit.days),
              value: DurationUnit.days,
            ),
            ListPickerItem<DurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationHours,
              subtitle: _getLargestDurationUnitSubtitle(DurationUnit.hours),
              value: DurationUnit.hours,
            ),
            ListPickerItem<DurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationMinutes,
              subtitle: _getLargestDurationUnitSubtitle(DurationUnit.minutes),
              value: DurationUnit.minutes,
            ),
          ],
        );
      }
    );
  }

  String _getLargestDurationUnitSubtitle(DurationUnit unit) {
    return formatTotalDuration(
      largestDurationUnit: unit,
      context: context, durations: [
        Duration(days: 3, hours: 15, minutes: 30, seconds: 55),
      ],
    );
  }

  Widget _buildHomeDateRangePicker() {
    return HomeDateRangeBuilder(
      app: widget.app,
      builder: (BuildContext context, DisplayDateRange dateRange) {
        return ListPicker<DisplayDateRange>(
          pageTitle: Strings.of(context).settingsPageHomeDateRangeLabel,
          initialValues: Set.of([dateRange]),
          showsValueOnTrailing: true,
          onChanged: (selectedValues) {
            widget.app.preferencesManager
                .setHomeDateRange(selectedValues.first);
          },
          titleBuilder: (_) => Text(Strings.of(context)
              .settingsPageHomeDateRangeLabel),
          listHeader: Text(Strings.of(context)
              .settingsPageHomeDateRangeDescription),
          items: [
            _buildDisplayDateRangeItem(DisplayDateRange.allDates),
            ListPickerItem.divider(),
            _buildDisplayDateRangeItem(DisplayDateRange.today),
            ListPickerItem.divider(),
            _buildDisplayDateRangeItem(DisplayDateRange.thisWeek),
            _buildDisplayDateRangeItem(DisplayDateRange.thisMonth),
            _buildDisplayDateRangeItem(DisplayDateRange.thisYear),
            ListPickerItem.divider(),
            _buildDisplayDateRangeItem(DisplayDateRange.last7Days),
            _buildDisplayDateRangeItem(DisplayDateRange.last30Days),
            _buildDisplayDateRangeItem(DisplayDateRange.last12Months),
          ],
        );
      }
    );
  }

  ListPickerItem<DisplayDateRange> _buildDisplayDateRangeItem(
      DisplayDateRange dateRange)
  {
    return ListPickerItem<DisplayDateRange>(
      title: dateRange.getTitle(context),
      value: dateRange,
    );
  }

  Widget _buildContact() => ListItem(
    title: Text(Strings.of(context).settingsPageContactLabel),
    onTap: () async {
      await _sendEmail(
        subject: "Support Message From Activity Log"
      );
    },
  );

  Widget _buildRate() => ListItem(
    title: Text(Strings.of(context).settingsPageRateLabel),
    onTap: () async {
      String url;
      String errorMessage;

      if (Platform.isAndroid) {
        url = _playStoreUrl + (await PackageInfo.fromPlatform()).packageName;
        errorMessage = Strings.of(context).settingsPageAndroidErrorRateMessage;
      } else {
        url = _rateAppStoreUrl;
        errorMessage = Strings.of(context).settingsPageIosErrorRateMessage;
      }

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        showError(context: context, description: errorMessage);
      }
    },
  );

  Widget _buildAbout() => ListItem(
    title: Text(Strings.of(context).settingsPageVersion),
    trailing: FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasData) {
          return SecondaryText(snapshot.data.version);
        } else {
          return Loading();
        }
      },
    ),
  );

  Widget _buildExport() => ListItem(
    title: Text(Strings.of(context).settingsPageExportLabel),
    subtitle: Text(Strings.of(context).settingsPageExportDescription),
    trailing: _isCreatingBackup ? Loading() : null,
    onTap: () {
      setState(() {
        _isCreatingBackup = true;
      });

      _startExport();
    },
  );

  Widget _buildImport() => ListItem(
    title: Text(Strings.of(context).settingsPageImportLabel),
    subtitle: Text(Strings.of(context).settingsPageImportDescription),
    trailing: _isImporting ? Loading() : null,
    onTap: _startImport,
  );

  void _startExport() async {
    // Save backup file to sandbox cache. It'll be small and it'll be overridden
    // by subsequent backups, so let the system handle deletion.
    Directory tempDir = await getTemporaryDirectory();
    File backupFile = File("${tempDir.path}/backup.activitylog");
    backupFile.writeAsStringSync(await export(widget.app));
    List<int> bytes = backupFile.readAsBytesSync();
    
    await Share.file(null, _backupFileName, bytes, "text/plain");
    
    setState(() {
      _isCreatingBackup = false;
    });
  }

  void _startImport() async {
    File importFile = await FilePicker.getFile(type: FileType.ANY);
    if (importFile == null) {
      return;
    }

    showWarning(
      context: context,
      description: Strings.of(context).settingsPageImportWarning,
      onContinue: () {
        setState(() {
          _isImporting = true;
        });

        _import(importFile);
      },
    );
  }

  void _import(File file) async {
    String jsonString;

    try {
      // This method will throw an exception for non-text files, such as
      // an image or archive.
      jsonString = file.readAsStringSync();
    } on Exception {
      showError(
        context: context,
        description: Strings.of(context).settingsPageImportBadFile,
      );
    }

    if (jsonString != null) {
      ImportResult result = await import(widget.app, json: jsonString);

      if (result == ImportResult.success) {
        showOk(
          context: context,
          description: Strings.of(context).settingsPageImportSuccess,
        );
      } else {
        _showImportError(result, file);
      }
    }

    setState(() {
      _isImporting = false;
    });
  }

  void _showImportError(ImportResult result, File importFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(Strings.of(context).error),
        titleTextStyle: styleTitleAlert,
        content: Text(Strings.of(context).settingsPageImportFailed),
        actions: <Widget>[
          buildDialogButton(
            context: context,
            name: Strings.of(context).settingsPageImportSendLogs,
            onTap: () async {
              await _sendEmail(
                subject: "Activity Log Import Error",
                body: "${result.toString()}",
                attachmentPath: importFile.path,
              );
            }
          ),
          buildDialogButton(
            context: context,
            name: Strings.of(context).done,
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail({
    String subject,
    String body,
    String attachmentPath,
  }) async {
    try {
      String osName = Platform.isAndroid ? "Android" : "iOS";
      await FlutterEmailSender.send(Email(
        subject: subject + " ($osName)",
        body: body,
        recipients: [_supportEmail],
        attachmentPath: attachmentPath,
      ));
    } on PlatformException {
      showError(
        context: context,
        description: Strings.of(context).settingsPageFailedEmailMessage,
      );
    }
  }
}