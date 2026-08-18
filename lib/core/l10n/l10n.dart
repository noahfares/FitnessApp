/// Shorthand for reaching the generated strings (`F-I18N-001`).
///
/// `context.l10n.finishWorkout` rather than
/// `AppLocalizations.of(context).finishWorkout` — the long form is what makes
/// externalisation feel expensive at the call site, and a rule that feels
/// expensive is a rule that gets skipped for "just this one string".
library;

import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
