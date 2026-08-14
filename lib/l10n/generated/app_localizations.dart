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
