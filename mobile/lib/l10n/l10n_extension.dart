import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/utils/root.dart';
import 'package:mobile/i18n/strings.dart';

extension L10ns on L10n {
  // TODO: Replace with real localizations object when app is internationalized.
  Strings get app => Strings.of(Root.get.buildContext);
}
