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

  /// Catalogue app bar title.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get catalogTitle;

  /// Archived-exercises app bar title, and the toggle button's tooltip when showing the active list.
  ///
  /// In en, this message translates to:
  /// **'Archived exercises'**
  String get catalogArchivedTitle;

  /// Toggle button tooltip when currently showing the archived list.
  ///
  /// In en, this message translates to:
  /// **'Active exercises'**
  String get catalogShowActiveTooltip;

  /// Icon button tooltip and bottom-sheet header for bulk-archiving by equipment.
  ///
  /// In en, this message translates to:
  /// **'Archive by equipment'**
  String get catalogArchiveByEquipment;

  /// Catalogue search field hint text.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get catalogSearchHint;

  /// Clear-search icon button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get catalogClearSearchTooltip;

  /// Error title if the catalogue query fails.
  ///
  /// In en, this message translates to:
  /// **'The catalogue could not be read'**
  String get catalogReadError;

  /// FAB label for creating a custom exercise.
  ///
  /// In en, this message translates to:
  /// **'New exercise'**
  String get catalogNewExercise;

  /// Confirmation sheet title before bulk-archiving by equipment.
  ///
  /// In en, this message translates to:
  /// **'Archive all {equipment} exercises?'**
  String catalogArchiveEquipmentConfirmTitle(String equipment);

  /// Confirmation sheet message before bulk-archiving by equipment.
  ///
  /// In en, this message translates to:
  /// **'Every non-archived {equipment} exercise is hidden from pickers and search. History is untouched, and each can be restored individually from the archived list.'**
  String catalogArchiveEquipmentConfirmMessage(String equipment);

  /// Confirm-button label for the bulk-archive-by-equipment sheet (non-destructive framing, unlike the shared Delete default).
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get catalogArchiveConfirmLabel;

  /// Snackbar result after bulk-archiving by equipment.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to archive.} one{Archived {count} {equipment} exercise.} other{Archived {count} {equipment} exercises.}}'**
  String catalogArchivedCount(num count, String equipment);

  /// Error title if the archived-exercises query fails.
  ///
  /// In en, this message translates to:
  /// **'Archived exercises could not be read'**
  String get catalogArchivedReadError;

  /// Empty state title on the archived list with nothing archived.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived'**
  String get catalogNothingArchivedTitle;

  /// Empty state message on the archived list with nothing archived.
  ///
  /// In en, this message translates to:
  /// **'Archived exercises stay in your history and can be restored from here.'**
  String get catalogNothingArchivedMessage;

  /// Restore button on an archived exercise row.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get catalogRestoreAction;

  /// Empty state title when a search/filter returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No exercises match'**
  String get catalogNoMatchTitle;

  /// Empty state message when a search/filter returns nothing.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter search, or clear a filter.'**
  String get catalogNoMatchMessage;

  /// Empty state title with no filter active and genuinely no exercises (should not happen post-seed).
  ///
  /// In en, this message translates to:
  /// **'The catalogue is empty'**
  String get catalogEmptyTitle;

  /// Empty state message with no filter active and genuinely no exercises.
  ///
  /// In en, this message translates to:
  /// **'Seeding runs at startup; this should not happen.'**
  String get catalogEmptyMessage;

  /// Result count shown while a search/filter narrows the list.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total, plural, one{{total} exercise} other{{total} exercises}}'**
  String catalogFilteredCount(num shown, num total);

  /// Favourite-star icon button tooltip when already a favourite.
  ///
  /// In en, this message translates to:
  /// **'Unfavourite'**
  String get catalogUnfavouriteTooltip;

  /// Favourite-star icon button tooltip when not yet a favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get catalogFavouriteTooltip;

  /// Per-exercise-row icon button tooltip opening its history/trend screen.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get catalogExerciseHistoryTooltip;

  /// Insights tab app bar title.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// Empty state title with no logged sessions at all.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get insightsNoSessionsTitle;

  /// Empty state message with no logged sessions at all.
  ///
  /// In en, this message translates to:
  /// **'Log a few workouts to see volume and muscle coverage here.'**
  String get insightsNoSessionsMessage;

  /// Button opening the consistency/streak screen.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get insightsConsistencyButton;

  /// Button opening the PR timeline screen.
  ///
  /// In en, this message translates to:
  /// **'PR timeline'**
  String get insightsPrTimelineButton;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Muscle balance'**
  String get insightsMuscleBalanceTitle;

  /// Muscle balance section subtitle.
  ///
  /// In en, this message translates to:
  /// **'Trailing 4 weeks. A rough guide, not a prescription.'**
  String get insightsMuscleBalanceSubtitle;

  /// Ratio tile label.
  ///
  /// In en, this message translates to:
  /// **'Push : pull'**
  String get insightsPushPullLabel;

  /// Ratio tile label.
  ///
  /// In en, this message translates to:
  /// **'Quad : hamstring'**
  String get insightsQuadHamstringLabel;

  /// Ratio tile label when there is no data to compute it from.
  ///
  /// In en, this message translates to:
  /// **'{label} — no data recorded'**
  String insightsRatioNoData(String label);

  /// ACWR section heading.
  ///
  /// In en, this message translates to:
  /// **'Training load'**
  String get insightsTrainingLoadTitle;

  /// ACWR section message when there isn't enough history yet.
  ///
  /// In en, this message translates to:
  /// **'Needs at least 28 days of logged training to show.'**
  String get insightsAcwrInsufficientData;

  /// ACWR explanatory text below the ratio.
  ///
  /// In en, this message translates to:
  /// **'Ratio of this week\'s volume to your trailing 4-week average (ACWR). 0.8–1.3 is typically described as a steady ramp rate; this is information, not a warning.'**
  String get insightsAcwrExplanation;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Duration & rest'**
  String get insightsDurationRestTitle;

  /// Duration & rest section subtitle when no rest-compliance data exists yet.
  ///
  /// In en, this message translates to:
  /// **'not enough logged rest yet'**
  String get insightsRestComplianceUnknown;

  /// Duration & rest section subtitle showing average rest compliance.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of prescribed rest'**
  String insightsRestCompliancePercent(num percent);

  /// Chart label above the session-duration trend.
  ///
  /// In en, this message translates to:
  /// **'Session duration'**
  String get insightsSessionDurationLabel;

  /// Session-duration chart subtitle.
  ///
  /// In en, this message translates to:
  /// **'Every finished session'**
  String get insightsEveryFinishedSession;

  /// Explanatory text under the rest-compliance figure.
  ///
  /// In en, this message translates to:
  /// **'Average actual rest vs. each exercise\'s resolved default — an approximation, not a per-set historical record.'**
  String get insightsRestComplianceExplanation;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Muscle heat map'**
  String get insightsMuscleHeatTitle;

  /// Muscle heat map section subtitle.
  ///
  /// In en, this message translates to:
  /// **'Relative training volume by muscle'**
  String get insightsMuscleHeatSubtitle;

  /// Body map view toggle segment.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get insightsBodyMapFront;

  /// Body map view toggle segment.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get insightsBodyMapBack;

  /// Explanatory text under the muscle heat map.
  ///
  /// In en, this message translates to:
  /// **'Relative to your hardest-trained muscle over the selected range.'**
  String get insightsMuscleHeatExplanation;

  /// Section heading above the per-muscle dropdown.
  ///
  /// In en, this message translates to:
  /// **'By muscle'**
  String get insightsByMuscleTitle;

  /// Per-muscle volume chart label.
  ///
  /// In en, this message translates to:
  /// **'Volume — {muscle}'**
  String insightsVolumeForMuscle(String muscle);

  /// Per-muscle hard-sets chart label.
  ///
  /// In en, this message translates to:
  /// **'Hard sets per week — {muscle}'**
  String insightsHardSetsForMuscle(String muscle);

  /// Drill-down list heading, whole range scoped.
  ///
  /// In en, this message translates to:
  /// **'Contributing exercises'**
  String get insightsContributingExercises;

  /// Drill-down list heading, scoped to one tapped week.
  ///
  /// In en, this message translates to:
  /// **'Contributing exercises — week of {week}'**
  String insightsContributingExercisesForWeek(String week);

  /// Clears the tapped-week drill-down scope.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get insightsClearAction;

  /// Set count on a contributing-exercise row, already formatted to one decimal.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets'**
  String insightsContributorSets(String sets);

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Overall weekly volume'**
  String get insightsOverallVolumeTitle;

  /// Date range label.
  ///
  /// In en, this message translates to:
  /// **'Last 4 weeks'**
  String get insightsRangeFourWeeks;

  /// Date range label.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get insightsRangeThreeMonths;

  /// Date range label.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get insightsRangeSixMonths;

  /// Date range label.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get insightsRangeOneYear;

  /// Date range label.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get insightsRangeAllTime;

  /// Date range label.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get insightsRangeCustom;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Rep ranges'**
  String get insightsRepRangesTitle;

  /// Rep-range chart subtitle.
  ///
  /// In en, this message translates to:
  /// **'{range} · sets by rep range'**
  String insightsRepRangeSubtitle(String range);

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Intensity (% of e1RM)'**
  String get insightsIntensityE1rmTitle;

  /// e1RM-intensity chart subtitle.
  ///
  /// In en, this message translates to:
  /// **'{range} · sets with a known e1RM baseline'**
  String insightsIntensityE1rmSubtitle(String range);

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Intensity (RPE)'**
  String get insightsIntensityRpeTitle;

  /// Explanatory text under the RPE intensity heading.
  ///
  /// In en, this message translates to:
  /// **'A more honest measure than an e1RM estimate, where logged.'**
  String get insightsIntensityRpeExplanation;

  /// RPE-intensity chart subtitle.
  ///
  /// In en, this message translates to:
  /// **'{range} · sets by RPE'**
  String insightsIntensityRpeSubtitle(String range);

  /// App bar title while loading/erroring, and on the no-session screen.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get activeWorkoutTitle;

  /// Error title if the active-workout query fails.
  ///
  /// In en, this message translates to:
  /// **'This workout could not be read'**
  String get activeWorkoutReadError;

  /// Message shown when /workout/active is reached with no session running.
  ///
  /// In en, this message translates to:
  /// **'No workout in progress.'**
  String get activeWorkoutNoneInProgress;

  /// Button on the no-session screen.
  ///
  /// In en, this message translates to:
  /// **'Start one'**
  String get activeWorkoutStartOne;

  /// Overflow-menu item opening the discard confirmation.
  ///
  /// In en, this message translates to:
  /// **'Discard workout'**
  String get activeWorkoutDiscardMenuItem;

  /// Empty state title with no exercises added to the session yet.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get activeWorkoutEmptyTitle;

  /// Empty state message with no exercises added to the session yet.
  ///
  /// In en, this message translates to:
  /// **'Add the first one to start logging.'**
  String get activeWorkoutEmptyMessage;

  /// Exercise count in the session header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} exercise} other{{count} exercises}}'**
  String activeWorkoutExerciseCount(num count);

  /// Button opening the exercise picker.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get activeWorkoutAddExercises;

  /// Button finishing the session.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get activeWorkoutFinish;

  /// Dialog title when finishing a session with no completed sets.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet'**
  String get activeWorkoutNothingLoggedTitle;

  /// Dialog message when finishing a session with no completed sets.
  ///
  /// In en, this message translates to:
  /// **'No sets were completed, so this would be an empty entry in your history. Discard it instead?'**
  String get activeWorkoutNothingLoggedMessage;

  /// Dialog/sheet action that dismisses without finishing or discarding.
  ///
  /// In en, this message translates to:
  /// **'Keep training'**
  String get activeWorkoutKeepTraining;

  /// Dialog action finishing an empty session anyway.
  ///
  /// In en, this message translates to:
  /// **'Finish anyway'**
  String get activeWorkoutFinishAnyway;

  /// Discard action label, used both in the empty-session dialog and the hold-to-confirm discard button.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get activeWorkoutDiscardAction;

  /// Sheet title before discarding a session.
  ///
  /// In en, this message translates to:
  /// **'Discard this workout?'**
  String get activeWorkoutDiscardConfirmTitle;

  /// Discard sheet message when the session has no exercises.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been added to it yet.'**
  String get activeWorkoutDiscardTallyEmpty;

  /// Discard sheet message summarising what will be lost.
  ///
  /// In en, this message translates to:
  /// **'{exercises, plural, one{{exercises} exercise} other{{exercises} exercises}} and {sets, plural, one{{sets} completed set} other{{sets} completed sets}} will be removed from this session.'**
  String activeWorkoutDiscardTally(num exercises, num sets);

  /// Banner shown on a session left running overnight.
  ///
  /// In en, this message translates to:
  /// **'This workout has been open for more than 12 hours. Finish or discard it if you are done.'**
  String get activeWorkoutStaleNotice;

  /// Per-exercise completion count.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total, plural, one{{total} set} other{{total} sets}} done'**
  String activeWorkoutSetsDone(num completed, num total);

  /// Prefix before a routine's per-exercise target summary.
  ///
  /// In en, this message translates to:
  /// **'Target: {summary}'**
  String activeWorkoutTargetPrefix(String summary);

  /// Overflow-menu item when the exercise has no note yet.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get activeWorkoutAddNote;

  /// Overflow-menu item when the exercise already has a note.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get activeWorkoutEditNote;

  /// Overflow-menu item opening the warm-up generator.
  ///
  /// In en, this message translates to:
  /// **'Generate warm-ups'**
  String get activeWorkoutGenerateWarmups;

  /// Overflow-menu item opening the exercise picker to swap.
  ///
  /// In en, this message translates to:
  /// **'Swap exercise'**
  String get activeWorkoutSwapExercise;

  /// Remove action, used as the overflow-menu item and the confirm sheet's confirm label.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get activeWorkoutRemove;

  /// Button breaking a superset pairing.
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get activeWorkoutUngroup;

  /// Button pairing this exercise with the next one into a superset.
  ///
  /// In en, this message translates to:
  /// **'Group with next'**
  String get activeWorkoutGroupWithNext;

  /// Label on a grouped exercise block.
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get activeWorkoutSupersetBadge;

  /// Confirm sheet title before removing an exercise with completed sets.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String activeWorkoutRemoveExerciseConfirmTitle(String name);

  /// Confirm sheet message before removing an exercise with completed sets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} completed set} other{{count} completed sets}} will be removed from this session too.'**
  String activeWorkoutRemoveExerciseConfirmMessage(num count);

  /// Snackbar after removing an exercise, with an Undo action.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String activeWorkoutExerciseRemovedSnackbar(String name);

  /// Snackbar action restoring a just-removed exercise.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get activeWorkoutUndo;

  /// Column header above the ghost-value column.
  ///
  /// In en, this message translates to:
  /// **'Last time'**
  String get activeWorkoutLastTimeHeader;

  /// Start-workout screen app bar title (deep-link entry).
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startWorkoutTitle;

  /// Title shown when a session is already in progress.
  ///
  /// In en, this message translates to:
  /// **'Already training'**
  String get startWorkoutAlreadyTrainingTitle;

  /// Message shown when a session is already in progress.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is still in progress. Finish or discard it before starting another.'**
  String startWorkoutAlreadyTrainingMessage(String name);

  /// Button resuming the in-progress session.
  ///
  /// In en, this message translates to:
  /// **'Resume workout'**
  String get startWorkoutResumeAction;

  /// Title shown when no session is in progress.
  ///
  /// In en, this message translates to:
  /// **'Start a workout'**
  String get startWorkoutFreshTitle;

  /// Message under the empty-workout option.
  ///
  /// In en, this message translates to:
  /// **'An empty session you add exercises to as you go.'**
  String get startWorkoutEmptySessionMessage;

  /// Button starting a blank session.
  ///
  /// In en, this message translates to:
  /// **'Start empty workout'**
  String get startWorkoutStartEmptyAction;

  /// Section heading above the routine-day list.
  ///
  /// In en, this message translates to:
  /// **'Or start from a routine'**
  String get startWorkoutFromRoutineTitle;

  /// Empty state title with no routines to start from.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get startWorkoutNoRoutinesTitle;

  /// Empty state message with no routines to start from.
  ///
  /// In en, this message translates to:
  /// **'Build one from the Routines tab.'**
  String get startWorkoutNoRoutinesMessage;

  /// Finish-summary app bar title.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get sessionSummaryTitle;

  /// Error title if the summary query fails.
  ///
  /// In en, this message translates to:
  /// **'This summary could not be read'**
  String get sessionSummaryReadError;

  /// Button returning to the dashboard from the summary.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sessionSummaryDone;

  /// Summary headline.
  ///
  /// In en, this message translates to:
  /// **'Nice work.'**
  String get sessionSummaryNiceWork;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sessionSummaryDurationLabel;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get sessionSummaryVolumeLabel;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sessionSummarySetsLabel;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get sessionSummaryExercisesLabel;

  /// Section heading, shown only when this session set a record.
  ///
  /// In en, this message translates to:
  /// **'Personal records'**
  String get sessionSummaryPersonalRecordsTitle;

  /// Section heading above the muscle chips.
  ///
  /// In en, this message translates to:
  /// **'Muscles worked'**
  String get sessionSummaryMusclesWorkedTitle;

  /// Section heading, shown only when a previous session exists to compare against.
  ///
  /// In en, this message translates to:
  /// **'Compared to last time'**
  String get sessionSummaryComparedToLastTime;

  /// Volume-change figure; the +/- sign is composed in code, not part of this template.
  ///
  /// In en, this message translates to:
  /// **'{volume} volume'**
  String sessionSummaryVolumeChange(String volume);

  /// PR description for a max-weight record.
  ///
  /// In en, this message translates to:
  /// **'heaviest set: {weight}'**
  String sessionSummaryPrHeaviestSet(String weight);

  /// PR description for a best-e1RM record.
  ///
  /// In en, this message translates to:
  /// **'best estimated 1RM: {e1rm}'**
  String sessionSummaryPrBestE1rm(String e1rm);

  /// PR description for a max-reps-at-weight record.
  ///
  /// In en, this message translates to:
  /// **'{reps} reps at {weight}'**
  String sessionSummaryPrRepsAtWeight(num reps, String weight);

  /// PR description for a max-session-volume record.
  ///
  /// In en, this message translates to:
  /// **'most volume in a session: {volume}'**
  String sessionSummaryPrSessionVolume(String volume);

  /// Error title if the routine query fails.
  ///
  /// In en, this message translates to:
  /// **'Routine could not be read'**
  String get routineEditorReadError;

  /// Shown when the routine id in the route no longer resolves.
  ///
  /// In en, this message translates to:
  /// **'This routine no longer exists.'**
  String get routineEditorNotFound;

  /// Error title if the day list query fails.
  ///
  /// In en, this message translates to:
  /// **'Days could not be read'**
  String get routineEditorDaysReadError;

  /// Empty state message with no days on this routine yet.
  ///
  /// In en, this message translates to:
  /// **'\"Push\", \"Pull\", \"Legs\" — a day is what you start a workout from.'**
  String get routineEditorNoDaysMessage;

  /// Button adding a new day.
  ///
  /// In en, this message translates to:
  /// **'Add a day'**
  String get routineEditorAddDay;

  /// Dialog title creating a new day.
  ///
  /// In en, this message translates to:
  /// **'New day'**
  String get routineEditorNewDayTitle;

  /// Opens the weekday scheduler — used as both an icon tooltip and a menu item.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get routineEditorScheduleAction;

  /// Error title if a single day's exercise list query fails.
  ///
  /// In en, this message translates to:
  /// **'Exercises could not be read'**
  String get routineEditorExercisesReadError;

  /// Overflow-menu item, shared by the day tile and the routine menu.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get routineEditorMenuRename;

  /// Dialog title renaming a day.
  ///
  /// In en, this message translates to:
  /// **'Rename day'**
  String get routineEditorRenameDayTitle;

  /// Dialog title renaming a routine.
  ///
  /// In en, this message translates to:
  /// **'Rename routine'**
  String get routineEditorRenameRoutineTitle;

  /// Confirm sheet message before deleting a day.
  ///
  /// In en, this message translates to:
  /// **'Its exercises and targets will be removed.'**
  String get routineEditorDeleteDayConfirmMessage;

  /// Error title if the day query fails.
  ///
  /// In en, this message translates to:
  /// **'Day could not be read'**
  String get routineDayEditorReadError;

  /// Shown when the day id in the route no longer resolves.
  ///
  /// In en, this message translates to:
  /// **'This day no longer exists.'**
  String get routineDayEditorNotFound;

  /// Monday, abbreviated — schedule chips and the day-tile summary.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get routineDayEditorWeekdayMon;

  /// Tuesday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get routineDayEditorWeekdayTue;

  /// Wednesday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get routineDayEditorWeekdayWed;

  /// Thursday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get routineDayEditorWeekdayThu;

  /// Friday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get routineDayEditorWeekdayFri;

  /// Saturday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get routineDayEditorWeekdaySat;

  /// Sunday, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get routineDayEditorWeekdaySun;

  /// Subtitle on the weekday scheduler sheet.
  ///
  /// In en, this message translates to:
  /// **'Optional — pick the weekdays you plan to train this day.'**
  String get routineDayEditorScheduleDescription;

  /// Empty state title with no exercises on this day yet.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get routineDayEditorEmptyTitle;

  /// Empty state message with no exercises on this day yet.
  ///
  /// In en, this message translates to:
  /// **'Add exercises, then set targets for each.'**
  String get routineDayEditorEmptyMessage;

  /// Button opening the exercise picker — used as both an empty-state action and the always-visible bottom button.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get routineDayEditorAddExercisesAction;

  /// Count of exercises multi-selected for grouping into a superset.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 selected} other{{count} selected}}'**
  String routineDayEditorSelectedCount(num count);

  /// Shown when the multi-selection can't be grouped because the rows aren't contiguous.
  ///
  /// In en, this message translates to:
  /// **'Must be adjacent'**
  String get routineDayEditorMustBeAdjacent;

  /// Groups the selected exercises into a superset.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get routineDayEditorGroupAction;

  /// Removes this exercise from the day.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get routineDayEditorRemoveTooltip;

  /// Exercise tile subtitle when no target has been configured.
  ///
  /// In en, this message translates to:
  /// **'No targets set'**
  String get routineDayEditorNoTargetsSet;

  /// Label on the first tile of a grouped block of exercises.
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get routineDayEditorSupersetLabel;

  /// Breaks a superset group back into independent exercises.
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get routineDayEditorUngroupAction;

  /// Target-sets number field label.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get routineDayEditorSetsLabel;

  /// Target-reps-minimum number field label.
  ///
  /// In en, this message translates to:
  /// **'Reps min'**
  String get routineDayEditorRepsMinLabel;

  /// Target-reps-maximum number field label.
  ///
  /// In en, this message translates to:
  /// **'Reps max'**
  String get routineDayEditorRepsMaxLabel;

  /// Target-weight field label, with the active load unit symbol.
  ///
  /// In en, this message translates to:
  /// **'Target weight ({unit})'**
  String routineDayEditorTargetWeightLabel(String unit);

  /// Per-exercise rest override dropdown label.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get routineDayEditorRestLabel;

  /// Helper text under the rest override dropdown.
  ///
  /// In en, this message translates to:
  /// **'Overrides the exercise and global defaults.'**
  String get routineDayEditorRestHelperText;

  /// Dropdown option meaning no override — fall back to the exercise's or app's default rest.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get routineDayEditorRestDefaultOption;

  /// Section heading above the progression-rule picker.
  ///
  /// In en, this message translates to:
  /// **'Progression'**
  String get routineDayEditorProgressionHeading;

  /// Progression-rule option: no automatic progression, carry the last weight forward.
  ///
  /// In en, this message translates to:
  /// **'I\'ll decide'**
  String get routineDayEditorRuleManual;

  /// Progression-rule option: linear progression.
  ///
  /// In en, this message translates to:
  /// **'Add weight on success'**
  String get routineDayEditorRuleLinear;

  /// Progression-rule option: double progression.
  ///
  /// In en, this message translates to:
  /// **'Add reps, then weight'**
  String get routineDayEditorRuleDoubleProgression;

  /// Progression-rule option: RPE-autoregulated progression.
  ///
  /// In en, this message translates to:
  /// **'Match effort (RPE)'**
  String get routineDayEditorRuleRpe;

  /// Progression-rule option: percentage of training max.
  ///
  /// In en, this message translates to:
  /// **'% of TM'**
  String get routineDayEditorRulePercent;

  /// Increment field label for the linear progression rule.
  ///
  /// In en, this message translates to:
  /// **'Add when I hit every set ({unit})'**
  String routineDayEditorLinearIncrementLabel(String unit);

  /// Helper text explaining the linear progression rule's behaviour.
  ///
  /// In en, this message translates to:
  /// **'Repeats the same weight on a partial miss; deloads after three misses in a row.'**
  String get routineDayEditorLinearHelperText;

  /// Increment field label for the double progression rule.
  ///
  /// In en, this message translates to:
  /// **'Add when I hit the top of my rep range ({unit})'**
  String routineDayEditorDoubleProgressionLabel(String unit);

  /// Helper text explaining the double progression rule's behaviour.
  ///
  /// In en, this message translates to:
  /// **'Uses the Reps min/max above as the range. Deloads after three sessions in a row below the minimum.'**
  String get routineDayEditorDoubleProgressionHelperText;

  /// Target-RPE dropdown label for the RPE-autoregulated rule.
  ///
  /// In en, this message translates to:
  /// **'Target RPE'**
  String get routineDayEditorTargetRpeLabel;

  /// Helper text explaining the target-RPE field.
  ///
  /// In en, this message translates to:
  /// **'How hard the last set should feel. Comes in easier — add more; harder — add less or back off.'**
  String get routineDayEditorTargetRpeHelperText;

  /// Increment field label for the RPE-autoregulated rule.
  ///
  /// In en, this message translates to:
  /// **'Base step ({unit})'**
  String routineDayEditorBaseStepLabel(String unit);

  /// Percentage field label for the percentage-of-training-max rule.
  ///
  /// In en, this message translates to:
  /// **'Percent of training max'**
  String get routineDayEditorPercentLabel;

  /// Helper text when the exercise has no training max configured.
  ///
  /// In en, this message translates to:
  /// **'No training max set on this exercise yet — set one on the exercise\'s own editor first.'**
  String get routineDayEditorPercentHelperNoTm;

  /// Helper text showing the exercise's configured training max.
  ///
  /// In en, this message translates to:
  /// **'Training max: {value} {unit}. Recomputed every time this day is started — no week/cycle variation yet.'**
  String routineDayEditorPercentHelperWithTm(String value, String unit);

  /// Button saving the target editor sheet.
  ///
  /// In en, this message translates to:
  /// **'Save targets'**
  String get routineDayEditorSaveTargets;

  /// Title on the day's estimated-duration/volume preview card.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get routineDayEditorPreviewTitle;

  /// Estimated session duration, rounded to the nearest minute.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String routineDayEditorDurationApprox(num minutes);

  /// Placeholder shown for duration or volume when nothing can be estimated yet.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get routineDayEditorNoData;

  /// Subtitle on the sets-per-muscle bar chart.
  ///
  /// In en, this message translates to:
  /// **'Sets per muscle'**
  String get routineDayEditorSetsPerMuscleSubtitle;

  /// Shown in place of the chart until any target is set.
  ///
  /// In en, this message translates to:
  /// **'Set targets to see sets per muscle here.'**
  String get routineDayEditorSetTargetsMessage;

  /// Button starting a workout from this day.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get routineDayEditorStartWorkoutAction;

  /// Confirm sheet message when starting a day while another workout is already active.
  ///
  /// In en, this message translates to:
  /// **'A workout is already in progress. Finish or discard it before starting another.'**
  String get routineDayEditorAlreadyTrainingMessage;

  /// Confirm sheet action jumping to the already-active workout.
  ///
  /// In en, this message translates to:
  /// **'Resume it'**
  String get routineDayEditorResumeAction;

  /// Workout detail screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get historyDetailTitle;

  /// Opens the full past-workout editor.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get historyDetailEditTooltip;

  /// Starts a new session pre-filled from this one.
  ///
  /// In en, this message translates to:
  /// **'Repeat this workout'**
  String get historyDetailRepeatTooltip;

  /// Used as both the app-bar tooltip and the naming dialog's title.
  ///
  /// In en, this message translates to:
  /// **'Save as routine'**
  String get historyDetailSaveAsRoutineAction;

  /// Confirm sheet title before deleting a whole past workout.
  ///
  /// In en, this message translates to:
  /// **'Delete this workout?'**
  String get historyDetailDeleteConfirmTitle;

  /// Confirm sheet message before deleting a whole past workout.
  ///
  /// In en, this message translates to:
  /// **'This session and all its sets will be removed from your history.'**
  String get historyDetailDeleteConfirmMessage;

  /// Empty state when a logged session has no exercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this session'**
  String get historyDetailNoExercisesTitle;

  /// Past-workout editor app bar title.
  ///
  /// In en, this message translates to:
  /// **'Edit workout'**
  String get historyEditTitle;

  /// Closes the past-workout editor — every field already writes through.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get historyEditDoneAction;

  /// Workout name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get historyEditNameLabel;

  /// Opens the date picker for this past workout.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get historyEditDateLabel;

  /// Opens the time picker for this past workout.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get historyEditTimeLabel;

  /// Workout notes field label.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get historyEditNotesLabel;

  /// Empty state before any exercise has been added to this past workout.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get historyEditEmptyTitle;

  /// Empty state message pointing at the add-exercises button.
  ///
  /// In en, this message translates to:
  /// **'Add the first one below.'**
  String get historyEditEmptyMessage;

  /// Removes an exercise from this past workout.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get historyEditRemoveExerciseTooltip;

  /// Per-exercise note field label on the past-workout editor.
  ///
  /// In en, this message translates to:
  /// **'Exercise note'**
  String get historyEditExerciseNoteLabel;

  /// Confirm sheet message before removing an exercise from a past workout — unconditional, unlike the live logger's completed-set-count version.
  ///
  /// In en, this message translates to:
  /// **'Its sets in this session will be removed too.'**
  String get historyEditRemoveExerciseConfirmMessage;

  /// Screen-reader label on a past set's completion checkbox.
  ///
  /// In en, this message translates to:
  /// **'Complete set'**
  String get historySetRowCompleteSemanticLabel;

  /// Snackbar after deleting a set from a past workout, with an Undo action.
  ///
  /// In en, this message translates to:
  /// **'Set {label} deleted'**
  String historySetRowDeletedSnackbar(String label);

  /// Title on the sheet that starts a retroactively-logged session.
  ///
  /// In en, this message translates to:
  /// **'Log a past workout'**
  String get historyLogPastSheetTitle;

  /// Workout name field label — optional, unlike the live logger.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get historyLogPastNameLabel;

  /// Opens the date picker for the retroactive session.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get historyLogPastDateLabel;

  /// Opens the time picker for the retroactive session's start.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get historyLogPastStartTimeLabel;

  /// Estimated duration in minutes, shown next to and on the duration slider.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String historyLogPastDurationMinutes(num minutes);

  /// Body screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get bodyTitle;

  /// Used as both the app-bar tooltip and the tracked-measurements sheet's own heading.
  ///
  /// In en, this message translates to:
  /// **'Measurements to track'**
  String get bodyMeasurementsToTrackAction;

  /// Error title if the bodyweight history query fails.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight history could not be read'**
  String get bodyReadError;

  /// Empty state before any bodyweight has been logged.
  ///
  /// In en, this message translates to:
  /// **'No bodyweight logged yet'**
  String get bodyEmptyTitle;

  /// Empty state message before any bodyweight has been logged.
  ///
  /// In en, this message translates to:
  /// **'Log your weight to track it alongside your lifts.'**
  String get bodyEmptyMessage;

  /// Used as the empty-state action, the FAB label, and the log sheet's own title when creating a new entry.
  ///
  /// In en, this message translates to:
  /// **'Log bodyweight'**
  String get bodyLogBodyweightAction;

  /// Heading above the bodyweight EMA trend chart.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get bodyTrendLabel;

  /// Weekly rate-of-change reading below the trend chart. value already carries its own +/- sign.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit}/week'**
  String bodyWeeklyRateLabel(String value, String unit);

  /// Confirm-swipe title before deleting a bodyweight or measurement entry.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get bodyDeleteEntryConfirmTitle;

  /// Confirm-swipe message before deleting a bodyweight entry.
  ///
  /// In en, this message translates to:
  /// **'{date}\'s bodyweight entry will be removed.'**
  String bodyDeleteBodyweightConfirmMessage(String date);

  /// Confirm-swipe message before deleting a non-bodyweight measurement entry.
  ///
  /// In en, this message translates to:
  /// **'{date}\'s {measurement} entry will be removed.'**
  String bodyDeleteMeasurementConfirmMessage(String date, String measurement);

  /// Used as both the per-measurement-section add tooltip and the log sheet's own title when creating a new entry.
  ///
  /// In en, this message translates to:
  /// **'Log {type}'**
  String bodyLogAction(String type);

  /// Shown under a tracked measurement's heading before any value has been logged.
  ///
  /// In en, this message translates to:
  /// **'Not logged yet.'**
  String get bodyNotLoggedYet;

  /// Log-bodyweight sheet title when editing an existing entry.
  ///
  /// In en, this message translates to:
  /// **'Edit bodyweight'**
  String get bodyLogWeightEditTitle;

  /// The weight value field label on the log-bodyweight sheet.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get bodyLogWeightFieldLabel;

  /// Opens the date picker on the log-bodyweight sheet.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bodyLogWeightDateLabel;

  /// Note field label on the log-bodyweight sheet.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get bodyLogWeightNoteLabel;

  /// Validation error when the weight field is empty or non-positive.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight'**
  String get bodyLogWeightRequiredError;

  /// Log-measurement sheet title when editing an existing entry.
  ///
  /// In en, this message translates to:
  /// **'Edit {label}'**
  String bodyLogMeasurementEditTitle(String label);

  /// Opens the date picker on the log-measurement sheet.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bodyLogMeasurementDateLabel;

  /// Note field label on the log-measurement sheet.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get bodyLogMeasurementNoteLabel;

  /// Validation error when the measurement field is empty or negative.
  ///
  /// In en, this message translates to:
  /// **'Enter a value'**
  String get bodyLogMeasurementRequiredError;

  /// Used as both the body screen's app-bar tooltip and the progress-photos screen's own title.
  ///
  /// In en, this message translates to:
  /// **'Progress photos'**
  String get bodyPhotosTitle;

  /// Exits compare-selection mode.
  ///
  /// In en, this message translates to:
  /// **'Cancel compare'**
  String get bodyPhotosCancelCompareTooltip;

  /// Enters compare-selection mode.
  ///
  /// In en, this message translates to:
  /// **'Compare two photos'**
  String get bodyPhotosCompareTwoTooltip;

  /// Shown if the photo list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load photos.'**
  String get bodyPhotosLoadError;

  /// Empty state before any progress photo has been added.
  ///
  /// In en, this message translates to:
  /// **'No progress photos yet'**
  String get bodyPhotosEmptyTitle;

  /// Empty state message before any progress photo has been added.
  ///
  /// In en, this message translates to:
  /// **'Add one to start a date-tagged record.'**
  String get bodyPhotosEmptyMessage;

  /// FAB label opening the two-photo comparison dialog.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get bodyPhotosCompareAction;

  /// Confirm sheet title before permanently deleting a progress photo.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo?'**
  String get bodyPhotosDeleteConfirmTitle;

  /// Confirm sheet message before permanently deleting a progress photo — no undo, unlike a soft delete.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the photo from this device.'**
  String get bodyPhotosDeleteConfirmMessage;

  /// Subtitle on the tracked-measurements sheet.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight is always logged. Turn on whichever of these you also want to track.'**
  String get bodyTrackedDescription;

  /// Consistency screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistencyTitle;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get consistencyCurrentStreakLabel;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get consistencyLongestStreakLabel;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Sessions / week'**
  String get consistencySessionsPerWeekLabel;

  /// A streak length in weeks, used for both the current- and longest-streak stat tiles.
  ///
  /// In en, this message translates to:
  /// **'{weeks} wk'**
  String consistencyStreakWeeks(num weeks);

  /// Explanatory footer describing how the streak and target work.
  ///
  /// In en, this message translates to:
  /// **'Target: {target} sessions a week. A streak is a run of complete weeks meeting it — the week in progress never breaks one, whatever it currently reads.'**
  String consistencyTargetExplanation(num target);

  /// PR timeline screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'PR timeline'**
  String get prTimelineTitle;

  /// Empty state before any personal record has been set.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get prTimelineEmptyTitle;

  /// Empty state message before any personal record has been set.
  ///
  /// In en, this message translates to:
  /// **'Every personal record you set will show up here.'**
  String get prTimelineEmptyMessage;

  /// Exercise filter dropdown's unset-state hint and its own "no filter" option.
  ///
  /// In en, this message translates to:
  /// **'All exercises'**
  String get prTimelineAllExercises;

  /// PR-kind filter dropdown's unset-state hint and its own "no filter" option.
  ///
  /// In en, this message translates to:
  /// **'All kinds'**
  String get prTimelineAllKinds;

  /// Empty state when the exercise/kind filters exclude every record.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get prTimelineNoMatchesTitle;

  /// PR description for a max-weight record — sentence case, since this is a standalone list-tile subtitle rather than SessionSummaryScreen's inline list item.
  ///
  /// In en, this message translates to:
  /// **'Heaviest set: {weight}'**
  String prTimelineHeaviestSet(String weight);

  /// PR description for a best-e1RM record — sentence case, see prTimelineHeaviestSet.
  ///
  /// In en, this message translates to:
  /// **'Best estimated 1RM: {e1rm}'**
  String prTimelineBestE1rm(String e1rm);

  /// PR description for a max-session-volume record — sentence case, see prTimelineHeaviestSet.
  ///
  /// In en, this message translates to:
  /// **'Most volume in a session: {volume}'**
  String prTimelineSessionVolume(String volume);

  /// PR-kind filter dropdown option.
  ///
  /// In en, this message translates to:
  /// **'Heaviest set'**
  String get prTimelineKindHeaviestSet;

  /// PR-kind filter dropdown option.
  ///
  /// In en, this message translates to:
  /// **'Best e1RM'**
  String get prTimelineKindBestE1rm;

  /// PR-kind filter dropdown option.
  ///
  /// In en, this message translates to:
  /// **'Most reps at a weight'**
  String get prTimelineKindMostReps;

  /// PR-kind filter dropdown option.
  ///
  /// In en, this message translates to:
  /// **'Most session volume'**
  String get prTimelineKindMostVolume;
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
