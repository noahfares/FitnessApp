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

  @override
  String get activeWorkoutTitle => 'Workout';

  @override
  String get activeWorkoutReadError => 'This workout could not be read';

  @override
  String get activeWorkoutNoneInProgress => 'No workout in progress.';

  @override
  String get activeWorkoutStartOne => 'Start one';

  @override
  String get activeWorkoutDiscardMenuItem => 'Discard workout';

  @override
  String get activeWorkoutEmptyTitle => 'No exercises yet';

  @override
  String get activeWorkoutEmptyMessage => 'Add the first one to start logging.';

  @override
  String activeWorkoutExerciseCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '$count exercise',
    );
    return '$_temp0';
  }

  @override
  String get activeWorkoutAddExercises => 'Add exercises';

  @override
  String get activeWorkoutFinish => 'Finish';

  @override
  String get activeWorkoutNothingLoggedTitle => 'Nothing logged yet';

  @override
  String get activeWorkoutNothingLoggedMessage =>
      'No sets were completed, so this would be an empty entry in your history. Discard it instead?';

  @override
  String get activeWorkoutKeepTraining => 'Keep training';

  @override
  String get activeWorkoutFinishAnyway => 'Finish anyway';

  @override
  String get activeWorkoutDiscardAction => 'Discard';

  @override
  String get activeWorkoutDiscardConfirmTitle => 'Discard this workout?';

  @override
  String get activeWorkoutDiscardTallyEmpty =>
      'Nothing has been added to it yet.';

  @override
  String activeWorkoutDiscardTally(num exercises, num sets) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercises',
      one: '$exercises exercise',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets completed sets',
      one: '$sets completed set',
    );
    return '$_temp0 and $_temp1 will be removed from this session.';
  }

  @override
  String get activeWorkoutStaleNotice =>
      'This workout has been open for more than 12 hours. Finish or discard it if you are done.';

  @override
  String activeWorkoutSetsDone(num completed, num total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total sets',
      one: '$total set',
    );
    return '$completed of $_temp0 done';
  }

  @override
  String activeWorkoutTargetPrefix(String summary) {
    return 'Target: $summary';
  }

  @override
  String get activeWorkoutAddNote => 'Add note';

  @override
  String get activeWorkoutEditNote => 'Edit note';

  @override
  String get activeWorkoutGenerateWarmups => 'Generate warm-ups';

  @override
  String get activeWorkoutSwapExercise => 'Swap exercise';

  @override
  String get activeWorkoutRemove => 'Remove';

  @override
  String get activeWorkoutUngroup => 'Ungroup';

  @override
  String get activeWorkoutGroupWithNext => 'Group with next';

  @override
  String get activeWorkoutSupersetBadge => 'Superset';

  @override
  String activeWorkoutRemoveExerciseConfirmTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String activeWorkoutRemoveExerciseConfirmMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed sets',
      one: '$count completed set',
    );
    return '$_temp0 will be removed from this session too.';
  }

  @override
  String activeWorkoutExerciseRemovedSnackbar(String name) {
    return '$name removed';
  }

  @override
  String get activeWorkoutUndo => 'Undo';

  @override
  String get activeWorkoutLastTimeHeader => 'Last time';

  @override
  String get startWorkoutTitle => 'Start';

  @override
  String get startWorkoutAlreadyTrainingTitle => 'Already training';

  @override
  String startWorkoutAlreadyTrainingMessage(String name) {
    return '\"$name\" is still in progress. Finish or discard it before starting another.';
  }

  @override
  String get startWorkoutResumeAction => 'Resume workout';

  @override
  String get startWorkoutFreshTitle => 'Start a workout';

  @override
  String get startWorkoutEmptySessionMessage =>
      'An empty session you add exercises to as you go.';

  @override
  String get startWorkoutStartEmptyAction => 'Start empty workout';

  @override
  String get startWorkoutFromRoutineTitle => 'Or start from a routine';

  @override
  String get startWorkoutNoRoutinesTitle => 'No routines yet';

  @override
  String get startWorkoutNoRoutinesMessage =>
      'Build one from the Routines tab.';

  @override
  String get sessionSummaryTitle => 'Workout complete';

  @override
  String get sessionSummaryReadError => 'This summary could not be read';

  @override
  String get sessionSummaryDone => 'Done';

  @override
  String get sessionSummaryNiceWork => 'Nice work.';

  @override
  String get sessionSummaryDurationLabel => 'Duration';

  @override
  String get sessionSummaryVolumeLabel => 'Volume';

  @override
  String get sessionSummarySetsLabel => 'Sets';

  @override
  String get sessionSummaryExercisesLabel => 'Exercises';

  @override
  String get sessionSummaryPersonalRecordsTitle => 'Personal records';

  @override
  String get sessionSummaryMusclesWorkedTitle => 'Muscles worked';

  @override
  String get sessionSummaryComparedToLastTime => 'Compared to last time';

  @override
  String sessionSummaryVolumeChange(String volume) {
    return '$volume volume';
  }

  @override
  String sessionSummaryPrHeaviestSet(String weight) {
    return 'heaviest set: $weight';
  }

  @override
  String sessionSummaryPrBestE1rm(String e1rm) {
    return 'best estimated 1RM: $e1rm';
  }

  @override
  String sessionSummaryPrRepsAtWeight(num reps, String weight) {
    return '$reps reps at $weight';
  }

  @override
  String sessionSummaryPrSessionVolume(String volume) {
    return 'most volume in a session: $volume';
  }

  @override
  String get routineEditorReadError => 'Routine could not be read';

  @override
  String get routineEditorNotFound => 'This routine no longer exists.';

  @override
  String get routineEditorDaysReadError => 'Days could not be read';

  @override
  String get routineEditorNoDaysMessage =>
      '\"Push\", \"Pull\", \"Legs\" — a day is what you start a workout from.';

  @override
  String get routineEditorAddDay => 'Add a day';

  @override
  String get routineEditorNewDayTitle => 'New day';

  @override
  String get routineEditorScheduleAction => 'Schedule';

  @override
  String get routineEditorExercisesReadError => 'Exercises could not be read';

  @override
  String get routineEditorMenuRename => 'Rename';

  @override
  String get routineEditorRenameDayTitle => 'Rename day';

  @override
  String get routineEditorRenameRoutineTitle => 'Rename routine';

  @override
  String get routineEditorDeleteDayConfirmMessage =>
      'Its exercises and targets will be removed.';

  @override
  String get routineDayEditorReadError => 'Day could not be read';

  @override
  String get routineDayEditorNotFound => 'This day no longer exists.';

  @override
  String get routineDayEditorWeekdayMon => 'Mon';

  @override
  String get routineDayEditorWeekdayTue => 'Tue';

  @override
  String get routineDayEditorWeekdayWed => 'Wed';

  @override
  String get routineDayEditorWeekdayThu => 'Thu';

  @override
  String get routineDayEditorWeekdayFri => 'Fri';

  @override
  String get routineDayEditorWeekdaySat => 'Sat';

  @override
  String get routineDayEditorWeekdaySun => 'Sun';

  @override
  String get routineDayEditorScheduleDescription =>
      'Optional — pick the weekdays you plan to train this day.';

  @override
  String get routineDayEditorEmptyTitle => 'No exercises yet';

  @override
  String get routineDayEditorEmptyMessage =>
      'Add exercises, then set targets for each.';

  @override
  String get routineDayEditorAddExercisesAction => 'Add exercises';

  @override
  String routineDayEditorSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get routineDayEditorMustBeAdjacent => 'Must be adjacent';

  @override
  String get routineDayEditorGroupAction => 'Group';

  @override
  String get routineDayEditorRemoveTooltip => 'Remove';

  @override
  String get routineDayEditorNoTargetsSet => 'No targets set';

  @override
  String get routineDayEditorSupersetLabel => 'Superset';

  @override
  String get routineDayEditorUngroupAction => 'Ungroup';

  @override
  String get routineDayEditorSetsLabel => 'Sets';

  @override
  String get routineDayEditorRepsMinLabel => 'Reps min';

  @override
  String get routineDayEditorRepsMaxLabel => 'Reps max';

  @override
  String routineDayEditorTargetWeightLabel(String unit) {
    return 'Target weight ($unit)';
  }

  @override
  String get routineDayEditorRestLabel => 'Rest';

  @override
  String get routineDayEditorRestHelperText =>
      'Overrides the exercise and global defaults.';

  @override
  String get routineDayEditorRestDefaultOption => 'Default';

  @override
  String get routineDayEditorProgressionHeading => 'Progression';

  @override
  String get routineDayEditorRuleManual => 'I\'ll decide';

  @override
  String get routineDayEditorRuleLinear => 'Add weight on success';

  @override
  String get routineDayEditorRuleDoubleProgression => 'Add reps, then weight';

  @override
  String get routineDayEditorRuleRpe => 'Match effort (RPE)';

  @override
  String get routineDayEditorRulePercent => '% of TM';

  @override
  String routineDayEditorLinearIncrementLabel(String unit) {
    return 'Add when I hit every set ($unit)';
  }

  @override
  String get routineDayEditorLinearHelperText =>
      'Repeats the same weight on a partial miss; deloads after three misses in a row.';

  @override
  String routineDayEditorDoubleProgressionLabel(String unit) {
    return 'Add when I hit the top of my rep range ($unit)';
  }

  @override
  String get routineDayEditorDoubleProgressionHelperText =>
      'Uses the Reps min/max above as the range. Deloads after three sessions in a row below the minimum.';

  @override
  String get routineDayEditorTargetRpeLabel => 'Target RPE';

  @override
  String get routineDayEditorTargetRpeHelperText =>
      'How hard the last set should feel. Comes in easier — add more; harder — add less or back off.';

  @override
  String routineDayEditorBaseStepLabel(String unit) {
    return 'Base step ($unit)';
  }

  @override
  String get routineDayEditorPercentLabel => 'Percent of training max';

  @override
  String get routineDayEditorPercentHelperNoTm =>
      'No training max set on this exercise yet — set one on the exercise\'s own editor first.';

  @override
  String routineDayEditorPercentHelperWithTm(String value, String unit) {
    return 'Training max: $value $unit. Recomputed every time this day is started — no week/cycle variation yet.';
  }

  @override
  String get routineDayEditorSaveTargets => 'Save targets';

  @override
  String get routineDayEditorPreviewTitle => 'Preview';

  @override
  String routineDayEditorDurationApprox(num minutes) {
    return '~$minutes min';
  }

  @override
  String get routineDayEditorNoData => '—';

  @override
  String get routineDayEditorSetsPerMuscleSubtitle => 'Sets per muscle';

  @override
  String get routineDayEditorSetTargetsMessage =>
      'Set targets to see sets per muscle here.';

  @override
  String get routineDayEditorStartWorkoutAction => 'Start workout';

  @override
  String get routineDayEditorAlreadyTrainingMessage =>
      'A workout is already in progress. Finish or discard it before starting another.';

  @override
  String get routineDayEditorResumeAction => 'Resume it';

  @override
  String get historyDetailTitle => 'Workout';

  @override
  String get historyDetailEditTooltip => 'Edit';

  @override
  String get historyDetailRepeatTooltip => 'Repeat this workout';

  @override
  String get historyDetailSaveAsRoutineAction => 'Save as routine';

  @override
  String get historyDetailDeleteConfirmTitle => 'Delete this workout?';

  @override
  String get historyDetailDeleteConfirmMessage =>
      'This session and all its sets will be removed from your history.';

  @override
  String get historyDetailNoExercisesTitle => 'No exercises in this session';

  @override
  String get historyEditTitle => 'Edit workout';

  @override
  String get historyEditDoneAction => 'Done';

  @override
  String get historyEditNameLabel => 'Name';

  @override
  String get historyEditDateLabel => 'Date';

  @override
  String get historyEditTimeLabel => 'Time';

  @override
  String get historyEditNotesLabel => 'Notes';

  @override
  String get historyEditEmptyTitle => 'No exercises yet';

  @override
  String get historyEditEmptyMessage => 'Add the first one below.';

  @override
  String get historyEditRemoveExerciseTooltip => 'Remove exercise';

  @override
  String get historyEditExerciseNoteLabel => 'Exercise note';

  @override
  String get historyEditRemoveExerciseConfirmMessage =>
      'Its sets in this session will be removed too.';

  @override
  String get historySetRowCompleteSemanticLabel => 'Complete set';

  @override
  String historySetRowDeletedSnackbar(String label) {
    return 'Set $label deleted';
  }

  @override
  String get historyLogPastSheetTitle => 'Log a past workout';

  @override
  String get historyLogPastNameLabel => 'Name (optional)';

  @override
  String get historyLogPastDateLabel => 'Date';

  @override
  String get historyLogPastStartTimeLabel => 'Start time';

  @override
  String historyLogPastDurationMinutes(num minutes) {
    return '$minutes min';
  }
}
