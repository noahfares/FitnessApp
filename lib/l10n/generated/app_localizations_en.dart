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

  @override
  String get catalogTitle => 'Exercises';

  @override
  String get catalogArchivedTitle => 'Archived exercises';

  @override
  String get catalogShowActiveTooltip => 'Active exercises';

  @override
  String get catalogArchiveByEquipment => 'Archive by equipment';

  @override
  String get catalogSearchHint => 'Search exercises';

  @override
  String get catalogClearSearchTooltip => 'Clear search';

  @override
  String get catalogReadError => 'The catalogue could not be read';

  @override
  String get catalogNewExercise => 'New exercise';

  @override
  String catalogArchiveEquipmentConfirmTitle(String equipment) {
    return 'Archive all $equipment exercises?';
  }

  @override
  String catalogArchiveEquipmentConfirmMessage(String equipment) {
    return 'Every non-archived $equipment exercise is hidden from pickers and search. History is untouched, and each can be restored individually from the archived list.';
  }

  @override
  String get catalogArchiveConfirmLabel => 'Archive';

  @override
  String catalogArchivedCount(num count, String equipment) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Archived $count $equipment exercises.',
      one: 'Archived $count $equipment exercise.',
      zero: 'Nothing to archive.',
    );
    return '$_temp0';
  }

  @override
  String get catalogArchivedReadError => 'Archived exercises could not be read';

  @override
  String get catalogNothingArchivedTitle => 'Nothing archived';

  @override
  String get catalogNothingArchivedMessage =>
      'Archived exercises stay in your history and can be restored from here.';

  @override
  String get catalogRestoreAction => 'Restore';

  @override
  String get catalogNoMatchTitle => 'No exercises match';

  @override
  String get catalogNoMatchMessage =>
      'Try a shorter search, or clear a filter.';

  @override
  String get catalogEmptyTitle => 'The catalogue is empty';

  @override
  String get catalogEmptyMessage =>
      'Seeding runs at startup; this should not happen.';

  @override
  String catalogFilteredCount(num shown, num total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total exercises',
      one: '$total exercise',
    );
    return '$shown of $_temp0';
  }

  @override
  String get catalogUnfavouriteTooltip => 'Unfavourite';

  @override
  String get catalogFavouriteTooltip => 'Favourite';

  @override
  String get catalogExerciseHistoryTooltip => 'History';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsNoSessionsTitle => 'No sessions yet';

  @override
  String get insightsNoSessionsMessage =>
      'Log a few workouts to see volume and muscle coverage here.';

  @override
  String get insightsConsistencyButton => 'Consistency';

  @override
  String get insightsPrTimelineButton => 'PR timeline';

  @override
  String get insightsMuscleBalanceTitle => 'Muscle balance';

  @override
  String get insightsMuscleBalanceSubtitle =>
      'Trailing 4 weeks. A rough guide, not a prescription.';

  @override
  String get insightsPushPullLabel => 'Push : pull';

  @override
  String get insightsQuadHamstringLabel => 'Quad : hamstring';

  @override
  String insightsRatioNoData(String label) {
    return '$label — no data recorded';
  }

  @override
  String get insightsTrainingLoadTitle => 'Training load';

  @override
  String get insightsAcwrInsufficientData =>
      'Needs at least 28 days of logged training to show.';

  @override
  String get insightsAcwrExplanation =>
      'Ratio of this week\'s volume to your trailing 4-week average (ACWR). 0.8–1.3 is typically described as a steady ramp rate; this is information, not a warning.';

  @override
  String get insightsDurationRestTitle => 'Duration & rest';

  @override
  String get insightsRestComplianceUnknown => 'not enough logged rest yet';

  @override
  String insightsRestCompliancePercent(num percent) {
    return '$percent% of prescribed rest';
  }

  @override
  String get insightsSessionDurationLabel => 'Session duration';

  @override
  String get insightsEveryFinishedSession => 'Every finished session';

  @override
  String get insightsRestComplianceExplanation =>
      'Average actual rest vs. each exercise\'s resolved default — an approximation, not a per-set historical record.';

  @override
  String get insightsMuscleHeatTitle => 'Muscle heat map';

  @override
  String get insightsMuscleHeatSubtitle => 'Relative training volume by muscle';

  @override
  String get insightsBodyMapFront => 'Front';

  @override
  String get insightsBodyMapBack => 'Back';

  @override
  String get insightsMuscleHeatExplanation =>
      'Relative to your hardest-trained muscle over the selected range.';

  @override
  String get insightsByMuscleTitle => 'By muscle';

  @override
  String insightsVolumeForMuscle(String muscle) {
    return 'Volume — $muscle';
  }

  @override
  String insightsHardSetsForMuscle(String muscle) {
    return 'Hard sets per week — $muscle';
  }

  @override
  String get insightsContributingExercises => 'Contributing exercises';

  @override
  String insightsContributingExercisesForWeek(String week) {
    return 'Contributing exercises — week of $week';
  }

  @override
  String get insightsClearAction => 'Clear';

  @override
  String insightsContributorSets(String sets) {
    return '$sets sets';
  }

  @override
  String get insightsOverallVolumeTitle => 'Overall weekly volume';

  @override
  String get insightsRangeFourWeeks => 'Last 4 weeks';

  @override
  String get insightsRangeThreeMonths => 'Last 3 months';

  @override
  String get insightsRangeSixMonths => 'Last 6 months';

  @override
  String get insightsRangeOneYear => 'Last year';

  @override
  String get insightsRangeAllTime => 'All time';

  @override
  String get insightsRangeCustom => 'Custom range';

  @override
  String get insightsRepRangesTitle => 'Rep ranges';

  @override
  String insightsRepRangeSubtitle(String range) {
    return '$range · sets by rep range';
  }

  @override
  String get insightsIntensityE1rmTitle => 'Intensity (% of e1RM)';

  @override
  String insightsIntensityE1rmSubtitle(String range) {
    return '$range · sets with a known e1RM baseline';
  }

  @override
  String get insightsIntensityRpeTitle => 'Intensity (RPE)';

  @override
  String get insightsIntensityRpeExplanation =>
      'A more honest measure than an e1RM estimate, where logged.';

  @override
  String insightsIntensityRpeSubtitle(String range) {
    return '$range · sets by RPE';
  }
}
