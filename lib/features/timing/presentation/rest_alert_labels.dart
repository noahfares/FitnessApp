/// Display names for [RestAlertStyle] (`F-I18N-001`).
///
/// In presentation rather than beside the enum: `lib/domain/` imports nothing
/// from Flutter (docs/20-ARCHITECTURE.md) and `AppLocalizations` is Flutter.
/// The behaviour the enum implies — whether it plays a sound, whether it
/// vibrates — stays in the domain, because that is a rule rather than text.
library;

import '../../../domain/timing/rest_settings.dart';
import '../../../l10n/app_localizations.dart';

extension RestAlertStyleLabel on RestAlertStyle {
  String label(AppLocalizations l10n) => switch (this) {
    RestAlertStyle.silent => l10n.restAlertSilent,
    RestAlertStyle.sound => l10n.restAlertSound,
    RestAlertStyle.vibration => l10n.restAlertVibration,
    RestAlertStyle.both => l10n.restAlertBoth,
  };
}
