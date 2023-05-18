import 'package:flutter/services.dart' show rootBundle;

import 'utils/properties_file.dart';

/// A class for accessing data in configuration files.
class PropertiesManager {
  final String _keyClientSenderEmail = "clientSender.email";
  final String _keySupportEmail = "support.email";
  final String _keySendGridApiKey = "sendGrid.apikey";

  final String _path = "assets/sensitive.properties";
  final String _feedbackTemplatePath = "assets/feedback_template";

  late PropertiesFile _properties;
  late String _feedbackTemplate;

  Future<void> initialize() async {
    _properties = PropertiesFile(await rootBundle.loadString(_path));
    _feedbackTemplate = await rootBundle.loadString(_feedbackTemplatePath);
  }

  String get clientSenderEmail =>
      _properties.stringForKey(_keyClientSenderEmail);

  String get supportEmail => _properties.stringForKey(_keySupportEmail);

  String get sendGridApiKey => _properties.stringForKey(_keySendGridApiKey);

  String get feedbackTemplate => _feedbackTemplate;
}
