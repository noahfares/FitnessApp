import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Settings screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// RPE toggle title on Settings root.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get settingsRpeTitle;

  /// RPE toggle subtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate of perceived exertion per set, 6.0–10.0.'**
  String get settingsRpeSubtitle;

  /// RPE display-mode radio label.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get settingsRpeModeRpe;

  /// RIR display-mode radio label.
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get settingsRpeModeRir;

  /// Week-start setting title.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get settingsWeekStartTitle;

  /// Week-start setting subtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies to weekly volume, sets-per-muscle and streaks.'**
  String get settingsWeekStartSubtitle;

  /// Monday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get settingsWeekdayMon;

  /// Saturday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get settingsWeekdaySat;

  /// Sunday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get settingsWeekdaySun;

  /// Units settings row title.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnitsTitle;

  /// Appearance settings row title.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// Rest timer settings row title.
  ///
  /// In en, this message translates to:
  /// **'Rest timer'**
  String get settingsRestTimerTitle;

  /// Rest timer subtitle when auto-start is on.
  ///
  /// In en, this message translates to:
  /// **'Starts automatically'**
  String get settingsRestTimerAutoStart;

  /// Rest timer subtitle when auto-start is off.
  ///
  /// In en, this message translates to:
  /// **'Manual start'**
  String get settingsRestTimerManualStart;

  /// Rest timer subtitle when no fixed default length is set.
  ///
  /// In en, this message translates to:
  /// **'automatic length'**
  String get settingsRestTimerAutoLength;

  /// Bodyweight settings row title.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get settingsBodyweightTitle;

  /// Data settings row title.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataTitle;

  /// Bars & plates settings row title.
  ///
  /// In en, this message translates to:
  /// **'Bars & plates'**
  String get settingsPlatesTitle;

  /// App lock settings row title.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLockTitle;

  /// About settings row title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
