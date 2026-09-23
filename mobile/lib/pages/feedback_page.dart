import 'package:adair_flutter_lib/l10n/gen/adair_flutter_lib_localizations.dart';
import 'package:adair_flutter_lib/managers/email_manager.dart';
import 'package:adair_flutter_lib/managers/properties_manager.dart';
import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/dialog.dart';
import 'package:adair_flutter_lib/utils/io.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:adair_flutter_lib/utils/string.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:adair_flutter_lib/wrappers/device_info_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/package_info_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/my_page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage();

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const _maxLengthName = 40;
  static const _maxLengthEmail = 320;
  static const _maxLengthMessage = 500;

  final _log = const Log("FeedbackPage");
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var _isSending = false;
  var _showSendError = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = PreferencesManager.get.userName ?? "";
    _emailController.text = PreferencesManager.get.userEmail ?? "";
  }

  @override
  Widget build(BuildContext context) {
    Widget action = Loading.appBar();
    if (!_isSending) {
      action = ActionButton(
        text: Strings.of(context).feedbackPageSend,
        onPressed: _isSending ? null : _send,
      );
    }

    return MyPage(
      appBarStyle: MyPageAppBarStyle(
        title: Strings.of(context).feedbackPageTitle,
        actions: <Widget>[action],
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: insetsDefault,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: _maxLengthName,
                decoration: InputDecoration(
                  label: Text(Strings.of(context).feedbackPageName),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: isEmpty(_nameController.text),
                textInputAction: TextInputAction.next,
              ),
              Container(height: paddingDefault),
              TextFormField(
                controller: _emailController,
                maxLength: _maxLengthEmail,
                decoration: InputDecoration(
                  label: Text(Strings.of(context).feedbackPageEmail),
                ),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.always,
                validator: _validateEmail,
                textInputAction: TextInputAction.next,
              ),
              Container(height: paddingDefault),
              TextFormField(
                controller: _messageController,
                maxLength: _maxLengthMessage,
                decoration: InputDecoration(
                  label: Text(Strings.of(context).feedbackPageMessage),
                ),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                autovalidateMode: AutovalidateMode.always,
                validator: (value) => isEmpty(value)
                    ? Strings.of(context).feedbackPageRequired
                    : null,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _send(),
                autofocus:
                    isNotEmpty(_nameController.text) &&
                    isNotEmpty(_emailController.text),
              ),
              Container(height: paddingDefault),
              _showSendError
                  ? ErrorText(
                      format(Strings.of(context).feedbackPageErrorSending, [
                        PropertiesManager.get.supportEmail,
                      ]),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  void _send() async {
    if (_isSending) {
      return;
    }

    // Check for valid input.
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(
        context,
        Strings.of(context).feedbackPageRequiredFields,
      );
      return;
    }

    setState(() {
      _isSending = true;
      _showSendError = false;
    });

    // Check internet connection.
    if (!await isConnected()) {
      if (!mounted) {
        return;
      }

      setState(() => _isSending = false);
      showErrorSnackBar(
        context,
        Strings.of(context).feedbackPageConnectionError,
      );
      return;
    }

    // Gather app and device info.
    var appVersion = (await PackageInfoWrapper.get.fromPlatform()).version;
    String? osVersion;
    String? deviceModel;
    String? deviceId;

    if (IoWrapper.get.isIOS) {
      var info = await DeviceInfoWrapper.get.iosInfo;
      osVersion = "${info.systemName} (${info.systemVersion})";
      deviceModel = info.utsname.machine;
      deviceId = info.identifierForVendor;
    } else if (IoWrapper.get.isAndroid) {
      var info = await DeviceInfoWrapper.get.androidInfo;
      osVersion = "Android (${info.version.sdkInt})";
      deviceModel = info.model;
      deviceId = info.id;
    }

    var revenueCatId = "";
    try {
      revenueCatId = await SubscriptionManager.get.userId;
    } catch (e) {
      _log.e(e, reason: "Getting RevenueCat customer ID for feedback");
    }

    var name = _nameController.text;
    var email = _emailController.text;
    var message = _messageController.text;

    var text = format(PropertiesManager.get.feedbackTemplate, [
      appVersion,
      isNotEmpty(osVersion) ? osVersion : "Unknown",
      isNotEmpty(deviceModel) ? deviceModel : "Unknown",
      isNotEmpty(deviceId) ? deviceId : "Unknown",
      isNotEmpty(revenueCatId) ? revenueCatId : "Unknown",
      isNotEmpty(name) ? name : "Unknown",
      email,
      message,
    ]);

    var result = await EmailManager.get.send(
      appName: "Activity Log",
      replyToEmail: email,
      replyToName: name,
      subject: "User Feedback",
      text: text,
      userMessage: message,
    );

    if (result == EmailSendResult.failed) {
      _log.e(
        Exception("Error sending feedback"),
        reason: "Sending in-app feedback",
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = false;
      _showSendError = result == EmailSendResult.failed;
    });

    switch (result) {
      case EmailSendResult.failed:
        return;
      case EmailSendResult.rateLimited:
        showOkDialog(
          context: context,
          title: AdairFlutterLibLocalizations.of(context).emailRateLimitedTitle,
          description: Text(
            AdairFlutterLibLocalizations.of(context).emailRateLimitedMessage,
          ),
        );
        return;
      case EmailSendResult.sent:
        PreferencesManager.get.setUserInfo(
          _nameController.text,
          _emailController.text,
        );

        // Confirm feedback has been sent.
        showOkDialog(
          context: context,
          description: Text(Strings.of(context).feedbackPageConfirmation),
          onTapOk: () => Navigator.of(context).pop(),
        );
    }
  }

  String? _validateEmail(String? email) {
    if (isEmpty(email)) {
      return Strings.of(context).feedbackPageRequired;
    }

    if (!RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\])|(([a-zA-Z\-\d]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(email!)) {
      return Strings.of(context).feedbackPageInvalidEmail;
    }

    return null;
  }
}
