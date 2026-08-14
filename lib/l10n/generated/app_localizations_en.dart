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

  @override
  String get dashboardSettingsTooltip => 'Settings';

  @override
  String get dashboardReadyToTrain => 'Ready to train?';

  @override
  String get dashboardStartWorkout => 'Start a workout';

  @override
  String dashboardInProgress(String elapsed) {
    return 'In progress · $elapsed';
  }

  @override
  String dashboardTodaySchedule(String day) {
    return 'Today: $day';
  }

  @override
  String get dashboardNoBodyweight => 'No bodyweight logged yet';

  @override
  String get dashboardBodyweightHint => 'Log it to track alongside your lifts.';

  @override
  String get dashboardLogBodyweightTooltip => 'Log bodyweight';

  @override
  String get dashboardEmptyTitle => 'No workouts yet';

  @override
  String get dashboardEmptyMessage =>
      'Your finished sessions will show up here.';

  @override
  String get dashboardRecentWorkoutsError =>
      'Recent workouts could not be read';

  @override
  String dashboardExerciseCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '$count exercise',
    );
    return '$_temp0';
  }

  @override
  String get dashboardExercisesButton => 'Exercises';

  @override
  String get dashboardHistoryButton => 'History';

  @override
  String get dashboardRecentWorkoutsTitle => 'Recent workouts';

  @override
  String get historyTitle => 'History';

  @override
  String get historySearchHint => 'Search by workout or exercise';

  @override
  String get historyClearSearchTooltip => 'Clear search';

  @override
  String get historyReadError => 'History could not be read';

  @override
  String get historyNoResultsTitle => 'No sessions match';

  @override
  String get historyNoResultsMessage => 'Try a shorter search.';

  @override
  String get historyEmptyTitle => 'No sessions logged yet';

  @override
  String get historyEmptyMessage => 'Finished workouts show up here.';

  @override
  String get historyLogPastWorkout => 'Log past workout';

  @override
  String historyExerciseCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '$count exercise',
    );
    return '$_temp0';
  }

  @override
  String get confirmSheetDeleteLabel => 'Delete';

  @override
  String get confirmSheetKeepItLabel => 'Keep it';

  @override
  String get routinesTitle => 'Routines';

  @override
  String get routinesArchivedTitle => 'Archived routines';

  @override
  String get routinesShowActiveTooltip => 'Active routines';

  @override
  String get routinesStarterProgramsTooltip => 'Starter programs';

  @override
  String get routinesNewFolderAction => 'New folder';

  @override
  String get routinesNewRoutineAction => 'New routine';

  @override
  String get routinesReadError => 'Routines could not be read';

  @override
  String get routinesEmptyTitle => 'No routines yet';

  @override
  String get routinesEmptyMessage =>
      'A routine holds days; a day is what you start a workout from. A starter program is the fastest way to get one.';

  @override
  String get routinesBrowseStarterPrograms => 'Browse starter programs';

  @override
  String get routinesNoFolder => 'No folder';

  @override
  String get routinesArchivedReadError => 'Archived routines could not be read';

  @override
  String get routinesNothingArchivedTitle => 'Nothing archived';

  @override
  String get routinesNothingArchivedMessage =>
      'Archived routines stay startable and can be restored from here.';

  @override
  String get routinesNoDaysYet => 'No days yet';

  @override
  String get routinesRestoreTooltip => 'Restore';

  @override
  String get routinesMoveToFolderAction => 'Move to folder';

  @override
  String get routinesDuplicateAction => 'Duplicate';

  @override
  String get routinesArchiveAction => 'Archive';

  @override
  String get routinesDeleteAction => 'Delete';

  @override
  String routinesDeleteConfirmTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get routinesDeleteConfirmMessage =>
      'Its days and targets will be removed. Workouts you have already logged from it are never affected (`ADR-0004`).';

  @override
  String get routineNameFieldLabel => 'Name';

  @override
  String get routineNameDialogCancel => 'Cancel';

  @override
  String get routineNameDialogSave => 'Save';
}
