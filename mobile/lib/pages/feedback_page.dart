import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/managers/properties_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/dialog.dart';
import 'package:adair_flutter_lib/utils/io.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/string.dart';
import 'package:adair_flutter_lib/utils/widget.dart';
import 'package:adair_flutter_lib/widgets/empty.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:adair_flutter_lib/widgets/vertical_space.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/device_info_wrapper.dart';
import 'package:mobile/http_wrapper.dart';
import 'package:mobile/package_info_wrapper.dart';
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
  static const _urlSendGrid = "https://api.sendgrid.com/v3/mail/send";

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
              const VerticalSpace(paddingDefault),
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
              const VerticalSpace(paddingDefault),
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
                autofocus: isNotEmpty(_nameController.text) &&
                    isNotEmpty(_emailController.text),
              ),
              const VerticalSpace(paddingDefault),
              _showSendError
                  ? ErrorText(
                      format(Strings.of(context).feedbackPageErrorSending, [
                        PropertiesManager.get.supportEmail,
                      ]),
                    )
                  : const Empty(),
            ],
          ),
        ),
      ),
    );
  }

  void _send() async {
    // Check for valid input.
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(
        context,
        Strings.of(context).feedbackPageRequiredFields,
      );
      return;
    }

    // Check internet connection.
    if (!await isConnected()) {
      safeUseContext(
        this,
        () => showErrorSnackBar(
          context,
          Strings.of(context).feedbackPageConnectionError,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

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

    var name = _nameController.text;
    var email = _emailController.text;
    var message = _messageController.text;

    // API data, per https://sendgrid.com/docs/api-reference/.
    var body = <String, dynamic>{
      "personalizations": [
        {
          "to": [
            {"email": PropertiesManager.get.supportEmail},
          ],
        },
      ],
      "from": {
        "name":
            "Activity Log ${IoWrapper.get.isAndroid ? "Android" : "iOS"} App",
        "email": PropertiesManager.get.clientSenderEmail,
      },
      "reply_to": {"email": email, "name": name},
      "subject": "User Feedback",
      "content": [
        {
          "type": "text/plain",
          "value": format(PropertiesManager.get.feedbackTemplate, [
            appVersion,
            isNotEmpty(osVersion) ? osVersion : "Unknown",
            isNotEmpty(deviceModel) ? deviceModel : "Unknown",
            isNotEmpty(deviceId) ? deviceId : "Unknown",
            isNotEmpty(name) ? name : "Unknown",
            email,
            message,
          ]),
        },
      ],
    };

    var response = await HttpWrapper.get.post(
      Uri.parse(_urlSendGrid),
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": "Bearer ${PropertiesManager.get.sendGridApiKey}",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != HttpStatus.accepted) {
      _log.e("Error sending feedback: ${response.statusCode}");

      setState(() {
        _isSending = false;
        _showSendError = true;
      });

      return;
    }

    PreferencesManager.get
        .setUserInfo(_nameController.text, _emailController.text);
    setState(() {
      _isSending = false;
      _showSendError = false;
    });

    // Confirm feedback has been sent.
    safeUseContext(
      this,
      () => showOkDialog(
        context: context,
        description: Strings.of(context).feedbackPageConfirmation,
        onTapOk: () => Navigator.of(context).pop(),
      ),
    );
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
