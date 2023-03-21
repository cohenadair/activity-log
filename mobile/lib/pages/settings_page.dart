import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/database/backup.dart';
import 'package:mobile/res/style.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/strings.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:mobile/widgets/page.dart' as p;
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../log.dart';

class SettingsPage extends StatefulWidget {
  final AppManager app;

  const SettingsPage(this.app);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  static const _supportEmail = "cohenadair@gmail.com";
  static const _rateAppStoreUrl =
      "itms-apps://itunes.apple.com/app/id1458926666?action=write-review";
  static const _playStoreUrl = "market://details?id=com.cohenadair.activitylog";
  static const _privacyUrl =
      "https://cohenadair.github.io/activity-log/privacy_policy.html";
  static const _backupFileExtension = "dat";
  static const _backupFileName = "ActivityLogBackup.$_backupFileExtension";

  static const _log = Log("SettingsPage");

  bool _isCreatingBackup = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return p.Page(
      appBarStyle: p.PageAppBarStyle(
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
          _buildPrivacy(),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(
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
          initialValues: {durationUnit},
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
      },
    );
  }

  String _getLargestDurationUnitSubtitle(DurationUnit unit) {
    return formatTotalDuration(
      largestDurationUnit: unit,
      context: context,
      durations: [
        const Duration(days: 3, hours: 15, minutes: 30, seconds: 55),
      ],
    );
  }

  Widget _buildHomeDateRangePicker() {
    return HomeDateRangeBuilder(
      app: widget.app,
      builder: (BuildContext context, DisplayDateRange dateRange) {
        return ListPicker<DisplayDateRange>(
          pageTitle: Strings.of(context).settingsPageHomeDateRangeLabel,
          initialValues: {dateRange},
          showsValueOnTrailing: true,
          onChanged: (selectedValues) {
            widget.app.preferencesManager
                .setHomeDateRange(selectedValues.first);
          },
          titleBuilder: (_) =>
              Text(Strings.of(context).settingsPageHomeDateRangeLabel),
          listHeader:
              Text(Strings.of(context).settingsPageHomeDateRangeDescription),
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
      },
    );
  }

  ListPickerItem<DisplayDateRange> _buildDisplayDateRangeItem(
      DisplayDateRange dateRange) {
    return ListPickerItem<DisplayDateRange>(
      title: dateRange.getTitle(context),
      value: dateRange,
    );
  }

  Widget _buildContact() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageContactLabel),
      onTap: () async {
        await _sendEmail(subject: "Support Message From Activity Log");
      },
    );
  }

  Widget _buildRate() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageRateLabel),
      onTap: () async {
        String url;
        String errorMessage;

        if (Platform.isAndroid) {
          url = _playStoreUrl;
          errorMessage =
              Strings.of(context).settingsPageAndroidErrorRateMessage;
        } else {
          url = _rateAppStoreUrl;
          errorMessage = Strings.of(context).settingsPageIosErrorRateMessage;
        }

        if (await canLaunchUrlString(url)) {
          await launchUrlString(url);
        } else if (context.mounted) {
          showError(context: context, description: errorMessage);
        }
      },
    );
  }

  Widget _buildAbout() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageVersion),
      trailing: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
          if (snapshot.hasData) {
            return SecondaryText(
                "${snapshot.data!.version} (${snapshot.data!.buildNumber})");
          } else {
            return const Loading();
          }
        },
      ),
    );
  }

  Widget _buildPrivacy() {
    return ListItem(
      title: Text(Strings.of(context).settingsPagePrivacyPolicy),
      onTap: () => launchUrlString(_privacyUrl),
    );
  }

  Widget _buildExport() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageExportLabel),
      subtitle: Text(Strings.of(context).settingsPageExportDescription),
      trailing: _isCreatingBackup ? const Loading() : Empty(),
      onTap: () {
        setState(() => _isCreatingBackup = true);
        _startExport(context.findRenderObject() as RenderBox);
      },
    );
  }

  Widget _buildImport() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageImportLabel),
      subtitle: Text(Strings.of(context).settingsPageImportDescription),
      trailing: _isImporting ? const Loading() : Empty(),
      onTap: _startImport,
    );
  }

  void _startExport(RenderBox renderBox) async {
    // Save backup file to sandbox cache. It'll be small and it'll be overridden
    // by subsequent backups, so let the system handle deletion.
    var tempDir = await getTemporaryDirectory();
    var path = "${tempDir.path}/$_backupFileName";
    var backupFile = File(path);
    backupFile.writeAsStringSync(await export(widget.app));

    await Share.shareXFiles(
      [XFile(path, mimeType: "text/plain")],
      sharePositionOrigin:
          renderBox.localToGlobal(Offset.zero) & renderBox.size,
    );

    setState(() {
      _isCreatingBackup = false;
    });
  }

  void _startImport() async {
    FilePickerResult? result;
    try {
      // TODO: Crashes on old Android devices when picking from downloads folder.
      result = await FilePicker.platform.pickFiles(allowMultiple: false);
    } catch (e) {
      _log.e(StackTrace.current, e.toString());
    }

    if (result == null || result.files.isEmpty) {
      return;
    }

    if (context.mounted) {
      showWarning(
        context: context,
        description: Strings.of(context).settingsPageImportWarning,
        onContinue: () {
          setState(() {
            _isImporting = true;
          });

          _import(File(result!.files.first.path!));
        },
      );
    }
  }

  void _import(File file) async {
    String? jsonString;

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

      if (context.mounted) {
        if (result == ImportResult.success) {
          showOk(
            context: context,
            description: Strings.of(context).settingsPageImportSuccess,
          );
        } else {
          _showImportError(result, file);
        }
      }
    }

    setState(() => _isImporting = false);
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
                body: result.toString(),
                attachmentPath: importFile.path,
              );
            },
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
    required String subject,
    String? body,
    String? attachmentPath,
  }) async {
    try {
      String osName = Platform.isAndroid ? "Android" : "iOS";
      await FlutterEmailSender.send(Email(
        subject: "$subject ($osName)",
        body: body ?? "",
        recipients: [_supportEmail],
        attachmentPaths: isEmpty(attachmentPath) ? [] : [attachmentPath!],
      ));
    } on PlatformException {
      showError(
        context: context,
        description: Strings.of(context).settingsPageFailedEmailMessage,
      );
    }
  }
}
