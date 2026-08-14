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

  /// Settings icon button tooltip on the dashboard app bar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dashboardSettingsTooltip;

  /// Title on the start-a-workout card when no session is in progress.
  ///
  /// In en, this message translates to:
  /// **'Ready to train?'**
  String get dashboardReadyToTrain;

  /// Start-a-workout button/action label, used on the card and the empty state.
  ///
  /// In en, this message translates to:
  /// **'Start a workout'**
  String get dashboardStartWorkout;

  /// Subtitle on the resume card for a session already running.
  ///
  /// In en, this message translates to:
  /// **'In progress · {elapsed}'**
  String dashboardInProgress(String elapsed);

  /// Title of a scheduled-day card, e.g. "Today: Push".
  ///
  /// In en, this message translates to:
  /// **'Today: {day}'**
  String dashboardTodaySchedule(String day);

  /// Bodyweight card title before any entry exists.
  ///
  /// In en, this message translates to:
  /// **'No bodyweight logged yet'**
  String get dashboardNoBodyweight;

  /// Bodyweight card subtitle before any entry exists.
  ///
  /// In en, this message translates to:
  /// **'Log it to track alongside your lifts.'**
  String get dashboardBodyweightHint;

  /// Bodyweight card's quick-add icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Log bodyweight'**
  String get dashboardLogBodyweightTooltip;

  /// Recent-workouts empty state title.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get dashboardEmptyTitle;

  /// Recent-workouts empty state message.
  ///
  /// In en, this message translates to:
  /// **'Your finished sessions will show up here.'**
  String get dashboardEmptyMessage;

  /// Error title if the recent-workouts query fails.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts could not be read'**
  String get dashboardRecentWorkoutsError;

  /// Exercise count on a recent-workout tile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} exercise} other{{count} exercises}}'**
  String dashboardExerciseCount(num count);

  /// Shortcut button to the exercise catalogue.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get dashboardExercisesButton;

  /// Shortcut button to the history tab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dashboardHistoryButton;

  /// Section heading above the recent-workouts list.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get dashboardRecentWorkoutsTitle;

  /// History screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// History search field hint text.
  ///
  /// In en, this message translates to:
  /// **'Search by workout or exercise'**
  String get historySearchHint;

  /// Clear-search icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get historyClearSearchTooltip;

  /// Error title if the history query fails.
  ///
  /// In en, this message translates to:
  /// **'History could not be read'**
  String get historyReadError;

  /// Empty state title when a search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No sessions match'**
  String get historyNoResultsTitle;

  /// Empty state message when a search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter search.'**
  String get historyNoResultsMessage;

  /// Empty state title with no search active and no history at all.
  ///
  /// In en, this message translates to:
  /// **'No sessions logged yet'**
  String get historyEmptyTitle;

  /// Empty state message with no search active and no history at all.
  ///
  /// In en, this message translates to:
  /// **'Finished workouts show up here.'**
  String get historyEmptyMessage;

  /// FAB label for retroactively logging a workout.
  ///
  /// In en, this message translates to:
  /// **'Log past workout'**
  String get historyLogPastWorkout;

  /// Exercise count on a history workout tile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} exercise} other{{count} exercises}}'**
  String historyExerciseCount(num count);

  /// ConfirmSheet's default confirm-button label, used across every destructive action in the app unless a call site names a more specific verb.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmSheetDeleteLabel;

  /// ConfirmSheet's default cancel-button label.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get confirmSheetKeepItLabel;

  /// Routine list app bar title.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routinesTitle;

  /// Archived-routines app bar title, and the toggle button's tooltip when showing the active list.
  ///
  /// In en, this message translates to:
  /// **'Archived routines'**
  String get routinesArchivedTitle;

  /// Toggle button tooltip when currently showing the archived list.
  ///
  /// In en, this message translates to:
  /// **'Active routines'**
  String get routinesShowActiveTooltip;

  /// App bar icon button tooltip opening the starter program gallery.
  ///
  /// In en, this message translates to:
  /// **'Starter programs'**
  String get routinesStarterProgramsTooltip;

  /// New-folder icon button tooltip, dialog title, and the "create a folder from here" sheet row label.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get routinesNewFolderAction;

  /// New-routine icon button tooltip and dialog title.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get routinesNewRoutineAction;

  /// Error title if the routine list query fails.
  ///
  /// In en, this message translates to:
  /// **'Routines could not be read'**
  String get routinesReadError;

  /// Empty state title with no routines at all.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get routinesEmptyTitle;

  /// Empty state message with no routines at all.
  ///
  /// In en, this message translates to:
  /// **'A routine holds days; a day is what you start a workout from. A starter program is the fastest way to get one.'**
  String get routinesEmptyMessage;

  /// Empty state action label opening the starter program gallery.
  ///
  /// In en, this message translates to:
  /// **'Browse starter programs'**
  String get routinesBrowseStarterPrograms;

  /// Section label for unfoldered routines, and the "remove from any folder" option in the move-to-folder sheet.
  ///
  /// In en, this message translates to:
  /// **'No folder'**
  String get routinesNoFolder;

  /// Error title if the archived-routines query fails.
  ///
  /// In en, this message translates to:
  /// **'Archived routines could not be read'**
  String get routinesArchivedReadError;

  /// Empty state title on the archived list with nothing archived.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived'**
  String get routinesNothingArchivedTitle;

  /// Empty state message on the archived list with nothing archived.
  ///
  /// In en, this message translates to:
  /// **'Archived routines stay startable and can be restored from here.'**
  String get routinesNothingArchivedMessage;

  /// A routine tile's subtitle before it has any days.
  ///
  /// In en, this message translates to:
  /// **'No days yet'**
  String get routinesNoDaysYet;

  /// Restore-from-archive icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get routinesRestoreTooltip;

  /// Routine overflow-menu item.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get routinesMoveToFolderAction;

  /// Routine overflow-menu item.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get routinesDuplicateAction;

  /// Routine overflow-menu item.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get routinesArchiveAction;

  /// Routine overflow-menu item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get routinesDeleteAction;

  /// Confirmation sheet title before deleting a routine.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String routinesDeleteConfirmTitle(String name);

  /// Confirmation sheet message before deleting a routine. Carries a verbatim internal doc reference from the original copy — not something this migration should silently rewrite.
  ///
  /// In en, this message translates to:
  /// **'Its days and targets will be removed. Workouts you have already logged from it are never affected (`ADR-0004`).'**
  String get routinesDeleteConfirmMessage;

  /// Text field label in the rename/create-routine dialog, shared by every caller across the routines feature.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get routineNameFieldLabel;

  /// Cancel button in the rename/create-routine dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get routineNameDialogCancel;

  /// Save button in the rename/create-routine dialog.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get routineNameDialogSave;
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
