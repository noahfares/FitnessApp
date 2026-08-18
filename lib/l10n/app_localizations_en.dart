// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get analytics1Year => '1 year';

  @override
  String get analytics3Months => '3 months';

  @override
  String get analytics4Weeks => '4 weeks';

  @override
  String get analytics6Months => '6 months';

  @override
  String get analyticsAMoreHonestMeasureThan =>
      'A more honest measure than an e1RM estimate, where logged.';

  @override
  String get analyticsAcwrExplainer =>
      'Ratio of this week\'s volume to your trailing 4-week average (ACWR). 0.8–1.3 is typically described as a steady ramp rate; this is information, not a warning.';

  @override
  String get analyticsAllExercises => 'All exercises';

  @override
  String get analyticsAllKinds => 'All kinds';

  @override
  String get analyticsAllTime => 'All time';

  @override
  String get analyticsBack => 'Back';

  @override
  String get analyticsBestE1rm => 'Best e1RM';

  @override
  String get analyticsByMuscle => 'By muscle';

  @override
  String get analyticsConsistency => 'Consistency';

  @override
  String get analyticsContributingExercises => 'Contributing exercises';

  @override
  String analyticsContributingExercisesForWeek(String week) {
    return 'Contributing exercises — week of $week';
  }

  @override
  String analyticsContributorSets(String sets) {
    return '$sets sets';
  }

  @override
  String get analyticsCore => 'Core';

  @override
  String get analyticsCurrentStreak => 'Current streak';

  @override
  String get analyticsCustomRange => 'Custom range';

  @override
  String get analyticsDeloadSuggestedHeading =>
      'Deload suggested — not automatic, this is your call:';

  @override
  String get analyticsDurationRest => 'Duration & rest';

  @override
  String get analyticsE1rmTrend => 'e1RM trend';

  @override
  String get analyticsEstimatedOneRepMax => 'Estimated one-rep max';

  @override
  String get analyticsEveryFinishedSession => 'Every finished session';

  @override
  String get analyticsEveryPersonalRecordYouSet =>
      'Every personal record you set will show up here.';

  @override
  String get analyticsExcludeSetsOver12Reps => 'Exclude sets over 12 reps';

  @override
  String get analyticsExerciseHistory => 'Exercise history';

  @override
  String analyticsFormulaLabel(String formula) {
    return 'Formula: $formula';
  }

  @override
  String get analyticsFront => 'Front';

  @override
  String analyticsHardSetsForMuscle(String muscle) {
    return 'Hard sets per week — $muscle';
  }

  @override
  String get analyticsHardSetsPerWeekFor =>
      'Hard sets per week for the selected muscle';

  @override
  String get analyticsHeatRelativeCaveat =>
      'Relative to your hardest-trained muscle over the selected range.';

  @override
  String get analyticsHeaviestSet => 'Heaviest set';

  @override
  String get analyticsInsights => 'Insights';

  @override
  String get analyticsIntensityOfE1rm => 'Intensity (% of e1RM)';

  @override
  String get analyticsIntensityRpe => 'Intensity (RPE)';

  @override
  String get analyticsLast3Months => 'Last 3 months';

  @override
  String get analyticsLast4Weeks => 'Last 4 weeks';

  @override
  String get analyticsLast6Months => 'Last 6 months';

  @override
  String get analyticsLastYear => 'Last year';

  @override
  String get analyticsLegs => 'Legs';

  @override
  String get analyticsLinearRegressionOverlay => 'Linear regression overlay';

  @override
  String get analyticsLogAFewWorkoutsTo =>
      'Log a few workouts to see volume and muscle coverage here.';

  @override
  String get analyticsLogThisExerciseInA =>
      'Log this exercise in a workout to see it here.';

  @override
  String get analyticsLongestStreak => 'Longest streak';

  @override
  String get analyticsMostRepsAtAWeight => 'Most reps at a weight';

  @override
  String get analyticsMostSessionVolume => 'Most session volume';

  @override
  String get analyticsMuscleBalance => 'Muscle balance';

  @override
  String get analyticsMuscleHeatMap => 'Muscle heat map';

  @override
  String get analyticsNeedsAtLeast28Days =>
      'Needs at least 28 days of logged training to show.';

  @override
  String get analyticsNoMatches => 'Nothing matches these filters';

  @override
  String get analyticsNoRecordsYet => 'No records yet';

  @override
  String get analyticsNoSessionsYet => 'No sessions yet';

  @override
  String get analyticsNotEnoughLoggedRestYet => 'not enough logged rest yet';

  @override
  String get analyticsOverallWeeklyVolume => 'Overall weekly volume';

  @override
  String get analyticsPrTimeline => 'PR timeline';

  @override
  String get analyticsPull => 'Pull';

  @override
  String get analyticsPush => 'Push';

  @override
  String get analyticsPushPull => 'Push : pull';

  @override
  String get analyticsQuadHamstring => 'Quad : hamstring';

  @override
  String get analyticsReferenceBand =>
      'Shaded: 10–20 hard sets a week, a commonly cited range for a muscle group. A guide, not a target.';

  @override
  String get analyticsRelativeVolumeByMuscle =>
      'Relative training volume by muscle';

  @override
  String get analyticsRepRanges => 'Rep ranges';

  @override
  String get analyticsRestComplianceCaveat =>
      'Average actual rest vs. each exercise\'s resolved default — an approximation, not a per-set historical record.';

  @override
  String get analyticsScheduleAdherence => 'Against your schedule';

  @override
  String analyticsScheduleAdherenceValue(
    int percent,
    int trained,
    int scheduled,
  ) {
    return '$percent% — you trained $trained of $scheduled scheduled days in the last 4 weeks.';
  }

  @override
  String get analyticsSessionDuration => 'Session duration';

  @override
  String get analyticsSessionDurationInMinutes => 'Session duration in minutes';

  @override
  String get analyticsSessionsWeek => 'Sessions / week';

  @override
  String get analyticsSetsByIntensityZone => 'Sets by intensity zone';

  @override
  String get analyticsSetsByLoggedRpe => 'Sets by logged RPE';

  @override
  String get analyticsSetsByRepRange => 'Sets by rep range';

  @override
  String analyticsStallExplainer(int sessions) {
    return 'e1RM has been flat over the last $sessions sessions. Consider a deload, a rep-range change, or an exercise variation.';
  }

  @override
  String analyticsStreakExplainer(int target) {
    return 'Target: $target sessions a week. A streak is a run of complete weeks meeting it — the week in progress never breaks one, whatever it currently reads.';
  }

  @override
  String get analyticsThisExercise => 'This exercise';

  @override
  String get analyticsThisMuscle => 'This muscle';

  @override
  String get analyticsTrailing4WeeksARough =>
      'Trailing 4 weeks. A rough guide, not a prescription.';

  @override
  String get analyticsTrainingLoad => 'Training load';

  @override
  String get analyticsTrendLine => 'Trend line';

  @override
  String get analyticsUnreliableAtHighRepCounts =>
      'Unreliable at high rep counts';

  @override
  String analyticsUnscheduledSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Plus $count sessions on unscheduled days. Extra sessions never count against this.',
      one:
          'Plus 1 session on an unscheduled day. Extra sessions never count against this.',
    );
    return '$_temp0';
  }

  @override
  String analyticsVolumeForMuscle(String muscle) {
    return 'Volume — $muscle';
  }

  @override
  String get analyticsWeeklyTarget => 'Sessions a week you are aiming for';

  @override
  String get analyticsWeeklyVolume => 'Weekly volume';

  @override
  String get analyticsWeeklyVolumeForMuscle =>
      'Weekly volume for the selected muscle';

  @override
  String get appTitle => 'FitnessApp';

  @override
  String get bodyAddOneToStartA => 'Add one to start a date-tagged record.';

  @override
  String get bodyBody => 'Body';

  @override
  String get bodyBodyweightHistoryCouldNotBe =>
      'Bodyweight history could not be read';

  @override
  String get bodyBodyweightTrend => 'Bodyweight trend';

  @override
  String get bodyCancelCompare => 'Cancel compare';

  @override
  String get bodyClearGoal => 'Clear goal';

  @override
  String get bodyCompare => 'Compare';

  @override
  String get bodyCompareTwoPhotos => 'Compare two photos';

  @override
  String get bodyCouldNotLoadPhotos => 'Could not load photos.';

  @override
  String bodyDeleteEntryExplainer(String date, String type) {
    return 'The $type entry from $date will be removed.';
  }

  @override
  String get bodyDeleteThisEntry => 'Delete this entry?';

  @override
  String get bodyDeleteThisPhoto => 'Delete this photo?';

  @override
  String get bodyEditBodyweight => 'Edit bodyweight';

  @override
  String bodyEditMeasurement(String type) {
    return 'Edit $type';
  }

  @override
  String get bodyEnterAValue => 'Enter a value';

  @override
  String get bodyEnterAWeight => 'Enter a weight';

  @override
  String get bodyGoal => 'Goal';

  @override
  String get bodyGoalExplainer =>
      'Drawn as a dashed line on the trend. A target, not a prediction — nothing else in the app reads it.';

  @override
  String get bodyLogBodyweight => 'Log bodyweight';

  @override
  String bodyLogMeasurement(String type) {
    return 'Log $type';
  }

  @override
  String get bodyLogYourWeightToTrack =>
      'Log your weight to track it alongside your lifts.';

  @override
  String get bodyMeasurementsToTrack => 'Measurements to track';

  @override
  String get bodyNoBodyweightLoggedYet => 'No bodyweight logged yet';

  @override
  String get bodyNoProgressPhotosYet => 'No progress photos yet';

  @override
  String get bodyNotLoggedYet => 'Not logged yet.';

  @override
  String get bodyNoteOptional => 'Note (optional)';

  @override
  String get bodyProgressPhotos => 'Progress photos';

  @override
  String get bodySetGoal => 'Set a bodyweight goal';

  @override
  String get bodyThisPermanentlyRemovesThePhoto =>
      'This permanently removes the photo from this device.';

  @override
  String get bodyTrackedTypesExplainer =>
      'Bodyweight is always logged. Turn on whichever of these you also want to track.';

  @override
  String get bodyTrend => 'Trend';

  @override
  String get bodyWeight => 'Weight';

  @override
  String get catalogActiveExercises => 'Active exercises';

  @override
  String get catalogAddAlias => 'Add alias';

  @override
  String get catalogAddAnAlias => 'Add an alias';

  @override
  String get catalogAliases => 'Aliases';

  @override
  String get catalogAliasesHint =>
      'Other names this is searchable by — \"RDL\" for Romanian Deadlift.';

  @override
  String get catalogAnotherExerciseAlreadyHasThis =>
      'Another exercise already has this name. That is allowed.';

  @override
  String get catalogArchive => 'Archive';

  @override
  String catalogArchiveAllExplainer(String equipment) {
    return 'Every non-archived $equipment exercise is hidden from pickers and search. History is untouched, and each can be restored individually from the archived list.';
  }

  @override
  String catalogArchiveAllTitle(String equipment) {
    return 'Archive all $equipment exercises?';
  }

  @override
  String get catalogArchiveByEquipment => 'Archive by equipment';

  @override
  String get catalogArchiveConfirmExplainer =>
      'Archiving hides an exercise from pickers without touching any workout it appears in.';

  @override
  String get catalogArchiveInstead => 'Archive instead';

  @override
  String get catalogArchivedExercises => 'Archived exercises';

  @override
  String get catalogArchivedExercisesCouldNotBe =>
      'Archived exercises could not be read';

  @override
  String get catalogArchivedExplainer =>
      'Archived exercises stay in your history and can be restored from here.';

  @override
  String get catalogAvailableWeights => 'Available weights';

  @override
  String get catalogBar => 'Bar';

  @override
  String get catalogBase => 'Base';

  @override
  String get catalogBlankUses100TheFull =>
      'Blank uses 100% — the full bodyweight.';

  @override
  String catalogBlankUsesDefault(String defaultLabel) {
    return 'Blank uses the default, $defaultLabel.';
  }

  @override
  String get catalogBodyweightLoaded => 'Bodyweight loaded';

  @override
  String get catalogBuiltInExerciseYourEdits =>
      'Built-in exercise — your edits survive catalogue updates';

  @override
  String get catalogCancel => 'Cancel';

  @override
  String get catalogClear => 'Clear';

  @override
  String get catalogClearAll => 'Clear all';

  @override
  String get catalogClearSearch => 'Clear search';

  @override
  String get catalogCreateExercise => 'Create exercise';

  @override
  String get catalogCustomExercise => 'Custom exercise';

  @override
  String get catalogDecidesWhichInputsTheLogger =>
      'Decides which inputs the logger shows.';

  @override
  String get catalogDefault => 'Default';

  @override
  String get catalogDelete => 'Delete';

  @override
  String catalogDeleteExerciseTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get catalogDeleteUnusedExplainer =>
      'It will be removed from the catalogue. Nothing else is affected — this exercise has never been logged.';

  @override
  String get catalogDeriveFromBestE1rm90 => 'Derive from best e1RM (~90%)';

  @override
  String get catalogEditExercise => 'Edit exercise';

  @override
  String get catalogEquipment => 'Equipment';

  @override
  String get catalogExercise => 'Exercise';

  @override
  String get catalogExerciseNote => 'Exercise note';

  @override
  String get catalogExerciseNoteHint =>
      'Seat height, pin position, grip width — visible inline during a session.';

  @override
  String get catalogFilter => 'Filter';

  @override
  String get catalogFixedDumbbells => 'Fixed dumbbells';

  @override
  String get catalogFixedIncrementsHint =>
      'Comma-separated, e.g. \"5, 10, 15, 20\" — exactly what the rack stocks.';

  @override
  String get catalogHalfStep => 'Half step';

  @override
  String get catalogHistory => 'History';

  @override
  String get catalogMuscle => 'Muscle';

  @override
  String get catalogName => 'Name';

  @override
  String get catalogNewExercise => 'New exercise';

  @override
  String get catalogNoLoggedHistoryForThis =>
      'No logged history for this exercise yet.';

  @override
  String get catalogNotes => 'Notes';

  @override
  String get catalogNothingArchived => 'Nothing archived';

  @override
  String get catalogNothingToArchive => 'Nothing to archive.';

  @override
  String get catalogOptional => 'Optional';

  @override
  String get catalogPerSide => 'Per side';

  @override
  String get catalogPerSideIsDoubledAnd =>
      'Per side is doubled and stored as total load.';

  @override
  String get catalogPlateLoaded => 'Plate-loaded';

  @override
  String get catalogPrimaryMuscle => 'Primary muscle';

  @override
  String get catalogRestOverrideHint =>
      'Overrides the global default for this exercise.';

  @override
  String get catalogRestTimer => 'Rest timer';

  @override
  String get catalogRestore => 'Restore';

  @override
  String get catalogSave => 'Save';

  @override
  String get catalogSearchExercises => 'Search exercises';

  @override
  String get catalogSeatHeight4PinPosition => 'Seat height 4, pin position 6…';

  @override
  String get catalogSecondaryMuscles => 'Secondary muscles';

  @override
  String get catalogSeedingRunsAtStartupThis =>
      'Seeding runs at startup; this should not happen.';

  @override
  String catalogShownOfTotal(int shown, int total) {
    return '$shown of $total exercises';
  }

  @override
  String get catalogStep => 'Step';

  @override
  String get catalogStepperIncrement => 'Stepper increment';

  @override
  String get catalogTheCatalogueCouldNotBe => 'The catalogue could not be read';

  @override
  String get catalogTheCatalogueIsEmpty => 'The catalogue is empty';

  @override
  String get catalogThisExercise => 'this exercise';

  @override
  String get catalogThisExerciseNoLongerExists =>
      'This exercise no longer exists.';

  @override
  String get catalogTotalLoad => 'Total load';

  @override
  String get catalogTracking => 'Tracking';

  @override
  String get catalogTrainingMax => 'Training max';

  @override
  String get catalogTrainingMaxHint => 'Used by percentage-based progression.';

  @override
  String get catalogTryAShorterSearchOr =>
      'Try a shorter search, or clear a filter.';

  @override
  String get catalogUsedInPastWorkouts => 'Used in past workouts';

  @override
  String catalogUsedInPastWorkoutsExplainer(String name) {
    return '$name appears in workouts you have already logged, so it cannot be deleted without breaking that history.\\n\\nArchiving hides it from pickers and leaves your history intact.';
  }

  @override
  String get catalogWeightEntry => 'Weight entry';

  @override
  String get catalogWeightSource => 'Weight source';

  @override
  String get catalogWeightStack => 'Weight stack';

  @override
  String get equipmentBand => 'Band';

  @override
  String get equipmentBarbell => 'Barbell';

  @override
  String get equipmentBodyweight => 'Bodyweight';

  @override
  String get equipmentCable => 'Cable';

  @override
  String get equipmentDumbbell => 'Dumbbell';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentMachine => 'Machine';

  @override
  String get equipmentOther => 'Other';

  @override
  String get healthExplainer =>
      'Off by default. Health Connect is Android\'s own on-device store — nothing here involves a network or an account, but it is still another app\'s copy of your training, so it asks first.';

  @override
  String get healthImportBodyweightExplainer =>
      'The last year, skipping days you already logged.';

  @override
  String get healthImportBodyweightNow => 'Import bodyweight now';

  @override
  String healthImportResult(int imported, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      imported,
      locale: localeName,
      other: '$imported entries imported.',
      one: '1 entry imported.',
      zero: 'Nothing new to import.',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: ' $skipped days skipped — you had already logged them.',
      one: ' 1 day skipped — you had already logged it.',
      zero: '',
    );
    return '$_temp0$_temp1';
  }

  @override
  String get healthNeverSentAnywhere =>
      'This app still makes no network calls. Health Connect is on your device, and what you share with it is governed by its own settings.';

  @override
  String get healthPermissionDenied =>
      'Permission was not granted, so nothing is shared. Everything else works exactly as before.';

  @override
  String get healthReadBodyweight => 'Read bodyweight';

  @override
  String get healthReadBodyweightExplainer =>
      'Lets a smart scale fill in your bodyweight log. Entries you made here always win for the same day.';

  @override
  String get healthTitle => 'Health Connect';

  @override
  String get healthWriteWorkouts => 'Write finished workouts';

  @override
  String get healthWriteWorkoutsExplainer =>
      'Each finished session is written as a strength-training workout: start time and duration, nothing else. No calorie estimate — a made-up number in your health record is worse than no number.';

  @override
  String get historyAddASetNote => 'Add a set note';

  @override
  String get historyAddExercises => 'Add exercises';

  @override
  String get historyAddTheFirstOneBelow => 'Add the first one below.';

  @override
  String get historyAlreadyTraining => 'Already training';

  @override
  String get historyAlreadyTrainingExplainer =>
      'A workout is already in progress. Finish or discard it before starting another.';

  @override
  String get historyCompleteSet => 'Complete set';

  @override
  String get historyDate => 'Date';

  @override
  String get historyDeleteThisWorkout => 'Delete this workout?';

  @override
  String get historyDeleteWorkoutExplainer =>
      'This session and all its sets will be removed from your history.';

  @override
  String get historyDeleteWorkoutHealthExplainer =>
      'This session and all its sets will be removed from your history, and the copy in Health Connect will be removed too.';

  @override
  String get historyDone => 'Done';

  @override
  String get historyDuration => 'Duration';

  @override
  String get historyEdit => 'Edit';

  @override
  String get historyEditSetNote => 'Edit set note';

  @override
  String get historyEditWorkout => 'Edit workout';

  @override
  String get historyExercises => 'Exercises';

  @override
  String get historyFinishedWorkoutsShowUpHere =>
      'Finished workouts show up here.';

  @override
  String get historyHistoryCouldNotBeRead => 'History could not be read';

  @override
  String get historyItsSetsInThisSession =>
      'Its sets in this session will be removed too.';

  @override
  String get historyLogAPastWorkout => 'Log a past workout';

  @override
  String get historyLogPastWorkout => 'Log past workout';

  @override
  String get historyNameOptional => 'Name (optional)';

  @override
  String get historyNoExercisesInThisSession => 'No exercises in this session';

  @override
  String get historyNoExercisesYet => 'No exercises yet';

  @override
  String get historyNoSessionsLoggedYet => 'No sessions logged yet';

  @override
  String get historyNoSessionsMatch => 'No sessions match';

  @override
  String get historyRemove => 'Remove';

  @override
  String get historyRemoveExercise => 'Remove exercise';

  @override
  String historyRemoveExerciseTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get historyRepeatThisWorkout => 'Repeat this workout';

  @override
  String get historyResumeIt => 'Resume it';

  @override
  String get historySaveAsRoutine => 'Save as routine';

  @override
  String get historySearchByWorkoutOrExercise =>
      'Search by workout or exercise';

  @override
  String get historyStartTime => 'Start time';

  @override
  String get historyTime => 'Time';

  @override
  String get historyTryAShorterSearch => 'Try a shorter search.';

  @override
  String get historyUndo => 'Undo';

  @override
  String get historyWorkout => 'Workout';

  @override
  String get loggingAddAtLeastOneStep => 'Add at least one step';

  @override
  String loggingAddCount(int count) {
    return 'Add $count';
  }

  @override
  String get loggingAddExercises => 'Add exercises';

  @override
  String get loggingAddNote => 'Add note';

  @override
  String get loggingAddSet => 'Add set';

  @override
  String get loggingAddStep => 'Add step';

  @override
  String get loggingAddTheFirstOneTo => 'Add the first one to start logging.';

  @override
  String loggingAlreadyTrainingExplainer(String name) {
    return '\"$name\" is still in progress. Finish or discard it before starting another.';
  }

  @override
  String get loggingAnEmptySessionYouAdd =>
      'An empty session you add exercises to as you go.';

  @override
  String get loggingBarOnlyNoPlatesNeeded => 'Bar only — no plates needed.';

  @override
  String get loggingBuildOneFromTheRoutines =>
      'Build one from the Routines tab.';

  @override
  String loggingClosestAbove(String weight) {
    return 'Closest above: $weight';
  }

  @override
  String loggingClosestBelow(String weight) {
    return 'Closest below: $weight';
  }

  @override
  String get loggingComparedToLastTime => 'Compared to last time';

  @override
  String get loggingCompleted => 'completed';

  @override
  String get loggingCountsTowardVolumeAndRecords =>
      'Counts toward volume and records.';

  @override
  String get loggingDecimalPoint => 'Decimal point';

  @override
  String get loggingDecrease => 'Decrease';

  @override
  String get loggingDiscard => 'Discard';

  @override
  String loggingDiscardTally(int exercises, int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercises',
      one: '1 exercise',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets completed sets',
      one: '1 completed set',
    );
    return '$_temp0 and $_temp1 will be removed from this session.';
  }

  @override
  String get loggingDiscardThisWorkout => 'Discard this workout?';

  @override
  String get loggingDiscardWorkout => 'Discard workout';

  @override
  String get loggingDropSet => 'Drop set';

  @override
  String get loggingEditNote => 'Edit note';

  @override
  String get loggingEmptySessionExplainer =>
      'No sets were completed, so this would be an empty entry in your history. Discard it instead?';

  @override
  String get loggingEnterTheWorkingWeight => 'Enter the working weight';

  @override
  String loggingExactMatch(String weight) {
    return 'Exact match: $weight';
  }

  @override
  String get loggingExerciseNoLongerExists => 'This exercise no longer exists.';

  @override
  String loggingExerciseRemoved(String name) {
    return '$name removed';
  }

  @override
  String get loggingExercisesCouldNotBeRead => 'Exercises could not be read';

  @override
  String get loggingFinish => 'Finish';

  @override
  String get loggingFinishAnyway => 'Finish anyway';

  @override
  String get loggingGenerateWarmUps => 'Generate warm-ups';

  @override
  String get loggingGroupWithNext => 'Group with next';

  @override
  String get loggingIncrease => 'Increase';

  @override
  String get loggingKeepTraining => 'Keep training';

  @override
  String get loggingLastTime => 'Last time';

  @override
  String get loggingLeftShoulderTwingedBeltToo =>
      'Left shoulder twinged, belt too loose…';

  @override
  String get loggingMusclesWorked => 'Muscles worked';

  @override
  String get loggingNiceWork => 'Nice work.';

  @override
  String get loggingNoBarConfigured =>
      'No bar configured yet — add one in Settings › Bars & plates.';

  @override
  String get loggingNoExercisesMatch => 'No exercises match';

  @override
  String get loggingNoRoutinesYet => 'No routines yet';

  @override
  String get loggingNoStackConfigured =>
      'No stack configured yet — add its base and step weight on this exercise\'s editor.';

  @override
  String get loggingNoWorkoutInProgress => 'No workout in progress.';

  @override
  String get loggingNotCompleted => 'not completed';

  @override
  String get loggingNothingHasBeenAddedTo =>
      'Nothing has been added to it yet.';

  @override
  String get loggingNothingLoggedYet => 'Nothing logged yet';

  @override
  String get loggingNumberedW1W2ExcludedFrom =>
      'Numbered W1, W2. Excluded from every figure.';

  @override
  String get loggingOfWorkingWeight => '% of working weight';

  @override
  String get loggingOrStartFromARoutine => 'Or start from a routine';

  @override
  String loggingPerSide(String plates) {
    return 'Per side: $plates';
  }

  @override
  String get loggingPersonalRecords => 'Personal records';

  @override
  String get loggingPlateCalculator => 'Plate calculator';

  @override
  String loggingPlatesPerSide(String plates) {
    return 'Plates per side: $plates';
  }

  @override
  String get loggingRamp => 'Ramp';

  @override
  String get loggingRateOfPerceivedExertionHigher =>
      'Rate of perceived exertion — higher is harder.';

  @override
  String loggingRemoveExerciseTally(int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets completed sets will be removed from this session too.',
      one: '1 completed set will be removed from this session too.',
      zero: 'No sets have been completed for it.',
    );
    return '$_temp0';
  }

  @override
  String loggingRemoveExerciseTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get loggingRemoveStep => 'Remove step';

  @override
  String get loggingReps => 'Reps';

  @override
  String get loggingRepsInReserveLowerIs =>
      'Reps in reserve — lower is harder.';

  @override
  String get loggingResetToDefault => 'Reset to default';

  @override
  String get loggingResumeWorkout => 'Resume workout';

  @override
  String loggingSetDeleted(String label) {
    return 'Set $label deleted';
  }

  @override
  String get loggingSetNote => 'Set note';

  @override
  String get loggingSetType => 'Set type';

  @override
  String get loggingSets => 'Sets';

  @override
  String loggingSetsDone(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total sets',
      one: '1 set',
    );
    return '$done of $_temp0 done';
  }

  @override
  String loggingStackBaseStep(String base, String step) {
    return 'Base $base, step $step';
  }

  @override
  String loggingStackHalfStep(String step) {
    return ', half step $step';
  }

  @override
  String get loggingStaleSessionNotice =>
      'This workout has been open for more than 12 hours. Finish or discard it if you are done.';

  @override
  String get loggingStart => 'Start';

  @override
  String get loggingStartAWorkout => 'Start a workout';

  @override
  String get loggingStartEmptyWorkout => 'Start empty workout';

  @override
  String get loggingStartOne => 'Start one';

  @override
  String get loggingStartStopwatch => 'Start stopwatch';

  @override
  String get loggingStopStopwatch => 'Stop stopwatch';

  @override
  String get loggingSuperset => 'Superset';

  @override
  String get loggingSwapExercise => 'Swap exercise';

  @override
  String get loggingTargetIsBelowTheBar =>
      'Target is below the bar itself — nothing to load.';

  @override
  String get loggingTargetIsBelowTheStack =>
      'Target is below the stack\'s own minimum.';

  @override
  String loggingTargetSummary(String summary) {
    return 'Target: $summary';
  }

  @override
  String get loggingThisSummaryCouldNotBe => 'This summary could not be read';

  @override
  String get loggingThisWorkoutCouldNotBe => 'This workout could not be read';

  @override
  String get loggingToFailure => 'To failure';

  @override
  String get loggingUnknownExercise => 'Unknown exercise';

  @override
  String get loggingVolume => 'Volume';

  @override
  String get loggingWorkingWeight => 'Working weight';

  @override
  String get loggingWorkoutComplete => 'Workout complete';

  @override
  String get measurementBodyFatPercent => 'Body fat';

  @override
  String get measurementBodyweight => 'Bodyweight';

  @override
  String get measurementChest => 'Chest';

  @override
  String get measurementHips => 'Hips';

  @override
  String get measurementLeftArm => 'Left arm';

  @override
  String get measurementLeftCalf => 'Left calf';

  @override
  String get measurementLeftThigh => 'Left thigh';

  @override
  String get measurementNeck => 'Neck';

  @override
  String get measurementRightArm => 'Right arm';

  @override
  String get measurementRightCalf => 'Right calf';

  @override
  String get measurementRightThigh => 'Right thigh';

  @override
  String get measurementShoulders => 'Shoulders';

  @override
  String get measurementWaist => 'Waist';

  @override
  String get muscleAbductors => 'Abductors';

  @override
  String get muscleAbs => 'Abs';

  @override
  String get muscleAdductors => 'Adductors';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleCalves => 'Calves';

  @override
  String get muscleChest => 'Chest';

  @override
  String get muscleForearms => 'Forearms';

  @override
  String get muscleFrontDelts => 'Front delts';

  @override
  String get muscleFullBody => 'Full body';

  @override
  String get muscleGlutes => 'Glutes';

  @override
  String get muscleHamstrings => 'Hamstrings';

  @override
  String get muscleLats => 'Lats';

  @override
  String get muscleLowerBack => 'Lower back';

  @override
  String get muscleNeck => 'Neck';

  @override
  String get muscleObliques => 'Obliques';

  @override
  String get muscleQuads => 'Quads';

  @override
  String get muscleRearDelts => 'Rear delts';

  @override
  String get muscleSideDelts => 'Side delts';

  @override
  String get muscleTraps => 'Traps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleUpperBack => 'Upper back';

  @override
  String get onboardingAppearance => 'Appearance';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingProgramBody =>
      'Optional. Pick one to get a routine ready to train tomorrow, or build your own later.';

  @override
  String get onboardingProgramLater =>
      'More programs live under Routines, and nothing here is permanent — every routine can be edited or deleted.';

  @override
  String get onboardingProgramTitle => 'Start from a program?';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStartTraining => 'Start training';

  @override
  String get onboardingUnitsBody =>
      'Display only — nothing stored ever changes, so you can switch back at any time without touching a single logged set.';

  @override
  String get onboardingUnitsTitle => 'Kilograms or pounds?';

  @override
  String get onboardingWeightUnit => 'Weight';

  @override
  String get onboardingWelcomeBody =>
      'Unlimited routines, real analytics, and your data on your own device. No account, no subscription, and nothing to sign up for.';

  @override
  String get onboardingWelcomeTitle => 'Everything, free';

  @override
  String progressionCarriedForward(int reps, String weight, String unit) {
    return 'Carried forward from last time: $reps at $weight $unit.';
  }

  @override
  String progressionDeload(int failures, String weight, String unit) {
    return 'Missed target $failures sessions in a row — deloading to $weight $unit.';
  }

  @override
  String progressionFailure(int failures) {
    return 'Missed target last time ($failures in a row) — repeating the same weight.';
  }

  @override
  String get progressionFirstRun =>
      'No history for this exercise yet — using the routine\'s own target.';

  @override
  String get progressionFromTrainingMax => 'Computed from your training max.';

  @override
  String get progressionPartial =>
      'Some sets missed target last time — repeating the same weight.';

  @override
  String progressionPercentOfTrainingMax(
    int percent,
    String weight,
    String unit,
  ) {
    return '$percent% of your training max ($weight $unit).';
  }

  @override
  String progressionPlateRoundingHeld(String weight, String unit) {
    return 'The next jump isn\'t assemblable from your plates, so weight stays at $weight $unit and reps go up by one instead.';
  }

  @override
  String progressionRepRangeTopMet(String weight, String unit, String delta) {
    return 'You hit the top of your rep range at $weight $unit last time, so this is +$delta $unit — back to the bottom of the range.';
  }

  @override
  String progressionSuccess(String weight, String unit, String delta) {
    return 'You hit every set at $weight $unit last time, so this is +$delta $unit.';
  }

  @override
  String get restAlertBoth => 'Sound and vibration';

  @override
  String get restAlertSilent => 'Silent';

  @override
  String get restAlertSound => 'Sound';

  @override
  String get restAlertVibration => 'Vibration';

  @override
  String get routinesActiveRoutines => 'Active routines';

  @override
  String get routinesAdd => 'Add';

  @override
  String get routinesAddADay => 'Add a day';

  @override
  String get routinesAddExercisesThenSetTargets =>
      'Add exercises, then set targets for each.';

  @override
  String routinesAddOnSuccessWithUnit(String unit) {
    return 'Add when I hit every set ($unit)';
  }

  @override
  String routinesAddProgramTitle(String name) {
    return 'Add $name?';
  }

  @override
  String get routinesAddRepsThenWeight => 'Add reps, then weight';

  @override
  String get routinesAddToMyRoutines => 'Add to my routines';

  @override
  String get routinesAddWeightOnSuccess => 'Add weight on success';

  @override
  String get routinesArchivedExplainer =>
      'Archived routines stay startable and can be restored from here.';

  @override
  String get routinesArchivedRoutines => 'Archived routines';

  @override
  String get routinesArchivedRoutinesCouldNotBe =>
      'Archived routines could not be read';

  @override
  String routinesBaseStepWithUnit(String unit) {
    return 'Base step ($unit)';
  }

  @override
  String get routinesBrowseStarterPrograms => 'Browse starter programs';

  @override
  String get routinesDayCouldNotBeRead => 'Day could not be read';

  @override
  String get routinesDayNameHint =>
      '\"Push\", \"Pull\", \"Legs\" — a day is what you start a workout from.';

  @override
  String get routinesDaysCouldNotBeRead => 'Days could not be read';

  @override
  String get routinesDeleteDayExplainer =>
      'Its days and targets will be removed. Workouts you have already logged from it are never affected.';

  @override
  String routinesDeleteDayTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get routinesDeleteRoutineExplainer =>
      'Its days and targets will be removed. Workouts you have already logged from it are never affected (`ADR-0004`).';

  @override
  String routinesDeleteRoutineTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get routinesDoubleProgressionExplainer =>
      'Uses the Reps min/max above as the range. Deloads after three sessions in a row below the minimum.';

  @override
  String get routinesDuplicate => 'Duplicate';

  @override
  String get routinesEmptyStateExplainer =>
      'A routine holds days; a day is what you start a workout from. A starter program is the fastest way to get one.';

  @override
  String get routinesGroup => 'Group';

  @override
  String get routinesILlDecide => 'I\'ll decide';

  @override
  String routinesImportProgramExplainer(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Creates a new routine with $_temp0. You can edit or delete it freely afterwards — it stays independent of this template.';
  }

  @override
  String get routinesItsExercisesAndTargetsWill =>
      'Its exercises and targets will be removed.';

  @override
  String get routinesLinearRuleExplainer =>
      'Repeats the same weight on a partial miss; deloads after three misses in a row.';

  @override
  String get routinesMatchEffortRpe => 'Match effort (RPE)';

  @override
  String get routinesMoveToFolder => 'Move to folder';

  @override
  String get routinesMustBeAdjacent => 'Must be adjacent';

  @override
  String get routinesNewDay => 'New day';

  @override
  String get routinesNewFolder => 'New folder';

  @override
  String get routinesNewRoutine => 'New routine';

  @override
  String get routinesNoDaysYet => 'No days yet';

  @override
  String get routinesNoFolder => 'No folder';

  @override
  String get routinesNoRestBetween => 'No rest between';

  @override
  String get routinesNoTargetsSet => 'No targets set';

  @override
  String get routinesNoTrainingMaxSet =>
      'No training max set on this exercise. Set one on the exercise\'s own editor first.';

  @override
  String get routinesOfTm => '% of TM';

  @override
  String get routinesOptionalPickTheWeekdaysYou =>
      'Optional — pick the weekdays you plan to train this day.';

  @override
  String get routinesPercentOfTrainingMax => 'Percent of training max';

  @override
  String get routinesPlannedSetsPerMuscle => 'Planned sets per muscle';

  @override
  String routinesProgramDayCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String routinesProgramSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0 could not be added — not found in your catalogue.';
  }

  @override
  String get routinesProgression => 'Progression';

  @override
  String get routinesRename => 'Rename';

  @override
  String get routinesRenameDay => 'Rename day';

  @override
  String get routinesRenameRoutine => 'Rename routine';

  @override
  String get routinesRepsMax => 'Reps max';

  @override
  String get routinesRepsMin => 'Reps min';

  @override
  String get routinesRest => 'Rest';

  @override
  String routinesRestFromBuiltIn(String duration) {
    return '$duration, the built-in default for this kind of exercise.';
  }

  @override
  String routinesRestFromExercise(String duration) {
    return '$duration, inherited from this exercise\'s own default.';
  }

  @override
  String routinesRestFromGlobal(String duration) {
    return '$duration, inherited from your global rest setting.';
  }

  @override
  String routinesRestFromRoutine(String duration) {
    return '$duration, set here for this routine.';
  }

  @override
  String get routinesRestOverrideHint =>
      'Overrides the exercise and global defaults.';

  @override
  String get routinesRoutineCouldNotBeRead => 'Routine could not be read';

  @override
  String get routinesRoutinesCouldNotBeRead => 'Routines could not be read';

  @override
  String get routinesSaveTargets => 'Save targets';

  @override
  String get routinesSchedule => 'Schedule';

  @override
  String routinesSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get routinesSetTargetsToSeeSets =>
      'Set targets to see sets per muscle here.';

  @override
  String get routinesSetsPerMuscle => 'Sets per muscle';

  @override
  String get routinesStartWorkout => 'Start workout';

  @override
  String get routinesStarterPrograms => 'Starter programs';

  @override
  String get routinesTargetRpe => 'Target RPE';

  @override
  String get routinesTargetRpeHint =>
      'How hard the last set should feel. Comes in easier — add more; harder — add less or back off.';

  @override
  String routinesTargetWeightWithUnit(String unit) {
    return 'Target weight ($unit)';
  }

  @override
  String get routinesThisDayNoLongerExists => 'This day no longer exists.';

  @override
  String get routinesThisRoutineNoLongerExists =>
      'This routine no longer exists.';

  @override
  String routinesTrainingMaxIs(String weight, String unit) {
    return 'Training max $weight $unit. Recomputed every time this day is started — no week/cycle variation yet.';
  }

  @override
  String get routinesUngroup => 'Ungroup';

  @override
  String get routinesWithinGroupRest => 'Rest between superset members';

  @override
  String get routinesWithinGroupRestExplainer =>
      'Zero is what a superset usually means. A few seconds is for walking between two machines without the timer treating it as a full rest.';

  @override
  String get settings100Kg8 => '100 kg × 8';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAddABar => 'Add a bar';

  @override
  String get settingsAddAPlate => 'Add a plate';

  @override
  String get settingsAllDataWiped => 'All data wiped.';

  @override
  String get settingsAllExercisesResolved => 'All exercises resolved.';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockExplainer =>
      'A PIN gates the whole app on launch and whenever it returns from the background. This is a screen lock, not encryption — it protects against a casual look, not a determined one.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppliesToWeeklyVolumeSets =>
      'Applies to weekly volume, sets-per-muscle and streaks.';

  @override
  String get settingsAutoStartRestExplainer =>
      'Completing a set starts the rest timer, and completing the next one restarts it.';

  @override
  String get settingsAutomatic => 'Automatic';

  @override
  String get settingsAutomaticLength => 'automatic length';

  @override
  String get settingsBackUpNow => 'Back up now';

  @override
  String get settingsBackingUp => 'Backing up…';

  @override
  String get settingsBackupExplainer =>
      'A backup is a full, versioned copy of everything on this device, saved here so restore can find it later.';

  @override
  String get settingsBackupFailedTryAgain => 'Backup failed. Try again.';

  @override
  String get settingsBackupSaved => 'Backup saved.';

  @override
  String get settingsBarsPlates => 'Bars & plates';

  @override
  String get settingsBodyweight => 'Bodyweight';

  @override
  String get settingsCardio => 'Cardio';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsChooseACsvFile => 'Choose a CSV file';

  @override
  String get settingsChooseAPin4Or => 'Choose a PIN (4 or more digits)';

  @override
  String get settingsCircumferences => 'Circumferences';

  @override
  String get settingsColoursInThisTheme => 'Colours in this theme';

  @override
  String get settingsConfirmTheNewPin => 'Confirm the new PIN';

  @override
  String get settingsCouldNotLoadSampleData => 'Could not load sample data.';

  @override
  String get settingsCreateNew => 'Create new';

  @override
  String get settingsCsvExportExplainer =>
      'For spreadsheets, not backup — one CSV each for sets, body measurements and routines, in your display units.';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsDefaultBar => 'Default bar';

  @override
  String get settingsDefaultRest => 'Default rest';

  @override
  String get settingsDelete => 'DELETE';

  @override
  String get settingsDemoDataExplainer =>
      'Debug build only — never reachable in a release. Adds 8 weeks of a Push/Pull/Legs split plus weekly bodyweight, so the analytics screens have something to show without hand-logging sessions.';

  @override
  String get settingsDistance => 'Distance';

  @override
  String get settingsDistanceUnitNote => 'Separate from weights on purpose';

  @override
  String get settingsDynamicColour => 'Dynamic colour';

  @override
  String get settingsDynamicColourExplainer =>
      'Tint the app from your wallpaper. Android 12+ only — off does nothing on a phone that doesn\'t support it.';

  @override
  String get settingsE1rmFormula => 'e1RM formula';

  @override
  String get settingsEditBar => 'Edit bar';

  @override
  String get settingsEnterTheCurrentPin => 'Enter the current PIN';

  @override
  String get settingsEpleyDefault => 'Epley (default)';

  @override
  String get settingsExportDataCsv => 'Export data (.csv)';

  @override
  String get settingsExportDataJson => 'Export data (.json)';

  @override
  String get settingsExportFailedTryAgain => 'Export failed. Try again.';

  @override
  String get settingsFewerPairs => 'Fewer pairs';

  @override
  String get settingsFitnessappCsvExport => 'FitnessApp CSV export';

  @override
  String get settingsFitnessappExport => 'FitnessApp export';

  @override
  String get settingsGhostValues => 'Ghost values';

  @override
  String get settingsHealthConnect => 'Health Connect';

  @override
  String get settingsHealthConnectSubtitle =>
      'Share workouts, read bodyweight — off by default';

  @override
  String get settingsImport => 'Import';

  @override
  String get settingsImportComplete => 'Import complete.';

  @override
  String settingsImportDone(int workouts, int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      workouts,
      locale: localeName,
      other: '$workouts workouts',
      one: '1 workout',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$_temp0 and $_temp1 imported.';
  }

  @override
  String get settingsImportExplainer =>
      'Bring your history over from Strong or Hevy — nothing is written until you confirm what to do with each exercise.';

  @override
  String get settingsImportFailed => 'Import failed.';

  @override
  String get settingsImportFailedNothingWasChanged =>
      'Import failed. Nothing was changed.';

  @override
  String get settingsImportFromStrongOrHevy => 'Import from Strong or Hevy';

  @override
  String settingsImportPreviewFound(int workouts, int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      workouts,
      locale: localeName,
      other: '$workouts workouts',
      one: '1 workout',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$_temp0, $_temp1 found.';
  }

  @override
  String get settingsImportScreenExplainer =>
      'Import your training history from a Strong or Hevy CSV export. Nothing is written until you confirm.';

  @override
  String settingsImportSkippedDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already-imported workouts skipped.',
      one: '1 already-imported workout skipped.',
    );
    return ' $_temp0';
  }

  @override
  String get settingsJsonDumpExplainer =>
      'Every table, every row, exactly as stored — a rescue copy, not a polished backup. Share it somewhere safe.';

  @override
  String get settingsKilograms => 'Kilograms';

  @override
  String get settingsLastTime975Kg => 'last time: 97.5 kg × 8';

  @override
  String get settingsLoadSampleDataDebug => 'Load sample data (debug)';

  @override
  String get settingsManualStart => 'Manual start';

  @override
  String get settingsMatchTheDeviceSetting => 'Match the device setting';

  @override
  String get settingsMeasurementReminders => 'Measurement reminders';

  @override
  String get settingsMeasurementRemindersExplainer =>
      'Off by default. A weekly nudge to log bodyweight and measurements.';

  @override
  String get settingsMeasurements => 'Measurements';

  @override
  String get settingsMorePairs => 'More pairs';

  @override
  String get settingsNewBar => 'New bar';

  @override
  String get settingsNewPlate => 'New plate';

  @override
  String get settingsNoBarsConfiguredYet => 'No bars configured yet.';

  @override
  String get settingsNoPlatesConfiguredYet => 'No plates configured yet.';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsOk => 'OK';

  @override
  String get settingsOpenSourceLicences => 'Open-source licences';

  @override
  String settingsPairsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pairs available',
      one: '1 pair available',
      zero: 'None available',
    );
    return '$_temp0';
  }

  @override
  String get settingsPairsAvailableLabel => 'Pairs available';

  @override
  String get settingsPersonalRecordsRebuilt => 'Personal records rebuilt.';

  @override
  String get settingsPounds => 'Pounds';

  @override
  String get settingsPreview => 'Preview';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsPrivacySummary =>
      'No account. No server. No telemetry. This app makes no network calls at all, and your training data never leaves the device unless you export it yourself.';

  @override
  String get settingsRateOfPerceivedExertionPer =>
      'Rate of perceived exertion per set, 6.0–10.0.';

  @override
  String get settingsRebuildFailedTryAgain => 'Rebuild failed. Try again.';

  @override
  String get settingsRebuildPersonalRecords => 'Rebuild personal records';

  @override
  String get settingsRebuildPrsExplainer =>
      'Personal records are a cache rebuilt from your logged sets. If one ever looks wrong, rebuilding it from scratch is always safe.';

  @override
  String get settingsRemoveAppLock => 'Remove app lock?';

  @override
  String get settingsRemovePin => 'Remove PIN';

  @override
  String get settingsRemovePlateNote =>
      'The calculator will stop proposing it.';

  @override
  String get settingsRemoveThisPlate => 'Remove this plate?';

  @override
  String get settingsRestAlertLimitation =>
      'The alert needs the app to still be running. Notifications that survive the phone putting the app to sleep arrive with F-TIM-003.';

  @override
  String get settingsRestAlerts => 'Rest timer alerts';

  @override
  String get settingsRestAlertsExplainer =>
      'A notification when a rest ends, so the phone can go back in your pocket.';

  @override
  String get settingsRestDefaultOverrideNote =>
      'An exercise with its own rest duration always wins over this.';

  @override
  String get settingsRestDefaultsHint =>
      'Longer for barbell and compound work, shorter for isolation.';

  @override
  String get settingsRestoreComplete => 'Restore complete.';

  @override
  String get settingsRestoreConfirmExplainer =>
      'This replaces every workout, routine and setting on this device with what is in the backup file. A safety copy of what is here now is saved first.';

  @override
  String get settingsRestoreFailed => 'Restore failed.';

  @override
  String get settingsRestoreFailedTryAgain => 'Restore failed. Try again.';

  @override
  String get settingsRestoreFromBackup => 'Restore from backup?';

  @override
  String get settingsRestoreFromBackup2 => 'Restore from backup…';

  @override
  String get settingsRpe => 'RPE';

  @override
  String get settingsSampleDataLoaded => 'Sample data loaded.';

  @override
  String get settingsSessionVolume => 'Session volume';

  @override
  String get settingsSetAPin => 'Set a PIN';

  @override
  String get settingsSetsTargetsPlatesAndBars =>
      'Sets, targets, plates and bars';

  @override
  String get settingsSkip => 'Skip';

  @override
  String get settingsSourceCode => 'Source code';

  @override
  String get settingsStartAutomatically => 'Start automatically';

  @override
  String get settingsStartsAutomatically => 'Starts automatically';

  @override
  String get settingsTheAppWillOpenWithout =>
      'The app will open without a PIN.';

  @override
  String get settingsTheFullTextInThe =>
      'The full text, in the app\'s repository';

  @override
  String get settingsTopSet => 'Top set';

  @override
  String get settingsTryAgain => 'Try again';

  @override
  String get settingsUnits => 'Units';

  @override
  String get settingsUnitsExplainer =>
      'Changing a unit only changes how numbers are shown. Nothing stored is rewritten, so switching back is lossless.';

  @override
  String get settingsUseExisting => 'Use existing';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsW1Reps30 => 'w × (1 + reps / 30)';

  @override
  String get settingsW3637Reps => 'w × 36 / (37 − reps)';

  @override
  String get settingsWReps010 => 'w × reps^0.10';

  @override
  String get settingsWarnBeforeTheEnd => 'Warn before the end';

  @override
  String get settingsWeekStartsOn => 'Week starts on';

  @override
  String settingsWeightWithUnit(String unit) {
    return 'Weight ($unit)';
  }

  @override
  String get settingsWeights => 'Weights';

  @override
  String get settingsWipe => 'Wipe';

  @override
  String get settingsWipeAllData => 'Wipe all data?';

  @override
  String get settingsWipeAllData2 => 'Wipe all data';

  @override
  String get settingsWipeConfirmExplainer =>
      'This permanently deletes every workout, routine and setting on this device. Type DELETE to confirm.';

  @override
  String get settingsWipeExplainer =>
      'Wiping deletes everything on this device and returns the app to its first-run state. A backup is taken first.';

  @override
  String get settingsWipeFailedTryAgain => 'Wipe failed. Try again.';

  @override
  String get settingsWorkoutReminders => 'Workout reminders';

  @override
  String get settingsWorkoutRemindersExplainer =>
      'Off by default. A nudge on the days your routine is scheduled for.';

  @override
  String get settingsWrongPin => 'Wrong PIN.';

  @override
  String get shellAtLeastThreeSessionsAre =>
      'At least three sessions are needed for a trend.';

  @override
  String get shellDelete => 'Delete';

  @override
  String get shellEnterPin => 'Enter PIN';

  @override
  String get shellGoHome => 'Go home';

  @override
  String shellHoldTo(String action) {
    return 'Hold to $action';
  }

  @override
  String get shellClose => 'Close';

  @override
  String get shellHomeTitle => 'Home';

  @override
  String shellInProgressElapsed(String elapsed) {
    return 'In progress · $elapsed';
  }

  @override
  String get shellKeepIt => 'Keep it';

  @override
  String get shellLogAFewSessionsTo => 'Log a few sessions to see this chart.';

  @override
  String get shellLogItToTrackAlongside =>
      'Log it to track alongside your lifts.';

  @override
  String shellNextUpDay(String day) {
    return 'Next up: $day';
  }

  @override
  String get shellNoBodyweightLoggedYet => 'No bodyweight logged yet';

  @override
  String get shellNoWorkoutsYet => 'No workouts yet';

  @override
  String get shellNotEnoughDataYet => 'Not enough data yet';

  @override
  String get shellNotFound => 'Not found';

  @override
  String get shellPersonalRecord => 'Personal record';

  @override
  String get shellPlateLoadingDiagram => 'Plate loading diagram';

  @override
  String get shellReadyToTrain => 'Ready to train?';

  @override
  String get shellRecentWorkouts => 'Recent workouts';

  @override
  String get shellRecentWorkoutsCouldNotBe =>
      'Recent workouts could not be read';

  @override
  String get shellSettings => 'Settings';

  @override
  String get shellSomethingWentWrong => 'Something went wrong';

  @override
  String get shellStartAWorkout => 'Start a workout';

  @override
  String get shellThisWeek => 'This week';

  @override
  String shellTodaysDay(String day) {
    return 'Today: $day';
  }

  @override
  String get shellTryAgainInAMoment => 'Try again in a moment.';

  @override
  String get shellUnlock => 'Unlock';

  @override
  String get shellWrongPin => 'Wrong PIN';

  @override
  String get shellYourFinishedSessionsWillShow =>
      'Your finished sessions will show up here.';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSystem => 'System';

  @override
  String timingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get timingNoTime => 'no time';

  @override
  String timingSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get timingSkipRest => 'Skip rest';

  @override
  String get trackingBodyweightReps => 'Bodyweight reps';

  @override
  String get trackingDistanceTime => 'Distance & time';

  @override
  String get trackingReps => 'Reps only';

  @override
  String get trackingTime => 'Time';

  @override
  String get trackingWeightReps => 'Weight × reps';

  @override
  String get trackingWeightTime => 'Weight & time';
}
