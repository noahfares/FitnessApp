/// The generated English strings, without pumping a widget (`F-I18N-001`).
///
/// Text-composing functions now take an `AppLocalizations` rather than reading
/// one from a context, which is what lets them stay unit-testable: this is the
/// one line those tests need instead of a widget tree.
library;

import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:fitness_app/l10n/app_localizations_en.dart';

AppLocalizations testL10n() => AppLocalizationsEn();
