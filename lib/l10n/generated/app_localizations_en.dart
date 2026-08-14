// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsRpeTitle => 'RPE';

  @override
  String get settingsRpeSubtitle =>
      'Rate of perceived exertion per set, 6.0–10.0.';

  @override
  String get settingsRpeModeRpe => 'RPE';

  @override
  String get settingsRpeModeRir => 'RIR';

  @override
  String get settingsWeekStartTitle => 'Week starts on';

  @override
  String get settingsWeekStartSubtitle =>
      'Applies to weekly volume, sets-per-muscle and streaks.';

  @override
  String get settingsWeekdayMon => 'Mon';

  @override
  String get settingsWeekdaySat => 'Sat';

  @override
  String get settingsWeekdaySun => 'Sun';

  @override
  String get settingsUnitsTitle => 'Units';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsRestTimerTitle => 'Rest timer';

  @override
  String get settingsRestTimerAutoStart => 'Starts automatically';

  @override
  String get settingsRestTimerManualStart => 'Manual start';

  @override
  String get settingsRestTimerAutoLength => 'automatic length';

  @override
  String get settingsBodyweightTitle => 'Bodyweight';

  @override
  String get settingsDataTitle => 'Data';

  @override
  String get settingsPlatesTitle => 'Bars & plates';

  @override
  String get settingsAppLockTitle => 'App lock';

  @override
  String get settingsAboutTitle => 'About';
}
