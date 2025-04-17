import 'dart:async';
import 'dart:io';

import 'package:adair_flutter_lib/pages/pro_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:adair_flutter_lib/utils/dialog.dart';
import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/widgets/empty.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/database/backup.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/strings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker.dart';
import 'package:mobile/widgets/my_page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/duration.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage();

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
    return MyPage(
      appBarStyle: MyPageAppBarStyle(
        title: Strings.of(context).settingsPageTitle,
      ),
      child: ListView(
        children: <Widget>[
          _buildHeading(Strings.of(context).settingsPageHeadingSupportUs),
          _buildPro(),
          MinDivider(),
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
      child: SafeArea(child: HeadingText(title)),
    );
  }

  Widget _buildPro() {
    return ListItem(
      title: Text(Strings.of(context).settingsPagePro),
      onTap: () => present(context, ProPage(features: [])),
    );
  }

  Widget _buildLargestDurationPicker() {
    return LargestDurationBuilder(
      builder: (BuildContext context, AppDurationUnit durationUnit) {
        return ListPicker<AppDurationUnit>(
          pageTitle: Strings.of(context).settingsPageLargestDurationLabel,
          initialValues: {durationUnit},
          showsValueOnTrailing: true,
          onChanged: (selectedValues) {
            PreferencesManager.get.setLargestDurationUnit(
              selectedValues.first,
            );
          },
          titleBuilder: (_) =>
              Text(Strings.of(context).settingsPageLargestDurationLabel),
          items: [
            ListPickerItem<AppDurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationDays,
              subtitle: _getLargestDurationUnitSubtitle(AppDurationUnit.days),
              value: AppDurationUnit.days,
            ),
            ListPickerItem<AppDurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationHours,
              subtitle: _getLargestDurationUnitSubtitle(AppDurationUnit.hours),
              value: AppDurationUnit.hours,
            ),
            ListPickerItem<AppDurationUnit>(
              title: Strings.of(context).settingsPageLargestDurationMinutes,
              subtitle: _getLargestDurationUnitSubtitle(
                AppDurationUnit.minutes,
              ),
              value: AppDurationUnit.minutes,
            ),
          ],
        );
      },
    );
  }

  String _getLargestDurationUnitSubtitle(AppDurationUnit unit) {
    return formatDurations(
      largestDurationUnit: toLibDurationUnit(unit),
      context: context,
      durations: [const Duration(days: 3, hours: 15, minutes: 30, seconds: 55)],
    );
  }

  Widget _buildHomeDateRangePicker() {
    return HomeDateRangeBuilder(
      builder: (BuildContext context, DisplayDateRange dateRange) {
        return ListPicker<DisplayDateRange>(
          pageTitle: Strings.of(context).settingsPageHomeDateRangeLabel,
          initialValues: {dateRange},
          showsValueOnTrailing: true,
          onChanged: (selectedValues) {
            PreferencesManager.get.setHomeDateRange(
              selectedValues.first,
            );
          },
          titleBuilder: (_) =>
              Text(Strings.of(context).settingsPageHomeDateRangeLabel),
          listHeader: Text(
            Strings.of(context).settingsPageHomeDateRangeDescription,
          ),
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
    DisplayDateRange dateRange,
  ) {
    return ListPickerItem<DisplayDateRange>(
      title: dateRange.onTitle(context),
      value: dateRange,
    );
  }

  Widget _buildContact() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageContactLabel),
      trailing: const RightChevronIcon(),
      onTap: () => push(context, FeedbackPage()),
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
          showErrorDialog(context: context, description: errorMessage);
        }
      },
    );
  }

  Widget _buildAbout() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageVersion),
      trailing: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (_, snap) => snap.hasData
            ? SecondaryText("${snap.data!.version} (${snap.data!.buildNumber})")
            : const Empty(),
      ),
    );
  }

  Widget _buildPrivacy() {
    return ListItem(
      title: Text(Strings.of(context).settingsPagePrivacyPolicy),
      onTap: () => launchUrl(
        Uri.parse(_privacyUrl),
        mode: LaunchMode.externalApplication,
      ),
    );
  }

  Widget _buildExport() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageExportLabel),
      subtitle: Text(Strings.of(context).settingsPageExportDescription),
      trailing: _isCreatingBackup ? const Loading.listItem() : const Empty(),
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
      trailing: _isImporting ? const Loading.listItem() : const Empty(),
      onTap: _startImport,
    );
  }

  void _startExport(RenderBox renderBox) async {
    // Save backup file to sandbox cache. It'll be small and it'll be overridden
    // by subsequent backups, so let the system handle deletion.
    var tempDir = await getTemporaryDirectory();
    var path = "${tempDir.path}/$_backupFileName";
    var backupFile = File(path);
    backupFile.writeAsStringSync(await export());

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
      _log.e(e.toString());
    }

    if (result == null || result.files.isEmpty) {
      return;
    }

    if (context.mounted) {
      showWarningDialog(
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
      showErrorDialog(
        context: context,
        description: Strings.of(context).settingsPageImportBadFile,
      );
    }

    if (jsonString != null) {
      ImportResult result = await import(json: jsonString);

      if (context.mounted) {
        if (result == ImportResult.success) {
          showOkDialog(
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
        content: Text(Strings.of(context).settingsPageImportFailed),
        actions: <Widget>[
          DialogButton(
            label: Strings.of(context).settingsPageImportSendLogs,
            onTap: () async {
              await _sendEmail(
                subject: "Activity Log Import Error",
                body: result.toString(),
                attachmentPath: importFile.path,
              );
            },
          ),
          DialogButton(label: Strings.of(context).done),
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
      await FlutterEmailSender.send(
        Email(
          subject: "$subject ($osName)",
          body: body ?? "",
          recipients: [_supportEmail],
          attachmentPaths: isEmpty(attachmentPath) ? [] : [attachmentPath!],
        ),
      );
    } on PlatformException {
      showErrorDialog(
        context: context,
        description: Strings.of(context).settingsPageFailedEmailMessage,
      );
    }
  }
}
