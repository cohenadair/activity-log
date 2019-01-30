import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/english_strings.dart';

class Strings {
  static const List<String> _supportedLanguages = ["en"];

  static Map<String, Map<String, Map<String, String>>> _values = {
    "en" : englishStrings,
  };

  static Strings of(BuildContext context) =>
      Localizations.of<Strings>(context, Strings);

  final Locale _locale;

  Strings(this._locale);

  /// If a specific string for a language and country exists, use it, otherwise
  /// use the default.
  String _getString(String key) {
    String value = _values[_locale.languageCode][_locale.countryCode][key];
    if (value == null) {
      return _values[_locale.languageCode]["default"][key];
    }
    return value;
  }

  String get appName => _getString("appName");

  String get cancel => _getString("cancel");
  String get delete => _getString("delete");

  String get activitiesPageTitle => _getString("activitiesPage_title");

  String get editActivityPageNewTitle => _getString("editActivityPage_newTitle");
  String get editActivityPageEditTitle => _getString("editActivityPage_editTitle");
  String get editActivityPageNameLabel => _getString("editActivityPage_nameLabel");
  String get editActivityPageDeleteMessage => _getString("editActivityPage_deleteMessage");
  String get editActivityPageNameExists => _getString("editActivityPage_nameExists");
  String get editActivityPageMissingName => _getString("editActivityPage_missingName");
  String get editActivityPageRecentSessions => _getString("editActivityPage_recentSessions");

  String get totalDurationFormat => _getString("totalDurationFormat");
}

class StringsDelegate extends LocalizationsDelegate<Strings> {
  @override
  bool isSupported(Locale locale) =>
      Strings._supportedLanguages.contains(locale.languageCode);

  @override
  Future<Strings> load(Locale locale) =>
      SynchronousFuture<Strings>(Strings(locale));

  @override
  bool shouldReload(LocalizationsDelegate<Strings> old) => false;
}