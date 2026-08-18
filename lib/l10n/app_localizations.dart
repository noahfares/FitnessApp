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
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// No description provided for @analytics1Year.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get analytics1Year;

  /// No description provided for @analytics3Months.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get analytics3Months;

  /// No description provided for @analytics4Weeks.
  ///
  /// In en, this message translates to:
  /// **'4 weeks'**
  String get analytics4Weeks;

  /// No description provided for @analytics6Months.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get analytics6Months;

  /// No description provided for @analyticsAMoreHonestMeasureThan.
  ///
  /// In en, this message translates to:
  /// **'A more honest measure than an e1RM estimate, where logged.'**
  String get analyticsAMoreHonestMeasureThan;

  /// No description provided for @analyticsAcwrExplainer.
  ///
  /// In en, this message translates to:
  /// **'Ratio of this week\'s volume to your trailing 4-week average (ACWR). 0.8–1.3 is typically described as a steady ramp rate; this is information, not a warning.'**
  String get analyticsAcwrExplainer;

  /// No description provided for @analyticsAllExercises.
  ///
  /// In en, this message translates to:
  /// **'All exercises'**
  String get analyticsAllExercises;

  /// No description provided for @analyticsAllKinds.
  ///
  /// In en, this message translates to:
  /// **'All kinds'**
  String get analyticsAllKinds;

  /// No description provided for @analyticsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get analyticsAllTime;

  /// No description provided for @analyticsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get analyticsBack;

  /// No description provided for @analyticsBestE1rm.
  ///
  /// In en, this message translates to:
  /// **'Best e1RM'**
  String get analyticsBestE1rm;

  /// No description provided for @analyticsByMuscle.
  ///
  /// In en, this message translates to:
  /// **'By muscle'**
  String get analyticsByMuscle;

  /// No description provided for @analyticsConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get analyticsConsistency;

  /// No description provided for @analyticsContributingExercises.
  ///
  /// In en, this message translates to:
  /// **'Contributing exercises'**
  String get analyticsContributingExercises;

  /// No description provided for @analyticsContributingExercisesForWeek.
  ///
  /// In en, this message translates to:
  /// **'Contributing exercises — week of {week}'**
  String analyticsContributingExercisesForWeek(String week);

  /// No description provided for @analyticsContributorSets.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets'**
  String analyticsContributorSets(String sets);

  /// No description provided for @analyticsCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get analyticsCore;

  /// No description provided for @analyticsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get analyticsCurrentStreak;

  /// No description provided for @analyticsCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get analyticsCustomRange;

  /// No description provided for @analyticsDeloadSuggestedHeading.
  ///
  /// In en, this message translates to:
  /// **'Deload suggested — not automatic, this is your call:'**
  String get analyticsDeloadSuggestedHeading;

  /// No description provided for @analyticsDurationRest.
  ///
  /// In en, this message translates to:
  /// **'Duration & rest'**
  String get analyticsDurationRest;

  /// No description provided for @analyticsE1rmTrend.
  ///
  /// In en, this message translates to:
  /// **'e1RM trend'**
  String get analyticsE1rmTrend;

  /// No description provided for @analyticsEstimatedOneRepMax.
  ///
  /// In en, this message translates to:
  /// **'Estimated one-rep max'**
  String get analyticsEstimatedOneRepMax;

  /// No description provided for @analyticsEveryFinishedSession.
  ///
  /// In en, this message translates to:
  /// **'Every finished session'**
  String get analyticsEveryFinishedSession;

  /// No description provided for @analyticsEveryPersonalRecordYouSet.
  ///
  /// In en, this message translates to:
  /// **'Every personal record you set will show up here.'**
  String get analyticsEveryPersonalRecordYouSet;

  /// No description provided for @analyticsExcludeSetsOver12Reps.
  ///
  /// In en, this message translates to:
  /// **'Exclude sets over 12 reps'**
  String get analyticsExcludeSetsOver12Reps;

  /// No description provided for @analyticsExerciseHistory.
  ///
  /// In en, this message translates to:
  /// **'Exercise history'**
  String get analyticsExerciseHistory;

  /// No description provided for @analyticsFormulaLabel.
  ///
  /// In en, this message translates to:
  /// **'Formula: {formula}'**
  String analyticsFormulaLabel(String formula);

  /// No description provided for @analyticsFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get analyticsFront;

  /// No description provided for @analyticsHardSetsForMuscle.
  ///
  /// In en, this message translates to:
  /// **'Hard sets per week — {muscle}'**
  String analyticsHardSetsForMuscle(String muscle);

  /// No description provided for @analyticsHardSetsPerWeekFor.
  ///
  /// In en, this message translates to:
  /// **'Hard sets per week for the selected muscle'**
  String get analyticsHardSetsPerWeekFor;

  /// No description provided for @analyticsHeatRelativeCaveat.
  ///
  /// In en, this message translates to:
  /// **'Relative to your hardest-trained muscle over the selected range.'**
  String get analyticsHeatRelativeCaveat;

  /// No description provided for @analyticsHeaviestSet.
  ///
  /// In en, this message translates to:
  /// **'Heaviest set'**
  String get analyticsHeaviestSet;

  /// No description provided for @analyticsInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get analyticsInsights;

  /// No description provided for @analyticsIntensityOfE1rm.
  ///
  /// In en, this message translates to:
  /// **'Intensity (% of e1RM)'**
  String get analyticsIntensityOfE1rm;

  /// No description provided for @analyticsIntensityRpe.
  ///
  /// In en, this message translates to:
  /// **'Intensity (RPE)'**
  String get analyticsIntensityRpe;

  /// No description provided for @analyticsLast3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get analyticsLast3Months;

  /// No description provided for @analyticsLast4Weeks.
  ///
  /// In en, this message translates to:
  /// **'Last 4 weeks'**
  String get analyticsLast4Weeks;

  /// No description provided for @analyticsLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get analyticsLast6Months;

  /// No description provided for @analyticsLastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get analyticsLastYear;

  /// No description provided for @analyticsLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get analyticsLegs;

  /// No description provided for @analyticsLinearRegressionOverlay.
  ///
  /// In en, this message translates to:
  /// **'Linear regression overlay'**
  String get analyticsLinearRegressionOverlay;

  /// No description provided for @analyticsLogAFewWorkoutsTo.
  ///
  /// In en, this message translates to:
  /// **'Log a few workouts to see volume and muscle coverage here.'**
  String get analyticsLogAFewWorkoutsTo;

  /// No description provided for @analyticsLogThisExerciseInA.
  ///
  /// In en, this message translates to:
  /// **'Log this exercise in a workout to see it here.'**
  String get analyticsLogThisExerciseInA;

  /// No description provided for @analyticsLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get analyticsLongestStreak;

  /// No description provided for @analyticsMostRepsAtAWeight.
  ///
  /// In en, this message translates to:
  /// **'Most reps at a weight'**
  String get analyticsMostRepsAtAWeight;

  /// No description provided for @analyticsMostSessionVolume.
  ///
  /// In en, this message translates to:
  /// **'Most session volume'**
  String get analyticsMostSessionVolume;

  /// No description provided for @analyticsMuscleBalance.
  ///
  /// In en, this message translates to:
  /// **'Muscle balance'**
  String get analyticsMuscleBalance;

  /// No description provided for @analyticsMuscleHeatMap.
  ///
  /// In en, this message translates to:
  /// **'Muscle heat map'**
  String get analyticsMuscleHeatMap;

  /// No description provided for @analyticsNeedsAtLeast28Days.
  ///
  /// In en, this message translates to:
  /// **'Needs at least 28 days of logged training to show.'**
  String get analyticsNeedsAtLeast28Days;

  /// No description provided for @analyticsNoMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get analyticsNoMatches;

  /// No description provided for @analyticsNoRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get analyticsNoRecordsYet;

  /// No description provided for @analyticsNoSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get analyticsNoSessionsYet;

  /// No description provided for @analyticsNotEnoughLoggedRestYet.
  ///
  /// In en, this message translates to:
  /// **'not enough logged rest yet'**
  String get analyticsNotEnoughLoggedRestYet;

  /// No description provided for @analyticsOverallWeeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Overall weekly volume'**
  String get analyticsOverallWeeklyVolume;

  /// No description provided for @analyticsPrTimeline.
  ///
  /// In en, this message translates to:
  /// **'PR timeline'**
  String get analyticsPrTimeline;

  /// No description provided for @analyticsPull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get analyticsPull;

  /// No description provided for @analyticsPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get analyticsPush;

  /// No description provided for @analyticsPushPull.
  ///
  /// In en, this message translates to:
  /// **'Push : pull'**
  String get analyticsPushPull;

  /// No description provided for @analyticsQuadHamstring.
  ///
  /// In en, this message translates to:
  /// **'Quad : hamstring'**
  String get analyticsQuadHamstring;

  /// No description provided for @analyticsReferenceBand.
  ///
  /// In en, this message translates to:
  /// **'Shaded: 10–20 hard sets a week, a commonly cited range for a muscle group. A guide, not a target.'**
  String get analyticsReferenceBand;

  /// No description provided for @analyticsRelativeVolumeByMuscle.
  ///
  /// In en, this message translates to:
  /// **'Relative training volume by muscle'**
  String get analyticsRelativeVolumeByMuscle;

  /// No description provided for @analyticsRepRanges.
  ///
  /// In en, this message translates to:
  /// **'Rep ranges'**
  String get analyticsRepRanges;

  /// No description provided for @analyticsRestComplianceCaveat.
  ///
  /// In en, this message translates to:
  /// **'Average actual rest vs. each exercise\'s resolved default — an approximation, not a per-set historical record.'**
  String get analyticsRestComplianceCaveat;

  /// No description provided for @analyticsScheduleAdherence.
  ///
  /// In en, this message translates to:
  /// **'Against your schedule'**
  String get analyticsScheduleAdherence;

  /// No description provided for @analyticsScheduleAdherenceValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}% — you trained {trained} of {scheduled} scheduled days in the last 4 weeks.'**
  String analyticsScheduleAdherenceValue(
    int percent,
    int trained,
    int scheduled,
  );

  /// No description provided for @analyticsSessionDuration.
  ///
  /// In en, this message translates to:
  /// **'Session duration'**
  String get analyticsSessionDuration;

  /// No description provided for @analyticsSessionDurationInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Session duration in minutes'**
  String get analyticsSessionDurationInMinutes;

  /// No description provided for @analyticsSessionsWeek.
  ///
  /// In en, this message translates to:
  /// **'Sessions / week'**
  String get analyticsSessionsWeek;

  /// No description provided for @analyticsSetsByIntensityZone.
  ///
  /// In en, this message translates to:
  /// **'Sets by intensity zone'**
  String get analyticsSetsByIntensityZone;

  /// No description provided for @analyticsSetsByLoggedRpe.
  ///
  /// In en, this message translates to:
  /// **'Sets by logged RPE'**
  String get analyticsSetsByLoggedRpe;

  /// No description provided for @analyticsSetsByRepRange.
  ///
  /// In en, this message translates to:
  /// **'Sets by rep range'**
  String get analyticsSetsByRepRange;

  /// No description provided for @analyticsStallExplainer.
  ///
  /// In en, this message translates to:
  /// **'e1RM has been flat over the last {sessions} sessions. Consider a deload, a rep-range change, or an exercise variation.'**
  String analyticsStallExplainer(int sessions);

  /// No description provided for @analyticsStreakExplainer.
  ///
  /// In en, this message translates to:
  /// **'Target: {target} sessions a week. A streak is a run of complete weeks meeting it — the week in progress never breaks one, whatever it currently reads.'**
  String analyticsStreakExplainer(int target);

  /// No description provided for @analyticsThisExercise.
  ///
  /// In en, this message translates to:
  /// **'This exercise'**
  String get analyticsThisExercise;

  /// No description provided for @analyticsThisMuscle.
  ///
  /// In en, this message translates to:
  /// **'This muscle'**
  String get analyticsThisMuscle;

  /// No description provided for @analyticsTrailing4WeeksARough.
  ///
  /// In en, this message translates to:
  /// **'Trailing 4 weeks. A rough guide, not a prescription.'**
  String get analyticsTrailing4WeeksARough;

  /// No description provided for @analyticsTrainingLoad.
  ///
  /// In en, this message translates to:
  /// **'Training load'**
  String get analyticsTrainingLoad;

  /// No description provided for @analyticsTrendLine.
  ///
  /// In en, this message translates to:
  /// **'Trend line'**
  String get analyticsTrendLine;

  /// No description provided for @analyticsUnreliableAtHighRepCounts.
  ///
  /// In en, this message translates to:
  /// **'Unreliable at high rep counts'**
  String get analyticsUnreliableAtHighRepCounts;

  /// No description provided for @analyticsUnscheduledSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Plus 1 session on an unscheduled day. Extra sessions never count against this.} other{Plus {count} sessions on unscheduled days. Extra sessions never count against this.}}'**
  String analyticsUnscheduledSessions(int count);

  /// No description provided for @analyticsVolumeForMuscle.
  ///
  /// In en, this message translates to:
  /// **'Volume — {muscle}'**
  String analyticsVolumeForMuscle(String muscle);

  /// No description provided for @analyticsWeeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'Sessions a week you are aiming for'**
  String get analyticsWeeklyTarget;

  /// No description provided for @analyticsWeeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Weekly volume'**
  String get analyticsWeeklyVolume;

  /// No description provided for @analyticsWeeklyVolumeForMuscle.
  ///
  /// In en, this message translates to:
  /// **'Weekly volume for the selected muscle'**
  String get analyticsWeeklyVolumeForMuscle;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FitnessApp'**
  String get appTitle;

  /// No description provided for @bodyAddOneToStartA.
  ///
  /// In en, this message translates to:
  /// **'Add one to start a date-tagged record.'**
  String get bodyAddOneToStartA;

  /// No description provided for @bodyBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get bodyBody;

  /// No description provided for @bodyBodyweightHistoryCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight history could not be read'**
  String get bodyBodyweightHistoryCouldNotBe;

  /// No description provided for @bodyBodyweightTrend.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight trend'**
  String get bodyBodyweightTrend;

  /// No description provided for @bodyCancelCompare.
  ///
  /// In en, this message translates to:
  /// **'Cancel compare'**
  String get bodyCancelCompare;

  /// No description provided for @bodyClearGoal.
  ///
  /// In en, this message translates to:
  /// **'Clear goal'**
  String get bodyClearGoal;

  /// No description provided for @bodyCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get bodyCompare;

  /// No description provided for @bodyCompareTwoPhotos.
  ///
  /// In en, this message translates to:
  /// **'Compare two photos'**
  String get bodyCompareTwoPhotos;

  /// No description provided for @bodyCouldNotLoadPhotos.
  ///
  /// In en, this message translates to:
  /// **'Could not load photos.'**
  String get bodyCouldNotLoadPhotos;

  /// No description provided for @bodyDeleteEntryExplainer.
  ///
  /// In en, this message translates to:
  /// **'The {type} entry from {date} will be removed.'**
  String bodyDeleteEntryExplainer(String date, String type);

  /// No description provided for @bodyDeleteThisEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get bodyDeleteThisEntry;

  /// No description provided for @bodyDeleteThisPhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo?'**
  String get bodyDeleteThisPhoto;

  /// No description provided for @bodyEditBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Edit bodyweight'**
  String get bodyEditBodyweight;

  /// No description provided for @bodyEditMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Edit {type}'**
  String bodyEditMeasurement(String type);

  /// No description provided for @bodyEnterAValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a value'**
  String get bodyEnterAValue;

  /// No description provided for @bodyEnterAWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight'**
  String get bodyEnterAWeight;

  /// No description provided for @bodyGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get bodyGoal;

  /// No description provided for @bodyGoalExplainer.
  ///
  /// In en, this message translates to:
  /// **'Drawn as a dashed line on the trend. A target, not a prediction — nothing else in the app reads it.'**
  String get bodyGoalExplainer;

  /// No description provided for @bodyLogBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Log bodyweight'**
  String get bodyLogBodyweight;

  /// No description provided for @bodyLogMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Log {type}'**
  String bodyLogMeasurement(String type);

  /// No description provided for @bodyLogYourWeightToTrack.
  ///
  /// In en, this message translates to:
  /// **'Log your weight to track it alongside your lifts.'**
  String get bodyLogYourWeightToTrack;

  /// No description provided for @bodyMeasurementsToTrack.
  ///
  /// In en, this message translates to:
  /// **'Measurements to track'**
  String get bodyMeasurementsToTrack;

  /// No description provided for @bodyNoBodyweightLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No bodyweight logged yet'**
  String get bodyNoBodyweightLoggedYet;

  /// No description provided for @bodyNoProgressPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No progress photos yet'**
  String get bodyNoProgressPhotosYet;

  /// No description provided for @bodyNotLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'Not logged yet.'**
  String get bodyNotLoggedYet;

  /// No description provided for @bodyNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get bodyNoteOptional;

  /// No description provided for @bodyProgressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Progress photos'**
  String get bodyProgressPhotos;

  /// No description provided for @bodySetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a bodyweight goal'**
  String get bodySetGoal;

  /// No description provided for @bodyThisPermanentlyRemovesThePhoto.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the photo from this device.'**
  String get bodyThisPermanentlyRemovesThePhoto;

  /// No description provided for @bodyTrackedTypesExplainer.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight is always logged. Turn on whichever of these you also want to track.'**
  String get bodyTrackedTypesExplainer;

  /// No description provided for @bodyTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get bodyTrend;

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get bodyWeight;

  /// No description provided for @catalogActiveExercises.
  ///
  /// In en, this message translates to:
  /// **'Active exercises'**
  String get catalogActiveExercises;

  /// No description provided for @catalogAddAlias.
  ///
  /// In en, this message translates to:
  /// **'Add alias'**
  String get catalogAddAlias;

  /// No description provided for @catalogAddAnAlias.
  ///
  /// In en, this message translates to:
  /// **'Add an alias'**
  String get catalogAddAnAlias;

  /// No description provided for @catalogAliases.
  ///
  /// In en, this message translates to:
  /// **'Aliases'**
  String get catalogAliases;

  /// No description provided for @catalogAliasesHint.
  ///
  /// In en, this message translates to:
  /// **'Other names this is searchable by — \"RDL\" for Romanian Deadlift.'**
  String get catalogAliasesHint;

  /// No description provided for @catalogAnotherExerciseAlreadyHasThis.
  ///
  /// In en, this message translates to:
  /// **'Another exercise already has this name. That is allowed.'**
  String get catalogAnotherExerciseAlreadyHasThis;

  /// No description provided for @catalogArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get catalogArchive;

  /// No description provided for @catalogArchiveAllExplainer.
  ///
  /// In en, this message translates to:
  /// **'Every non-archived {equipment} exercise is hidden from pickers and search. History is untouched, and each can be restored individually from the archived list.'**
  String catalogArchiveAllExplainer(String equipment);

  /// No description provided for @catalogArchiveAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive all {equipment} exercises?'**
  String catalogArchiveAllTitle(String equipment);

  /// No description provided for @catalogArchiveByEquipment.
  ///
  /// In en, this message translates to:
  /// **'Archive by equipment'**
  String get catalogArchiveByEquipment;

  /// No description provided for @catalogArchiveConfirmExplainer.
  ///
  /// In en, this message translates to:
  /// **'Archiving hides an exercise from pickers without touching any workout it appears in.'**
  String get catalogArchiveConfirmExplainer;

  /// No description provided for @catalogArchiveInstead.
  ///
  /// In en, this message translates to:
  /// **'Archive instead'**
  String get catalogArchiveInstead;

  /// No description provided for @catalogArchivedExercises.
  ///
  /// In en, this message translates to:
  /// **'Archived exercises'**
  String get catalogArchivedExercises;

  /// No description provided for @catalogArchivedExercisesCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'Archived exercises could not be read'**
  String get catalogArchivedExercisesCouldNotBe;

  /// No description provided for @catalogArchivedExplainer.
  ///
  /// In en, this message translates to:
  /// **'Archived exercises stay in your history and can be restored from here.'**
  String get catalogArchivedExplainer;

  /// No description provided for @catalogAvailableWeights.
  ///
  /// In en, this message translates to:
  /// **'Available weights'**
  String get catalogAvailableWeights;

  /// No description provided for @catalogBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get catalogBar;

  /// No description provided for @catalogBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get catalogBase;

  /// No description provided for @catalogBlankUses100TheFull.
  ///
  /// In en, this message translates to:
  /// **'Blank uses 100% — the full bodyweight.'**
  String get catalogBlankUses100TheFull;

  /// No description provided for @catalogBlankUsesDefault.
  ///
  /// In en, this message translates to:
  /// **'Blank uses the default, {defaultLabel}.'**
  String catalogBlankUsesDefault(String defaultLabel);

  /// No description provided for @catalogBodyweightLoaded.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight loaded'**
  String get catalogBodyweightLoaded;

  /// No description provided for @catalogBuiltInExerciseYourEdits.
  ///
  /// In en, this message translates to:
  /// **'Built-in exercise — your edits survive catalogue updates'**
  String get catalogBuiltInExerciseYourEdits;

  /// No description provided for @catalogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get catalogCancel;

  /// No description provided for @catalogClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get catalogClear;

  /// No description provided for @catalogClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get catalogClearAll;

  /// No description provided for @catalogClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get catalogClearSearch;

  /// No description provided for @catalogCreateExercise.
  ///
  /// In en, this message translates to:
  /// **'Create exercise'**
  String get catalogCreateExercise;

  /// No description provided for @catalogCustomExercise.
  ///
  /// In en, this message translates to:
  /// **'Custom exercise'**
  String get catalogCustomExercise;

  /// No description provided for @catalogDecidesWhichInputsTheLogger.
  ///
  /// In en, this message translates to:
  /// **'Decides which inputs the logger shows.'**
  String get catalogDecidesWhichInputsTheLogger;

  /// No description provided for @catalogDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get catalogDefault;

  /// No description provided for @catalogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get catalogDelete;

  /// No description provided for @catalogDeleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String catalogDeleteExerciseTitle(String name);

  /// No description provided for @catalogDeleteUnusedExplainer.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from the catalogue. Nothing else is affected — this exercise has never been logged.'**
  String get catalogDeleteUnusedExplainer;

  /// No description provided for @catalogDeriveFromBestE1rm90.
  ///
  /// In en, this message translates to:
  /// **'Derive from best e1RM (~90%)'**
  String get catalogDeriveFromBestE1rm90;

  /// No description provided for @catalogEditExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get catalogEditExercise;

  /// No description provided for @catalogEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get catalogEquipment;

  /// No description provided for @catalogExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get catalogExercise;

  /// No description provided for @catalogExerciseNote.
  ///
  /// In en, this message translates to:
  /// **'Exercise note'**
  String get catalogExerciseNote;

  /// No description provided for @catalogExerciseNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Seat height, pin position, grip width — visible inline during a session.'**
  String get catalogExerciseNoteHint;

  /// No description provided for @catalogFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get catalogFilter;

  /// No description provided for @catalogFixedDumbbells.
  ///
  /// In en, this message translates to:
  /// **'Fixed dumbbells'**
  String get catalogFixedDumbbells;

  /// No description provided for @catalogFixedIncrementsHint.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated, e.g. \"5, 10, 15, 20\" — exactly what the rack stocks.'**
  String get catalogFixedIncrementsHint;

  /// No description provided for @catalogHalfStep.
  ///
  /// In en, this message translates to:
  /// **'Half step'**
  String get catalogHalfStep;

  /// No description provided for @catalogHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get catalogHistory;

  /// No description provided for @catalogMuscle.
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get catalogMuscle;

  /// No description provided for @catalogName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get catalogName;

  /// No description provided for @catalogNewExercise.
  ///
  /// In en, this message translates to:
  /// **'New exercise'**
  String get catalogNewExercise;

  /// No description provided for @catalogNoLoggedHistoryForThis.
  ///
  /// In en, this message translates to:
  /// **'No logged history for this exercise yet.'**
  String get catalogNoLoggedHistoryForThis;

  /// No description provided for @catalogNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get catalogNotes;

  /// No description provided for @catalogNothingArchived.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived'**
  String get catalogNothingArchived;

  /// No description provided for @catalogNothingToArchive.
  ///
  /// In en, this message translates to:
  /// **'Nothing to archive.'**
  String get catalogNothingToArchive;

  /// No description provided for @catalogOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get catalogOptional;

  /// No description provided for @catalogPerSide.
  ///
  /// In en, this message translates to:
  /// **'Per side'**
  String get catalogPerSide;

  /// No description provided for @catalogPerSideIsDoubledAnd.
  ///
  /// In en, this message translates to:
  /// **'Per side is doubled and stored as total load.'**
  String get catalogPerSideIsDoubledAnd;

  /// No description provided for @catalogPlateLoaded.
  ///
  /// In en, this message translates to:
  /// **'Plate-loaded'**
  String get catalogPlateLoaded;

  /// No description provided for @catalogPrimaryMuscle.
  ///
  /// In en, this message translates to:
  /// **'Primary muscle'**
  String get catalogPrimaryMuscle;

  /// No description provided for @catalogRestOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Overrides the global default for this exercise.'**
  String get catalogRestOverrideHint;

  /// No description provided for @catalogRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest timer'**
  String get catalogRestTimer;

  /// No description provided for @catalogRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get catalogRestore;

  /// No description provided for @catalogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get catalogSave;

  /// No description provided for @catalogSearchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get catalogSearchExercises;

  /// No description provided for @catalogSeatHeight4PinPosition.
  ///
  /// In en, this message translates to:
  /// **'Seat height 4, pin position 6…'**
  String get catalogSeatHeight4PinPosition;

  /// No description provided for @catalogSecondaryMuscles.
  ///
  /// In en, this message translates to:
  /// **'Secondary muscles'**
  String get catalogSecondaryMuscles;

  /// No description provided for @catalogSeedingRunsAtStartupThis.
  ///
  /// In en, this message translates to:
  /// **'Seeding runs at startup; this should not happen.'**
  String get catalogSeedingRunsAtStartupThis;

  /// No description provided for @catalogShownOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} exercises'**
  String catalogShownOfTotal(int shown, int total);

  /// No description provided for @catalogStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get catalogStep;

  /// No description provided for @catalogStepperIncrement.
  ///
  /// In en, this message translates to:
  /// **'Stepper increment'**
  String get catalogStepperIncrement;

  /// No description provided for @catalogTheCatalogueCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'The catalogue could not be read'**
  String get catalogTheCatalogueCouldNotBe;

  /// No description provided for @catalogTheCatalogueIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'The catalogue is empty'**
  String get catalogTheCatalogueIsEmpty;

  /// No description provided for @catalogThisExercise.
  ///
  /// In en, this message translates to:
  /// **'this exercise'**
  String get catalogThisExercise;

  /// No description provided for @catalogThisExerciseNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This exercise no longer exists.'**
  String get catalogThisExerciseNoLongerExists;

  /// No description provided for @catalogTotalLoad.
  ///
  /// In en, this message translates to:
  /// **'Total load'**
  String get catalogTotalLoad;

  /// No description provided for @catalogTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get catalogTracking;

  /// No description provided for @catalogTrainingMax.
  ///
  /// In en, this message translates to:
  /// **'Training max'**
  String get catalogTrainingMax;

  /// No description provided for @catalogTrainingMaxHint.
  ///
  /// In en, this message translates to:
  /// **'Used by percentage-based progression.'**
  String get catalogTrainingMaxHint;

  /// No description provided for @catalogTryAShorterSearchOr.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter search, or clear a filter.'**
  String get catalogTryAShorterSearchOr;

  /// No description provided for @catalogUsedInPastWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Used in past workouts'**
  String get catalogUsedInPastWorkouts;

  /// No description provided for @catalogUsedInPastWorkoutsExplainer.
  ///
  /// In en, this message translates to:
  /// **'{name} appears in workouts you have already logged, so it cannot be deleted without breaking that history.\\n\\nArchiving hides it from pickers and leaves your history intact.'**
  String catalogUsedInPastWorkoutsExplainer(String name);

  /// No description provided for @catalogWeightEntry.
  ///
  /// In en, this message translates to:
  /// **'Weight entry'**
  String get catalogWeightEntry;

  /// No description provided for @catalogWeightSource.
  ///
  /// In en, this message translates to:
  /// **'Weight source'**
  String get catalogWeightSource;

  /// No description provided for @catalogWeightStack.
  ///
  /// In en, this message translates to:
  /// **'Weight stack'**
  String get catalogWeightStack;

  /// No description provided for @equipmentBand.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get equipmentBand;

  /// No description provided for @equipmentBarbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get equipmentBarbell;

  /// No description provided for @equipmentBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get equipmentBodyweight;

  /// No description provided for @equipmentCable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get equipmentCable;

  /// No description provided for @equipmentDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get equipmentDumbbell;

  /// No description provided for @equipmentKettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get equipmentKettlebell;

  /// No description provided for @equipmentMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get equipmentMachine;

  /// No description provided for @equipmentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get equipmentOther;

  /// No description provided for @healthExplainer.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Health Connect is Android\'s own on-device store — nothing here involves a network or an account, but it is still another app\'s copy of your training, so it asks first.'**
  String get healthExplainer;

  /// No description provided for @healthImportBodyweightExplainer.
  ///
  /// In en, this message translates to:
  /// **'The last year, skipping days you already logged.'**
  String get healthImportBodyweightExplainer;

  /// No description provided for @healthImportBodyweightNow.
  ///
  /// In en, this message translates to:
  /// **'Import bodyweight now'**
  String get healthImportBodyweightNow;

  /// No description provided for @healthImportResult.
  ///
  /// In en, this message translates to:
  /// **'{imported, plural, =0{Nothing new to import.} =1{1 entry imported.} other{{imported} entries imported.}}{skipped, plural, =0{} =1{ 1 day skipped — you had already logged it.} other{ {skipped} days skipped — you had already logged them.}}'**
  String healthImportResult(int imported, int skipped);

  /// No description provided for @healthNeverSentAnywhere.
  ///
  /// In en, this message translates to:
  /// **'This app still makes no network calls. Health Connect is on your device, and what you share with it is governed by its own settings.'**
  String get healthNeverSentAnywhere;

  /// No description provided for @healthPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted, so nothing is shared. Everything else works exactly as before.'**
  String get healthPermissionDenied;

  /// No description provided for @healthReadBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Read bodyweight'**
  String get healthReadBodyweight;

  /// No description provided for @healthReadBodyweightExplainer.
  ///
  /// In en, this message translates to:
  /// **'Lets a smart scale fill in your bodyweight log. Entries you made here always win for the same day.'**
  String get healthReadBodyweightExplainer;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get healthTitle;

  /// No description provided for @healthWriteWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Write finished workouts'**
  String get healthWriteWorkouts;

  /// No description provided for @healthWriteWorkoutsExplainer.
  ///
  /// In en, this message translates to:
  /// **'Each finished session is written as a strength-training workout: start time and duration, nothing else. No calorie estimate — a made-up number in your health record is worse than no number.'**
  String get healthWriteWorkoutsExplainer;

  /// No description provided for @historyAddASetNote.
  ///
  /// In en, this message translates to:
  /// **'Add a set note'**
  String get historyAddASetNote;

  /// No description provided for @historyAddExercises.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get historyAddExercises;

  /// No description provided for @historyAddTheFirstOneBelow.
  ///
  /// In en, this message translates to:
  /// **'Add the first one below.'**
  String get historyAddTheFirstOneBelow;

  /// No description provided for @historyAlreadyTraining.
  ///
  /// In en, this message translates to:
  /// **'Already training'**
  String get historyAlreadyTraining;

  /// No description provided for @historyAlreadyTrainingExplainer.
  ///
  /// In en, this message translates to:
  /// **'A workout is already in progress. Finish or discard it before starting another.'**
  String get historyAlreadyTrainingExplainer;

  /// No description provided for @historyCompleteSet.
  ///
  /// In en, this message translates to:
  /// **'Complete set'**
  String get historyCompleteSet;

  /// No description provided for @historyDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get historyDate;

  /// No description provided for @historyDeleteThisWorkout.
  ///
  /// In en, this message translates to:
  /// **'Delete this workout?'**
  String get historyDeleteThisWorkout;

  /// No description provided for @historyDeleteWorkoutExplainer.
  ///
  /// In en, this message translates to:
  /// **'This session and all its sets will be removed from your history.'**
  String get historyDeleteWorkoutExplainer;

  /// No description provided for @historyDeleteWorkoutHealthExplainer.
  ///
  /// In en, this message translates to:
  /// **'This session and all its sets will be removed from your history, and the copy in Health Connect will be removed too.'**
  String get historyDeleteWorkoutHealthExplainer;

  /// No description provided for @historyDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get historyDone;

  /// No description provided for @historyDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get historyDuration;

  /// No description provided for @historyEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get historyEdit;

  /// No description provided for @historyEditSetNote.
  ///
  /// In en, this message translates to:
  /// **'Edit set note'**
  String get historyEditSetNote;

  /// No description provided for @historyEditWorkout.
  ///
  /// In en, this message translates to:
  /// **'Edit workout'**
  String get historyEditWorkout;

  /// No description provided for @historyExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get historyExercises;

  /// No description provided for @historyFinishedWorkoutsShowUpHere.
  ///
  /// In en, this message translates to:
  /// **'Finished workouts show up here.'**
  String get historyFinishedWorkoutsShowUpHere;

  /// No description provided for @historyHistoryCouldNotBeRead.
  ///
  /// In en, this message translates to:
  /// **'History could not be read'**
  String get historyHistoryCouldNotBeRead;

  /// No description provided for @historyItsSetsInThisSession.
  ///
  /// In en, this message translates to:
  /// **'Its sets in this session will be removed too.'**
  String get historyItsSetsInThisSession;

  /// No description provided for @historyLogAPastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Log a past workout'**
  String get historyLogAPastWorkout;

  /// No description provided for @historyLogPastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Log past workout'**
  String get historyLogPastWorkout;

  /// No description provided for @historyNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get historyNameOptional;

  /// No description provided for @historyNoExercisesInThisSession.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this session'**
  String get historyNoExercisesInThisSession;

  /// No description provided for @historyNoExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get historyNoExercisesYet;

  /// No description provided for @historyNoSessionsLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions logged yet'**
  String get historyNoSessionsLoggedYet;

  /// No description provided for @historyNoSessionsMatch.
  ///
  /// In en, this message translates to:
  /// **'No sessions match'**
  String get historyNoSessionsMatch;

  /// No description provided for @historyRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get historyRemove;

  /// No description provided for @historyRemoveExercise.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get historyRemoveExercise;

  /// No description provided for @historyRemoveExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String historyRemoveExerciseTitle(String name);

  /// No description provided for @historyRepeatThisWorkout.
  ///
  /// In en, this message translates to:
  /// **'Repeat this workout'**
  String get historyRepeatThisWorkout;

  /// No description provided for @historyResumeIt.
  ///
  /// In en, this message translates to:
  /// **'Resume it'**
  String get historyResumeIt;

  /// No description provided for @historySaveAsRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save as routine'**
  String get historySaveAsRoutine;

  /// No description provided for @historySearchByWorkoutOrExercise.
  ///
  /// In en, this message translates to:
  /// **'Search by workout or exercise'**
  String get historySearchByWorkoutOrExercise;

  /// No description provided for @historyStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get historyStartTime;

  /// No description provided for @historyTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get historyTime;

  /// No description provided for @historyTryAShorterSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter search.'**
  String get historyTryAShorterSearch;

  /// No description provided for @historyUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get historyUndo;

  /// No description provided for @historyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get historyWorkout;

  /// No description provided for @loggingAddAtLeastOneStep.
  ///
  /// In en, this message translates to:
  /// **'Add at least one step'**
  String get loggingAddAtLeastOneStep;

  /// No description provided for @loggingAddCount.
  ///
  /// In en, this message translates to:
  /// **'Add {count}'**
  String loggingAddCount(int count);

  /// No description provided for @loggingAddExercises.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get loggingAddExercises;

  /// No description provided for @loggingAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get loggingAddNote;

  /// No description provided for @loggingAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get loggingAddSet;

  /// No description provided for @loggingAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get loggingAddStep;

  /// No description provided for @loggingAddTheFirstOneTo.
  ///
  /// In en, this message translates to:
  /// **'Add the first one to start logging.'**
  String get loggingAddTheFirstOneTo;

  /// No description provided for @loggingAlreadyTrainingExplainer.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is still in progress. Finish or discard it before starting another.'**
  String loggingAlreadyTrainingExplainer(String name);

  /// No description provided for @loggingAnEmptySessionYouAdd.
  ///
  /// In en, this message translates to:
  /// **'An empty session you add exercises to as you go.'**
  String get loggingAnEmptySessionYouAdd;

  /// No description provided for @loggingBarOnlyNoPlatesNeeded.
  ///
  /// In en, this message translates to:
  /// **'Bar only — no plates needed.'**
  String get loggingBarOnlyNoPlatesNeeded;

  /// No description provided for @loggingBuildOneFromTheRoutines.
  ///
  /// In en, this message translates to:
  /// **'Build one from the Routines tab.'**
  String get loggingBuildOneFromTheRoutines;

  /// No description provided for @loggingClosestAbove.
  ///
  /// In en, this message translates to:
  /// **'Closest above: {weight}'**
  String loggingClosestAbove(String weight);

  /// No description provided for @loggingClosestBelow.
  ///
  /// In en, this message translates to:
  /// **'Closest below: {weight}'**
  String loggingClosestBelow(String weight);

  /// No description provided for @loggingComparedToLastTime.
  ///
  /// In en, this message translates to:
  /// **'Compared to last time'**
  String get loggingComparedToLastTime;

  /// No description provided for @loggingCompleted.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get loggingCompleted;

  /// No description provided for @loggingCountsTowardVolumeAndRecords.
  ///
  /// In en, this message translates to:
  /// **'Counts toward volume and records.'**
  String get loggingCountsTowardVolumeAndRecords;

  /// No description provided for @loggingDecimalPoint.
  ///
  /// In en, this message translates to:
  /// **'Decimal point'**
  String get loggingDecimalPoint;

  /// No description provided for @loggingDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get loggingDecrease;

  /// No description provided for @loggingDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get loggingDiscard;

  /// No description provided for @loggingDiscardTally.
  ///
  /// In en, this message translates to:
  /// **'{exercises, plural, =1{1 exercise} other{{exercises} exercises}} and {sets, plural, =1{1 completed set} other{{sets} completed sets}} will be removed from this session.'**
  String loggingDiscardTally(int exercises, int sets);

  /// No description provided for @loggingDiscardThisWorkout.
  ///
  /// In en, this message translates to:
  /// **'Discard this workout?'**
  String get loggingDiscardThisWorkout;

  /// No description provided for @loggingDiscardWorkout.
  ///
  /// In en, this message translates to:
  /// **'Discard workout'**
  String get loggingDiscardWorkout;

  /// No description provided for @loggingDropSet.
  ///
  /// In en, this message translates to:
  /// **'Drop set'**
  String get loggingDropSet;

  /// No description provided for @loggingEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get loggingEditNote;

  /// No description provided for @loggingEmptySessionExplainer.
  ///
  /// In en, this message translates to:
  /// **'No sets were completed, so this would be an empty entry in your history. Discard it instead?'**
  String get loggingEmptySessionExplainer;

  /// No description provided for @loggingEnterTheWorkingWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter the working weight'**
  String get loggingEnterTheWorkingWeight;

  /// No description provided for @loggingExactMatch.
  ///
  /// In en, this message translates to:
  /// **'Exact match: {weight}'**
  String loggingExactMatch(String weight);

  /// No description provided for @loggingExerciseNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This exercise no longer exists.'**
  String get loggingExerciseNoLongerExists;

  /// No description provided for @loggingExerciseRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String loggingExerciseRemoved(String name);

  /// No description provided for @loggingExercisesCouldNotBeRead.
  ///
  /// In en, this message translates to:
  /// **'Exercises could not be read'**
  String get loggingExercisesCouldNotBeRead;

  /// No description provided for @loggingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get loggingFinish;

  /// No description provided for @loggingFinishAnyway.
  ///
  /// In en, this message translates to:
  /// **'Finish anyway'**
  String get loggingFinishAnyway;

  /// No description provided for @loggingGenerateWarmUps.
  ///
  /// In en, this message translates to:
  /// **'Generate warm-ups'**
  String get loggingGenerateWarmUps;

  /// No description provided for @loggingGroupWithNext.
  ///
  /// In en, this message translates to:
  /// **'Group with next'**
  String get loggingGroupWithNext;

  /// No description provided for @loggingIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get loggingIncrease;

  /// No description provided for @loggingKeepTraining.
  ///
  /// In en, this message translates to:
  /// **'Keep training'**
  String get loggingKeepTraining;

  /// No description provided for @loggingLastTime.
  ///
  /// In en, this message translates to:
  /// **'Last time'**
  String get loggingLastTime;

  /// No description provided for @loggingLeftShoulderTwingedBeltToo.
  ///
  /// In en, this message translates to:
  /// **'Left shoulder twinged, belt too loose…'**
  String get loggingLeftShoulderTwingedBeltToo;

  /// No description provided for @loggingMusclesWorked.
  ///
  /// In en, this message translates to:
  /// **'Muscles worked'**
  String get loggingMusclesWorked;

  /// No description provided for @loggingNiceWork.
  ///
  /// In en, this message translates to:
  /// **'Nice work.'**
  String get loggingNiceWork;

  /// No description provided for @loggingNoBarConfigured.
  ///
  /// In en, this message translates to:
  /// **'No bar configured yet — add one in Settings › Bars & plates.'**
  String get loggingNoBarConfigured;

  /// No description provided for @loggingNoExercisesMatch.
  ///
  /// In en, this message translates to:
  /// **'No exercises match'**
  String get loggingNoExercisesMatch;

  /// No description provided for @loggingNoRoutinesYet.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get loggingNoRoutinesYet;

  /// No description provided for @loggingNoStackConfigured.
  ///
  /// In en, this message translates to:
  /// **'No stack configured yet — add its base and step weight on this exercise\'s editor.'**
  String get loggingNoStackConfigured;

  /// No description provided for @loggingNoWorkoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'No workout in progress.'**
  String get loggingNoWorkoutInProgress;

  /// No description provided for @loggingNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'not completed'**
  String get loggingNotCompleted;

  /// No description provided for @loggingNothingHasBeenAddedTo.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been added to it yet.'**
  String get loggingNothingHasBeenAddedTo;

  /// No description provided for @loggingNothingLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet'**
  String get loggingNothingLoggedYet;

  /// No description provided for @loggingNumberedW1W2ExcludedFrom.
  ///
  /// In en, this message translates to:
  /// **'Numbered W1, W2. Excluded from every figure.'**
  String get loggingNumberedW1W2ExcludedFrom;

  /// No description provided for @loggingOfWorkingWeight.
  ///
  /// In en, this message translates to:
  /// **'% of working weight'**
  String get loggingOfWorkingWeight;

  /// No description provided for @loggingOrStartFromARoutine.
  ///
  /// In en, this message translates to:
  /// **'Or start from a routine'**
  String get loggingOrStartFromARoutine;

  /// No description provided for @loggingPerSide.
  ///
  /// In en, this message translates to:
  /// **'Per side: {plates}'**
  String loggingPerSide(String plates);

  /// No description provided for @loggingPersonalRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal records'**
  String get loggingPersonalRecords;

  /// No description provided for @loggingPlateCalculator.
  ///
  /// In en, this message translates to:
  /// **'Plate calculator'**
  String get loggingPlateCalculator;

  /// No description provided for @loggingPlatesPerSide.
  ///
  /// In en, this message translates to:
  /// **'Plates per side: {plates}'**
  String loggingPlatesPerSide(String plates);

  /// No description provided for @loggingRamp.
  ///
  /// In en, this message translates to:
  /// **'Ramp'**
  String get loggingRamp;

  /// No description provided for @loggingRateOfPerceivedExertionHigher.
  ///
  /// In en, this message translates to:
  /// **'Rate of perceived exertion — higher is harder.'**
  String get loggingRateOfPerceivedExertionHigher;

  /// No description provided for @loggingRemoveExerciseTally.
  ///
  /// In en, this message translates to:
  /// **'{sets, plural, =0{No sets have been completed for it.} =1{1 completed set will be removed from this session too.} other{{sets} completed sets will be removed from this session too.}}'**
  String loggingRemoveExerciseTally(int sets);

  /// No description provided for @loggingRemoveExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String loggingRemoveExerciseTitle(String name);

  /// No description provided for @loggingRemoveStep.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get loggingRemoveStep;

  /// No description provided for @loggingReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get loggingReps;

  /// No description provided for @loggingRepsInReserveLowerIs.
  ///
  /// In en, this message translates to:
  /// **'Reps in reserve — lower is harder.'**
  String get loggingRepsInReserveLowerIs;

  /// No description provided for @loggingResetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get loggingResetToDefault;

  /// No description provided for @loggingResumeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Resume workout'**
  String get loggingResumeWorkout;

  /// No description provided for @loggingSetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Set {label} deleted'**
  String loggingSetDeleted(String label);

  /// No description provided for @loggingSetNote.
  ///
  /// In en, this message translates to:
  /// **'Set note'**
  String get loggingSetNote;

  /// No description provided for @loggingSetType.
  ///
  /// In en, this message translates to:
  /// **'Set type'**
  String get loggingSetType;

  /// No description provided for @loggingSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get loggingSets;

  /// No description provided for @loggingSetsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total, plural, =1{1 set} other{{total} sets}} done'**
  String loggingSetsDone(int done, int total);

  /// No description provided for @loggingStackBaseStep.
  ///
  /// In en, this message translates to:
  /// **'Base {base}, step {step}'**
  String loggingStackBaseStep(String base, String step);

  /// No description provided for @loggingStackHalfStep.
  ///
  /// In en, this message translates to:
  /// **', half step {step}'**
  String loggingStackHalfStep(String step);

  /// No description provided for @loggingStaleSessionNotice.
  ///
  /// In en, this message translates to:
  /// **'This workout has been open for more than 12 hours. Finish or discard it if you are done.'**
  String get loggingStaleSessionNotice;

  /// No description provided for @loggingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get loggingStart;

  /// No description provided for @loggingStartAWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start a workout'**
  String get loggingStartAWorkout;

  /// No description provided for @loggingStartEmptyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start empty workout'**
  String get loggingStartEmptyWorkout;

  /// No description provided for @loggingStartOne.
  ///
  /// In en, this message translates to:
  /// **'Start one'**
  String get loggingStartOne;

  /// No description provided for @loggingStartStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Start stopwatch'**
  String get loggingStartStopwatch;

  /// No description provided for @loggingStopStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stop stopwatch'**
  String get loggingStopStopwatch;

  /// No description provided for @loggingSuperset.
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get loggingSuperset;

  /// No description provided for @loggingSwapExercise.
  ///
  /// In en, this message translates to:
  /// **'Swap exercise'**
  String get loggingSwapExercise;

  /// No description provided for @loggingTargetIsBelowTheBar.
  ///
  /// In en, this message translates to:
  /// **'Target is below the bar itself — nothing to load.'**
  String get loggingTargetIsBelowTheBar;

  /// No description provided for @loggingTargetIsBelowTheStack.
  ///
  /// In en, this message translates to:
  /// **'Target is below the stack\'s own minimum.'**
  String get loggingTargetIsBelowTheStack;

  /// No description provided for @loggingTargetSummary.
  ///
  /// In en, this message translates to:
  /// **'Target: {summary}'**
  String loggingTargetSummary(String summary);

  /// No description provided for @loggingThisSummaryCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'This summary could not be read'**
  String get loggingThisSummaryCouldNotBe;

  /// No description provided for @loggingThisWorkoutCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'This workout could not be read'**
  String get loggingThisWorkoutCouldNotBe;

  /// No description provided for @loggingToFailure.
  ///
  /// In en, this message translates to:
  /// **'To failure'**
  String get loggingToFailure;

  /// No description provided for @loggingUnknownExercise.
  ///
  /// In en, this message translates to:
  /// **'Unknown exercise'**
  String get loggingUnknownExercise;

  /// No description provided for @loggingVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get loggingVolume;

  /// No description provided for @loggingWorkingWeight.
  ///
  /// In en, this message translates to:
  /// **'Working weight'**
  String get loggingWorkingWeight;

  /// No description provided for @loggingWorkoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get loggingWorkoutComplete;

  /// No description provided for @measurementBodyFatPercent.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get measurementBodyFatPercent;

  /// No description provided for @measurementBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get measurementBodyweight;

  /// No description provided for @measurementChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get measurementChest;

  /// No description provided for @measurementHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get measurementHips;

  /// No description provided for @measurementLeftArm.
  ///
  /// In en, this message translates to:
  /// **'Left arm'**
  String get measurementLeftArm;

  /// No description provided for @measurementLeftCalf.
  ///
  /// In en, this message translates to:
  /// **'Left calf'**
  String get measurementLeftCalf;

  /// No description provided for @measurementLeftThigh.
  ///
  /// In en, this message translates to:
  /// **'Left thigh'**
  String get measurementLeftThigh;

  /// No description provided for @measurementNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get measurementNeck;

  /// No description provided for @measurementRightArm.
  ///
  /// In en, this message translates to:
  /// **'Right arm'**
  String get measurementRightArm;

  /// No description provided for @measurementRightCalf.
  ///
  /// In en, this message translates to:
  /// **'Right calf'**
  String get measurementRightCalf;

  /// No description provided for @measurementRightThigh.
  ///
  /// In en, this message translates to:
  /// **'Right thigh'**
  String get measurementRightThigh;

  /// No description provided for @measurementShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get measurementShoulders;

  /// No description provided for @measurementWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get measurementWaist;

  /// No description provided for @muscleAbductors.
  ///
  /// In en, this message translates to:
  /// **'Abductors'**
  String get muscleAbductors;

  /// No description provided for @muscleAbs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get muscleAbs;

  /// No description provided for @muscleAdductors.
  ///
  /// In en, this message translates to:
  /// **'Adductors'**
  String get muscleAdductors;

  /// No description provided for @muscleBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleBiceps;

  /// No description provided for @muscleCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscleCalves;

  /// No description provided for @muscleChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleChest;

  /// No description provided for @muscleForearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get muscleForearms;

  /// No description provided for @muscleFrontDelts.
  ///
  /// In en, this message translates to:
  /// **'Front delts'**
  String get muscleFrontDelts;

  /// No description provided for @muscleFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get muscleFullBody;

  /// No description provided for @muscleGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGlutes;

  /// No description provided for @muscleHamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get muscleHamstrings;

  /// No description provided for @muscleLats.
  ///
  /// In en, this message translates to:
  /// **'Lats'**
  String get muscleLats;

  /// No description provided for @muscleLowerBack.
  ///
  /// In en, this message translates to:
  /// **'Lower back'**
  String get muscleLowerBack;

  /// No description provided for @muscleNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get muscleNeck;

  /// No description provided for @muscleObliques.
  ///
  /// In en, this message translates to:
  /// **'Obliques'**
  String get muscleObliques;

  /// No description provided for @muscleQuads.
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get muscleQuads;

  /// No description provided for @muscleRearDelts.
  ///
  /// In en, this message translates to:
  /// **'Rear delts'**
  String get muscleRearDelts;

  /// No description provided for @muscleSideDelts.
  ///
  /// In en, this message translates to:
  /// **'Side delts'**
  String get muscleSideDelts;

  /// No description provided for @muscleTraps.
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get muscleTraps;

  /// No description provided for @muscleTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleTriceps;

  /// No description provided for @muscleUpperBack.
  ///
  /// In en, this message translates to:
  /// **'Upper back'**
  String get muscleUpperBack;

  /// No description provided for @onboardingAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get onboardingAppearance;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingProgramBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Pick one to get a routine ready to train tomorrow, or build your own later.'**
  String get onboardingProgramBody;

  /// No description provided for @onboardingProgramLater.
  ///
  /// In en, this message translates to:
  /// **'More programs live under Routines, and nothing here is permanent — every routine can be edited or deleted.'**
  String get onboardingProgramLater;

  /// No description provided for @onboardingProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Start from a program?'**
  String get onboardingProgramTitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingStartTraining.
  ///
  /// In en, this message translates to:
  /// **'Start training'**
  String get onboardingStartTraining;

  /// No description provided for @onboardingUnitsBody.
  ///
  /// In en, this message translates to:
  /// **'Display only — nothing stored ever changes, so you can switch back at any time without touching a single logged set.'**
  String get onboardingUnitsBody;

  /// No description provided for @onboardingUnitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Kilograms or pounds?'**
  String get onboardingUnitsTitle;

  /// No description provided for @onboardingWeightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get onboardingWeightUnit;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Unlimited routines, real analytics, and your data on your own device. No account, no subscription, and nothing to sign up for.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything, free'**
  String get onboardingWelcomeTitle;

  /// No description provided for @progressionCarriedForward.
  ///
  /// In en, this message translates to:
  /// **'Carried forward from last time: {reps} at {weight} {unit}.'**
  String progressionCarriedForward(int reps, String weight, String unit);

  /// No description provided for @progressionDeload.
  ///
  /// In en, this message translates to:
  /// **'Missed target {failures} sessions in a row — deloading to {weight} {unit}.'**
  String progressionDeload(int failures, String weight, String unit);

  /// No description provided for @progressionFailure.
  ///
  /// In en, this message translates to:
  /// **'Missed target last time ({failures} in a row) — repeating the same weight.'**
  String progressionFailure(int failures);

  /// No description provided for @progressionFirstRun.
  ///
  /// In en, this message translates to:
  /// **'No history for this exercise yet — using the routine\'s own target.'**
  String get progressionFirstRun;

  /// No description provided for @progressionFromTrainingMax.
  ///
  /// In en, this message translates to:
  /// **'Computed from your training max.'**
  String get progressionFromTrainingMax;

  /// No description provided for @progressionPartial.
  ///
  /// In en, this message translates to:
  /// **'Some sets missed target last time — repeating the same weight.'**
  String get progressionPartial;

  /// No description provided for @progressionPercentOfTrainingMax.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of your training max ({weight} {unit}).'**
  String progressionPercentOfTrainingMax(
    int percent,
    String weight,
    String unit,
  );

  /// No description provided for @progressionPlateRoundingHeld.
  ///
  /// In en, this message translates to:
  /// **'The next jump isn\'t assemblable from your plates, so weight stays at {weight} {unit} and reps go up by one instead.'**
  String progressionPlateRoundingHeld(String weight, String unit);

  /// No description provided for @progressionRepRangeTopMet.
  ///
  /// In en, this message translates to:
  /// **'You hit the top of your rep range at {weight} {unit} last time, so this is +{delta} {unit} — back to the bottom of the range.'**
  String progressionRepRangeTopMet(String weight, String unit, String delta);

  /// No description provided for @progressionSuccess.
  ///
  /// In en, this message translates to:
  /// **'You hit every set at {weight} {unit} last time, so this is +{delta} {unit}.'**
  String progressionSuccess(String weight, String unit, String delta);

  /// No description provided for @restAlertBoth.
  ///
  /// In en, this message translates to:
  /// **'Sound and vibration'**
  String get restAlertBoth;

  /// No description provided for @restAlertSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get restAlertSilent;

  /// No description provided for @restAlertSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get restAlertSound;

  /// No description provided for @restAlertVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get restAlertVibration;

  /// No description provided for @routinesActiveRoutines.
  ///
  /// In en, this message translates to:
  /// **'Active routines'**
  String get routinesActiveRoutines;

  /// No description provided for @routinesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get routinesAdd;

  /// No description provided for @routinesAddADay.
  ///
  /// In en, this message translates to:
  /// **'Add a day'**
  String get routinesAddADay;

  /// No description provided for @routinesAddExercisesThenSetTargets.
  ///
  /// In en, this message translates to:
  /// **'Add exercises, then set targets for each.'**
  String get routinesAddExercisesThenSetTargets;

  /// No description provided for @routinesAddOnSuccessWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Add when I hit every set ({unit})'**
  String routinesAddOnSuccessWithUnit(String unit);

  /// No description provided for @routinesAddProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Add {name}?'**
  String routinesAddProgramTitle(String name);

  /// No description provided for @routinesAddRepsThenWeight.
  ///
  /// In en, this message translates to:
  /// **'Add reps, then weight'**
  String get routinesAddRepsThenWeight;

  /// No description provided for @routinesAddToMyRoutines.
  ///
  /// In en, this message translates to:
  /// **'Add to my routines'**
  String get routinesAddToMyRoutines;

  /// No description provided for @routinesAddWeightOnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Add weight on success'**
  String get routinesAddWeightOnSuccess;

  /// No description provided for @routinesArchivedExplainer.
  ///
  /// In en, this message translates to:
  /// **'Archived routines stay startable and can be restored from here.'**
  String get routinesArchivedExplainer;

  /// No description provided for @routinesArchivedRoutines.
  ///
  /// In en, this message translates to:
  /// **'Archived routines'**
  String get routinesArchivedRoutines;

  /// No description provided for @routinesArchivedRoutinesCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'Archived routines could not be read'**
  String get routinesArchivedRoutinesCouldNotBe;

  /// No description provided for @routinesBaseStepWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Base step ({unit})'**
  String routinesBaseStepWithUnit(String unit);

  /// No description provided for @routinesBrowseStarterPrograms.
  ///
  /// In en, this message translates to:
  /// **'Browse starter programs'**
  String get routinesBrowseStarterPrograms;

  /// No description provided for @routinesDayCouldNotBeRead.
  ///
  /// In en, this message translates to:
  /// **'Day could not be read'**
  String get routinesDayCouldNotBeRead;

  /// No description provided for @routinesDayNameHint.
  ///
  /// In en, this message translates to:
  /// **'\"Push\", \"Pull\", \"Legs\" — a day is what you start a workout from.'**
  String get routinesDayNameHint;

  /// No description provided for @routinesDaysCouldNotBeRead.
  ///
  /// In en, this message translates to:
  /// **'Days could not be read'**
  String get routinesDaysCouldNotBeRead;

  /// No description provided for @routinesDeleteDayExplainer.
  ///
  /// In en, this message translates to:
  /// **'Its days and targets will be removed. Workouts you have already logged from it are never affected.'**
  String get routinesDeleteDayExplainer;

  /// No description provided for @routinesDeleteDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String routinesDeleteDayTitle(String name);

  /// No description provided for @routinesDeleteRoutineExplainer.
  ///
  /// In en, this message translates to:
  /// **'Its days and targets will be removed. Workouts you have already logged from it are never affected (`ADR-0004`).'**
  String get routinesDeleteRoutineExplainer;

  /// No description provided for @routinesDeleteRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String routinesDeleteRoutineTitle(String name);

  /// No description provided for @routinesDoubleProgressionExplainer.
  ///
  /// In en, this message translates to:
  /// **'Uses the Reps min/max above as the range. Deloads after three sessions in a row below the minimum.'**
  String get routinesDoubleProgressionExplainer;

  /// No description provided for @routinesDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get routinesDuplicate;

  /// No description provided for @routinesEmptyStateExplainer.
  ///
  /// In en, this message translates to:
  /// **'A routine holds days; a day is what you start a workout from. A starter program is the fastest way to get one.'**
  String get routinesEmptyStateExplainer;

  /// No description provided for @routinesGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get routinesGroup;

  /// No description provided for @routinesILlDecide.
  ///
  /// In en, this message translates to:
  /// **'I\'ll decide'**
  String get routinesILlDecide;

  /// No description provided for @routinesImportProgramExplainer.
  ///
  /// In en, this message translates to:
  /// **'Creates a new routine with {days, plural, =1{1 day} other{{days} days}}. You can edit or delete it freely afterwards — it stays independent of this template.'**
  String routinesImportProgramExplainer(int days);

  /// No description provided for @routinesItsExercisesAndTargetsWill.
  ///
  /// In en, this message translates to:
  /// **'Its exercises and targets will be removed.'**
  String get routinesItsExercisesAndTargetsWill;

  /// No description provided for @routinesLinearRuleExplainer.
  ///
  /// In en, this message translates to:
  /// **'Repeats the same weight on a partial miss; deloads after three misses in a row.'**
  String get routinesLinearRuleExplainer;

  /// No description provided for @routinesMatchEffortRpe.
  ///
  /// In en, this message translates to:
  /// **'Match effort (RPE)'**
  String get routinesMatchEffortRpe;

  /// No description provided for @routinesMoveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get routinesMoveToFolder;

  /// No description provided for @routinesMustBeAdjacent.
  ///
  /// In en, this message translates to:
  /// **'Must be adjacent'**
  String get routinesMustBeAdjacent;

  /// No description provided for @routinesNewDay.
  ///
  /// In en, this message translates to:
  /// **'New day'**
  String get routinesNewDay;

  /// No description provided for @routinesNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get routinesNewFolder;

  /// No description provided for @routinesNewRoutine.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get routinesNewRoutine;

  /// No description provided for @routinesNoDaysYet.
  ///
  /// In en, this message translates to:
  /// **'No days yet'**
  String get routinesNoDaysYet;

  /// No description provided for @routinesNoFolder.
  ///
  /// In en, this message translates to:
  /// **'No folder'**
  String get routinesNoFolder;

  /// No description provided for @routinesNoRestBetween.
  ///
  /// In en, this message translates to:
  /// **'No rest between'**
  String get routinesNoRestBetween;

  /// No description provided for @routinesNoTargetsSet.
  ///
  /// In en, this message translates to:
  /// **'No targets set'**
  String get routinesNoTargetsSet;

  /// No description provided for @routinesNoTrainingMaxSet.
  ///
  /// In en, this message translates to:
  /// **'No training max set on this exercise. Set one on the exercise\'s own editor first.'**
  String get routinesNoTrainingMaxSet;

  /// No description provided for @routinesOfTm.
  ///
  /// In en, this message translates to:
  /// **'% of TM'**
  String get routinesOfTm;

  /// No description provided for @routinesOptionalPickTheWeekdaysYou.
  ///
  /// In en, this message translates to:
  /// **'Optional — pick the weekdays you plan to train this day.'**
  String get routinesOptionalPickTheWeekdaysYou;

  /// No description provided for @routinesPercentOfTrainingMax.
  ///
  /// In en, this message translates to:
  /// **'Percent of training max'**
  String get routinesPercentOfTrainingMax;

  /// No description provided for @routinesPlannedSetsPerMuscle.
  ///
  /// In en, this message translates to:
  /// **'Planned sets per muscle'**
  String get routinesPlannedSetsPerMuscle;

  /// No description provided for @routinesProgramDayCount.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String routinesProgramDayCount(int days);

  /// No description provided for @routinesProgramSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}} could not be added — not found in your catalogue.'**
  String routinesProgramSkipped(int count);

  /// No description provided for @routinesProgression.
  ///
  /// In en, this message translates to:
  /// **'Progression'**
  String get routinesProgression;

  /// No description provided for @routinesRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get routinesRename;

  /// No description provided for @routinesRenameDay.
  ///
  /// In en, this message translates to:
  /// **'Rename day'**
  String get routinesRenameDay;

  /// No description provided for @routinesRenameRoutine.
  ///
  /// In en, this message translates to:
  /// **'Rename routine'**
  String get routinesRenameRoutine;

  /// No description provided for @routinesRepsMax.
  ///
  /// In en, this message translates to:
  /// **'Reps max'**
  String get routinesRepsMax;

  /// No description provided for @routinesRepsMin.
  ///
  /// In en, this message translates to:
  /// **'Reps min'**
  String get routinesRepsMin;

  /// No description provided for @routinesRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get routinesRest;

  /// No description provided for @routinesRestFromBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'{duration}, the built-in default for this kind of exercise.'**
  String routinesRestFromBuiltIn(String duration);

  /// No description provided for @routinesRestFromExercise.
  ///
  /// In en, this message translates to:
  /// **'{duration}, inherited from this exercise\'s own default.'**
  String routinesRestFromExercise(String duration);

  /// No description provided for @routinesRestFromGlobal.
  ///
  /// In en, this message translates to:
  /// **'{duration}, inherited from your global rest setting.'**
  String routinesRestFromGlobal(String duration);

  /// No description provided for @routinesRestFromRoutine.
  ///
  /// In en, this message translates to:
  /// **'{duration}, set here for this routine.'**
  String routinesRestFromRoutine(String duration);

  /// No description provided for @routinesRestOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Overrides the exercise and global defaults.'**
  String get routinesRestOverrideHint;

  /// No description provided for @routinesRoutineCouldNotBeRead.
  ///
  /// In en, this message translates to:
  /// **'Routine could not be read'**
  String get routinesRoutineCouldNotBeRead;

  /// No description provided for @routinesRoutinesCouldNotBeRead.
  ///
  /// In en, this message translates to:
  /// **'Routines could not be read'**
  String get routinesRoutinesCouldNotBeRead;

  /// No description provided for @routinesSaveTargets.
  ///
  /// In en, this message translates to:
  /// **'Save targets'**
  String get routinesSaveTargets;

  /// No description provided for @routinesSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get routinesSchedule;

  /// No description provided for @routinesSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String routinesSelectedCount(int count);

  /// No description provided for @routinesSetTargetsToSeeSets.
  ///
  /// In en, this message translates to:
  /// **'Set targets to see sets per muscle here.'**
  String get routinesSetTargetsToSeeSets;

  /// No description provided for @routinesSetsPerMuscle.
  ///
  /// In en, this message translates to:
  /// **'Sets per muscle'**
  String get routinesSetsPerMuscle;

  /// No description provided for @routinesStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get routinesStartWorkout;

  /// No description provided for @routinesStarterPrograms.
  ///
  /// In en, this message translates to:
  /// **'Starter programs'**
  String get routinesStarterPrograms;

  /// No description provided for @routinesTargetRpe.
  ///
  /// In en, this message translates to:
  /// **'Target RPE'**
  String get routinesTargetRpe;

  /// No description provided for @routinesTargetRpeHint.
  ///
  /// In en, this message translates to:
  /// **'How hard the last set should feel. Comes in easier — add more; harder — add less or back off.'**
  String get routinesTargetRpeHint;

  /// No description provided for @routinesTargetWeightWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Target weight ({unit})'**
  String routinesTargetWeightWithUnit(String unit);

  /// No description provided for @routinesThisDayNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This day no longer exists.'**
  String get routinesThisDayNoLongerExists;

  /// No description provided for @routinesThisRoutineNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This routine no longer exists.'**
  String get routinesThisRoutineNoLongerExists;

  /// No description provided for @routinesTrainingMaxIs.
  ///
  /// In en, this message translates to:
  /// **'Training max {weight} {unit}. Recomputed every time this day is started — no week/cycle variation yet.'**
  String routinesTrainingMaxIs(String weight, String unit);

  /// No description provided for @routinesUngroup.
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get routinesUngroup;

  /// No description provided for @routinesWithinGroupRest.
  ///
  /// In en, this message translates to:
  /// **'Rest between superset members'**
  String get routinesWithinGroupRest;

  /// No description provided for @routinesWithinGroupRestExplainer.
  ///
  /// In en, this message translates to:
  /// **'Zero is what a superset usually means. A few seconds is for walking between two machines without the timer treating it as a full rest.'**
  String get routinesWithinGroupRestExplainer;

  /// No description provided for @settings100Kg8.
  ///
  /// In en, this message translates to:
  /// **'100 kg × 8'**
  String get settings100Kg8;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAddABar.
  ///
  /// In en, this message translates to:
  /// **'Add a bar'**
  String get settingsAddABar;

  /// No description provided for @settingsAddAPlate.
  ///
  /// In en, this message translates to:
  /// **'Add a plate'**
  String get settingsAddAPlate;

  /// No description provided for @settingsAllDataWiped.
  ///
  /// In en, this message translates to:
  /// **'All data wiped.'**
  String get settingsAllDataWiped;

  /// No description provided for @settingsAllExercisesResolved.
  ///
  /// In en, this message translates to:
  /// **'All exercises resolved.'**
  String get settingsAllExercisesResolved;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockExplainer.
  ///
  /// In en, this message translates to:
  /// **'A PIN gates the whole app on launch and whenever it returns from the background. This is a screen lock, not encryption — it protects against a casual look, not a determined one.'**
  String get settingsAppLockExplainer;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppliesToWeeklyVolumeSets.
  ///
  /// In en, this message translates to:
  /// **'Applies to weekly volume, sets-per-muscle and streaks.'**
  String get settingsAppliesToWeeklyVolumeSets;

  /// No description provided for @settingsAutoStartRestExplainer.
  ///
  /// In en, this message translates to:
  /// **'Completing a set starts the rest timer, and completing the next one restarts it.'**
  String get settingsAutoStartRestExplainer;

  /// No description provided for @settingsAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsAutomatic;

  /// No description provided for @settingsAutomaticLength.
  ///
  /// In en, this message translates to:
  /// **'automatic length'**
  String get settingsAutomaticLength;

  /// No description provided for @settingsBackUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get settingsBackUpNow;

  /// No description provided for @settingsBackingUp.
  ///
  /// In en, this message translates to:
  /// **'Backing up…'**
  String get settingsBackingUp;

  /// No description provided for @settingsBackupExplainer.
  ///
  /// In en, this message translates to:
  /// **'A backup is a full, versioned copy of everything on this device, saved here so restore can find it later.'**
  String get settingsBackupExplainer;

  /// No description provided for @settingsBackupFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Backup failed. Try again.'**
  String get settingsBackupFailedTryAgain;

  /// No description provided for @settingsBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get settingsBackupSaved;

  /// No description provided for @settingsBarsPlates.
  ///
  /// In en, this message translates to:
  /// **'Bars & plates'**
  String get settingsBarsPlates;

  /// No description provided for @settingsBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get settingsBodyweight;

  /// No description provided for @settingsCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get settingsCardio;

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @settingsChooseACsvFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a CSV file'**
  String get settingsChooseACsvFile;

  /// No description provided for @settingsChooseAPin4Or.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN (4 or more digits)'**
  String get settingsChooseAPin4Or;

  /// No description provided for @settingsCircumferences.
  ///
  /// In en, this message translates to:
  /// **'Circumferences'**
  String get settingsCircumferences;

  /// No description provided for @settingsColoursInThisTheme.
  ///
  /// In en, this message translates to:
  /// **'Colours in this theme'**
  String get settingsColoursInThisTheme;

  /// No description provided for @settingsConfirmTheNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm the new PIN'**
  String get settingsConfirmTheNewPin;

  /// No description provided for @settingsCouldNotLoadSampleData.
  ///
  /// In en, this message translates to:
  /// **'Could not load sample data.'**
  String get settingsCouldNotLoadSampleData;

  /// No description provided for @settingsCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get settingsCreateNew;

  /// No description provided for @settingsCsvExportExplainer.
  ///
  /// In en, this message translates to:
  /// **'For spreadsheets, not backup — one CSV each for sets, body measurements and routines, in your display units.'**
  String get settingsCsvExportExplainer;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsDefaultBar.
  ///
  /// In en, this message translates to:
  /// **'Default bar'**
  String get settingsDefaultBar;

  /// No description provided for @settingsDefaultRest.
  ///
  /// In en, this message translates to:
  /// **'Default rest'**
  String get settingsDefaultRest;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get settingsDelete;

  /// No description provided for @settingsDemoDataExplainer.
  ///
  /// In en, this message translates to:
  /// **'Debug build only — never reachable in a release. Adds 8 weeks of a Push/Pull/Legs split plus weekly bodyweight, so the analytics screens have something to show without hand-logging sessions.'**
  String get settingsDemoDataExplainer;

  /// No description provided for @settingsDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get settingsDistance;

  /// No description provided for @settingsDistanceUnitNote.
  ///
  /// In en, this message translates to:
  /// **'Separate from weights on purpose'**
  String get settingsDistanceUnitNote;

  /// No description provided for @settingsDynamicColour.
  ///
  /// In en, this message translates to:
  /// **'Dynamic colour'**
  String get settingsDynamicColour;

  /// No description provided for @settingsDynamicColourExplainer.
  ///
  /// In en, this message translates to:
  /// **'Tint the app from your wallpaper. Android 12+ only — off does nothing on a phone that doesn\'t support it.'**
  String get settingsDynamicColourExplainer;

  /// No description provided for @settingsE1rmFormula.
  ///
  /// In en, this message translates to:
  /// **'e1RM formula'**
  String get settingsE1rmFormula;

  /// No description provided for @settingsEditBar.
  ///
  /// In en, this message translates to:
  /// **'Edit bar'**
  String get settingsEditBar;

  /// No description provided for @settingsEnterTheCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter the current PIN'**
  String get settingsEnterTheCurrentPin;

  /// No description provided for @settingsEpleyDefault.
  ///
  /// In en, this message translates to:
  /// **'Epley (default)'**
  String get settingsEpleyDefault;

  /// No description provided for @settingsExportDataCsv.
  ///
  /// In en, this message translates to:
  /// **'Export data (.csv)'**
  String get settingsExportDataCsv;

  /// No description provided for @settingsExportDataJson.
  ///
  /// In en, this message translates to:
  /// **'Export data (.json)'**
  String get settingsExportDataJson;

  /// No description provided for @settingsExportFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Try again.'**
  String get settingsExportFailedTryAgain;

  /// No description provided for @settingsFewerPairs.
  ///
  /// In en, this message translates to:
  /// **'Fewer pairs'**
  String get settingsFewerPairs;

  /// No description provided for @settingsFitnessappCsvExport.
  ///
  /// In en, this message translates to:
  /// **'FitnessApp CSV export'**
  String get settingsFitnessappCsvExport;

  /// No description provided for @settingsFitnessappExport.
  ///
  /// In en, this message translates to:
  /// **'FitnessApp export'**
  String get settingsFitnessappExport;

  /// No description provided for @settingsGhostValues.
  ///
  /// In en, this message translates to:
  /// **'Ghost values'**
  String get settingsGhostValues;

  /// No description provided for @settingsHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get settingsHealthConnect;

  /// No description provided for @settingsHealthConnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share workouts, read bodyweight — off by default'**
  String get settingsHealthConnectSubtitle;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsImport;

  /// No description provided for @settingsImportComplete.
  ///
  /// In en, this message translates to:
  /// **'Import complete.'**
  String get settingsImportComplete;

  /// No description provided for @settingsImportDone.
  ///
  /// In en, this message translates to:
  /// **'{workouts, plural, =1{1 workout} other{{workouts} workouts}} and {sets, plural, =1{1 set} other{{sets} sets}} imported.'**
  String settingsImportDone(int workouts, int sets);

  /// No description provided for @settingsImportExplainer.
  ///
  /// In en, this message translates to:
  /// **'Bring your history over from Strong or Hevy — nothing is written until you confirm what to do with each exercise.'**
  String get settingsImportExplainer;

  /// No description provided for @settingsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed.'**
  String get settingsImportFailed;

  /// No description provided for @settingsImportFailedNothingWasChanged.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Nothing was changed.'**
  String get settingsImportFailedNothingWasChanged;

  /// No description provided for @settingsImportFromStrongOrHevy.
  ///
  /// In en, this message translates to:
  /// **'Import from Strong or Hevy'**
  String get settingsImportFromStrongOrHevy;

  /// No description provided for @settingsImportPreviewFound.
  ///
  /// In en, this message translates to:
  /// **'{workouts, plural, =1{1 workout} other{{workouts} workouts}}, {sets, plural, =1{1 set} other{{sets} sets}} found.'**
  String settingsImportPreviewFound(int workouts, int sets);

  /// No description provided for @settingsImportScreenExplainer.
  ///
  /// In en, this message translates to:
  /// **'Import your training history from a Strong or Hevy CSV export. Nothing is written until you confirm.'**
  String get settingsImportScreenExplainer;

  /// No description provided for @settingsImportSkippedDuplicates.
  ///
  /// In en, this message translates to:
  /// **' {count, plural, =1{1 already-imported workout skipped.} other{{count} already-imported workouts skipped.}}'**
  String settingsImportSkippedDuplicates(int count);

  /// No description provided for @settingsJsonDumpExplainer.
  ///
  /// In en, this message translates to:
  /// **'Every table, every row, exactly as stored — a rescue copy, not a polished backup. Share it somewhere safe.'**
  String get settingsJsonDumpExplainer;

  /// No description provided for @settingsKilograms.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get settingsKilograms;

  /// No description provided for @settingsLastTime975Kg.
  ///
  /// In en, this message translates to:
  /// **'last time: 97.5 kg × 8'**
  String get settingsLastTime975Kg;

  /// No description provided for @settingsLoadSampleDataDebug.
  ///
  /// In en, this message translates to:
  /// **'Load sample data (debug)'**
  String get settingsLoadSampleDataDebug;

  /// No description provided for @settingsManualStart.
  ///
  /// In en, this message translates to:
  /// **'Manual start'**
  String get settingsManualStart;

  /// No description provided for @settingsMatchTheDeviceSetting.
  ///
  /// In en, this message translates to:
  /// **'Match the device setting'**
  String get settingsMatchTheDeviceSetting;

  /// No description provided for @settingsMeasurementReminders.
  ///
  /// In en, this message translates to:
  /// **'Measurement reminders'**
  String get settingsMeasurementReminders;

  /// No description provided for @settingsMeasurementRemindersExplainer.
  ///
  /// In en, this message translates to:
  /// **'Off by default. A weekly nudge to log bodyweight and measurements.'**
  String get settingsMeasurementRemindersExplainer;

  /// No description provided for @settingsMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get settingsMeasurements;

  /// No description provided for @settingsMorePairs.
  ///
  /// In en, this message translates to:
  /// **'More pairs'**
  String get settingsMorePairs;

  /// No description provided for @settingsNewBar.
  ///
  /// In en, this message translates to:
  /// **'New bar'**
  String get settingsNewBar;

  /// No description provided for @settingsNewPlate.
  ///
  /// In en, this message translates to:
  /// **'New plate'**
  String get settingsNewPlate;

  /// No description provided for @settingsNoBarsConfiguredYet.
  ///
  /// In en, this message translates to:
  /// **'No bars configured yet.'**
  String get settingsNoBarsConfiguredYet;

  /// No description provided for @settingsNoPlatesConfiguredYet.
  ///
  /// In en, this message translates to:
  /// **'No plates configured yet.'**
  String get settingsNoPlatesConfiguredYet;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get settingsOk;

  /// No description provided for @settingsOpenSourceLicences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get settingsOpenSourceLicences;

  /// No description provided for @settingsPairsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None available} =1{1 pair available} other{{count} pairs available}}'**
  String settingsPairsAvailable(int count);

  /// No description provided for @settingsPairsAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Pairs available'**
  String get settingsPairsAvailableLabel;

  /// No description provided for @settingsPersonalRecordsRebuilt.
  ///
  /// In en, this message translates to:
  /// **'Personal records rebuilt.'**
  String get settingsPersonalRecordsRebuilt;

  /// No description provided for @settingsPounds.
  ///
  /// In en, this message translates to:
  /// **'Pounds'**
  String get settingsPounds;

  /// No description provided for @settingsPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get settingsPreview;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacySummary.
  ///
  /// In en, this message translates to:
  /// **'No account. No server. No telemetry. This app makes no network calls at all, and your training data never leaves the device unless you export it yourself.'**
  String get settingsPrivacySummary;

  /// No description provided for @settingsRateOfPerceivedExertionPer.
  ///
  /// In en, this message translates to:
  /// **'Rate of perceived exertion per set, 6.0–10.0.'**
  String get settingsRateOfPerceivedExertionPer;

  /// No description provided for @settingsRebuildFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Rebuild failed. Try again.'**
  String get settingsRebuildFailedTryAgain;

  /// No description provided for @settingsRebuildPersonalRecords.
  ///
  /// In en, this message translates to:
  /// **'Rebuild personal records'**
  String get settingsRebuildPersonalRecords;

  /// No description provided for @settingsRebuildPrsExplainer.
  ///
  /// In en, this message translates to:
  /// **'Personal records are a cache rebuilt from your logged sets. If one ever looks wrong, rebuilding it from scratch is always safe.'**
  String get settingsRebuildPrsExplainer;

  /// No description provided for @settingsRemoveAppLock.
  ///
  /// In en, this message translates to:
  /// **'Remove app lock?'**
  String get settingsRemoveAppLock;

  /// No description provided for @settingsRemovePin.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get settingsRemovePin;

  /// No description provided for @settingsRemovePlateNote.
  ///
  /// In en, this message translates to:
  /// **'The calculator will stop proposing it.'**
  String get settingsRemovePlateNote;

  /// No description provided for @settingsRemoveThisPlate.
  ///
  /// In en, this message translates to:
  /// **'Remove this plate?'**
  String get settingsRemoveThisPlate;

  /// No description provided for @settingsRestAlertLimitation.
  ///
  /// In en, this message translates to:
  /// **'The alert needs the app to still be running. Notifications that survive the phone putting the app to sleep arrive with F-TIM-003.'**
  String get settingsRestAlertLimitation;

  /// No description provided for @settingsRestAlerts.
  ///
  /// In en, this message translates to:
  /// **'Rest timer alerts'**
  String get settingsRestAlerts;

  /// No description provided for @settingsRestAlertsExplainer.
  ///
  /// In en, this message translates to:
  /// **'A notification when a rest ends, so the phone can go back in your pocket.'**
  String get settingsRestAlertsExplainer;

  /// No description provided for @settingsRestDefaultOverrideNote.
  ///
  /// In en, this message translates to:
  /// **'An exercise with its own rest duration always wins over this.'**
  String get settingsRestDefaultOverrideNote;

  /// No description provided for @settingsRestDefaultsHint.
  ///
  /// In en, this message translates to:
  /// **'Longer for barbell and compound work, shorter for isolation.'**
  String get settingsRestDefaultsHint;

  /// No description provided for @settingsRestoreComplete.
  ///
  /// In en, this message translates to:
  /// **'Restore complete.'**
  String get settingsRestoreComplete;

  /// No description provided for @settingsRestoreConfirmExplainer.
  ///
  /// In en, this message translates to:
  /// **'This replaces every workout, routine and setting on this device with what is in the backup file. A safety copy of what is here now is saved first.'**
  String get settingsRestoreConfirmExplainer;

  /// No description provided for @settingsRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed.'**
  String get settingsRestoreFailed;

  /// No description provided for @settingsRestoreFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Try again.'**
  String get settingsRestoreFailedTryAgain;

  /// No description provided for @settingsRestoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup?'**
  String get settingsRestoreFromBackup;

  /// No description provided for @settingsRestoreFromBackup2.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup…'**
  String get settingsRestoreFromBackup2;

  /// No description provided for @settingsRpe.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get settingsRpe;

  /// No description provided for @settingsSampleDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'Sample data loaded.'**
  String get settingsSampleDataLoaded;

  /// No description provided for @settingsSessionVolume.
  ///
  /// In en, this message translates to:
  /// **'Session volume'**
  String get settingsSessionVolume;

  /// No description provided for @settingsSetAPin.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get settingsSetAPin;

  /// No description provided for @settingsSetsTargetsPlatesAndBars.
  ///
  /// In en, this message translates to:
  /// **'Sets, targets, plates and bars'**
  String get settingsSetsTargetsPlatesAndBars;

  /// No description provided for @settingsSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get settingsSkip;

  /// No description provided for @settingsSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get settingsSourceCode;

  /// No description provided for @settingsStartAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Start automatically'**
  String get settingsStartAutomatically;

  /// No description provided for @settingsStartsAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Starts automatically'**
  String get settingsStartsAutomatically;

  /// No description provided for @settingsTheAppWillOpenWithout.
  ///
  /// In en, this message translates to:
  /// **'The app will open without a PIN.'**
  String get settingsTheAppWillOpenWithout;

  /// No description provided for @settingsTheFullTextInThe.
  ///
  /// In en, this message translates to:
  /// **'The full text, in the app\'s repository'**
  String get settingsTheFullTextInThe;

  /// No description provided for @settingsTopSet.
  ///
  /// In en, this message translates to:
  /// **'Top set'**
  String get settingsTopSet;

  /// No description provided for @settingsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get settingsTryAgain;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnits;

  /// No description provided for @settingsUnitsExplainer.
  ///
  /// In en, this message translates to:
  /// **'Changing a unit only changes how numbers are shown. Nothing stored is rewritten, so switching back is lossless.'**
  String get settingsUnitsExplainer;

  /// No description provided for @settingsUseExisting.
  ///
  /// In en, this message translates to:
  /// **'Use existing'**
  String get settingsUseExisting;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsW1Reps30.
  ///
  /// In en, this message translates to:
  /// **'w × (1 + reps / 30)'**
  String get settingsW1Reps30;

  /// No description provided for @settingsW3637Reps.
  ///
  /// In en, this message translates to:
  /// **'w × 36 / (37 − reps)'**
  String get settingsW3637Reps;

  /// No description provided for @settingsWReps010.
  ///
  /// In en, this message translates to:
  /// **'w × reps^0.10'**
  String get settingsWReps010;

  /// No description provided for @settingsWarnBeforeTheEnd.
  ///
  /// In en, this message translates to:
  /// **'Warn before the end'**
  String get settingsWarnBeforeTheEnd;

  /// No description provided for @settingsWeekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get settingsWeekStartsOn;

  /// No description provided for @settingsWeightWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight ({unit})'**
  String settingsWeightWithUnit(String unit);

  /// No description provided for @settingsWeights.
  ///
  /// In en, this message translates to:
  /// **'Weights'**
  String get settingsWeights;

  /// No description provided for @settingsWipe.
  ///
  /// In en, this message translates to:
  /// **'Wipe'**
  String get settingsWipe;

  /// No description provided for @settingsWipeAllData.
  ///
  /// In en, this message translates to:
  /// **'Wipe all data?'**
  String get settingsWipeAllData;

  /// No description provided for @settingsWipeAllData2.
  ///
  /// In en, this message translates to:
  /// **'Wipe all data'**
  String get settingsWipeAllData2;

  /// No description provided for @settingsWipeConfirmExplainer.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every workout, routine and setting on this device. Type DELETE to confirm.'**
  String get settingsWipeConfirmExplainer;

  /// No description provided for @settingsWipeExplainer.
  ///
  /// In en, this message translates to:
  /// **'Wiping deletes everything on this device and returns the app to its first-run state. A backup is taken first.'**
  String get settingsWipeExplainer;

  /// No description provided for @settingsWipeFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Wipe failed. Try again.'**
  String get settingsWipeFailedTryAgain;

  /// No description provided for @settingsWorkoutReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders'**
  String get settingsWorkoutReminders;

  /// No description provided for @settingsWorkoutRemindersExplainer.
  ///
  /// In en, this message translates to:
  /// **'Off by default. A nudge on the days your routine is scheduled for.'**
  String get settingsWorkoutRemindersExplainer;

  /// No description provided for @settingsWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN.'**
  String get settingsWrongPin;

  /// No description provided for @shellAtLeastThreeSessionsAre.
  ///
  /// In en, this message translates to:
  /// **'At least three sessions are needed for a trend.'**
  String get shellAtLeastThreeSessionsAre;

  /// No description provided for @shellDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get shellDelete;

  /// No description provided for @shellEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get shellEnterPin;

  /// No description provided for @shellGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get shellGoHome;

  /// No description provided for @shellHoldTo.
  ///
  /// In en, this message translates to:
  /// **'Hold to {action}'**
  String shellHoldTo(String action);

  /// No description provided for @shellInProgressElapsed.
  ///
  /// In en, this message translates to:
  /// **'In progress · {elapsed}'**
  String shellInProgressElapsed(String elapsed);

  /// No description provided for @shellKeepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get shellKeepIt;

  /// No description provided for @shellLogAFewSessionsTo.
  ///
  /// In en, this message translates to:
  /// **'Log a few sessions to see this chart.'**
  String get shellLogAFewSessionsTo;

  /// No description provided for @shellLogItToTrackAlongside.
  ///
  /// In en, this message translates to:
  /// **'Log it to track alongside your lifts.'**
  String get shellLogItToTrackAlongside;

  /// No description provided for @shellNextUpDay.
  ///
  /// In en, this message translates to:
  /// **'Next up: {day}'**
  String shellNextUpDay(String day);

  /// No description provided for @shellNoBodyweightLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No bodyweight logged yet'**
  String get shellNoBodyweightLoggedYet;

  /// No description provided for @shellNoWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get shellNoWorkoutsYet;

  /// No description provided for @shellNotEnoughDataYet.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get shellNotEnoughDataYet;

  /// No description provided for @shellNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get shellNotFound;

  /// No description provided for @shellPersonalRecord.
  ///
  /// In en, this message translates to:
  /// **'Personal record'**
  String get shellPersonalRecord;

  /// No description provided for @shellPlateLoadingDiagram.
  ///
  /// In en, this message translates to:
  /// **'Plate loading diagram'**
  String get shellPlateLoadingDiagram;

  /// No description provided for @shellReadyToTrain.
  ///
  /// In en, this message translates to:
  /// **'Ready to train?'**
  String get shellReadyToTrain;

  /// No description provided for @shellRecentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get shellRecentWorkouts;

  /// No description provided for @shellRecentWorkoutsCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts could not be read'**
  String get shellRecentWorkoutsCouldNotBe;

  /// No description provided for @shellSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get shellSettings;

  /// No description provided for @shellSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get shellSomethingWentWrong;

  /// No description provided for @shellStartAWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start a workout'**
  String get shellStartAWorkout;

  /// No description provided for @shellThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get shellThisWeek;

  /// No description provided for @shellTodaysDay.
  ///
  /// In en, this message translates to:
  /// **'Today: {day}'**
  String shellTodaysDay(String day);

  /// No description provided for @shellTryAgainInAMoment.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get shellTryAgainInAMoment;

  /// No description provided for @shellUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get shellUnlock;

  /// No description provided for @shellWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get shellWrongPin;

  /// No description provided for @shellYourFinishedSessionsWillShow.
  ///
  /// In en, this message translates to:
  /// **'Your finished sessions will show up here.'**
  String get shellYourFinishedSessionsWillShow;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @timingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String timingMinutes(int count);

  /// No description provided for @timingNoTime.
  ///
  /// In en, this message translates to:
  /// **'no time'**
  String get timingNoTime;

  /// No description provided for @timingSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String timingSeconds(int count);

  /// No description provided for @timingSkipRest.
  ///
  /// In en, this message translates to:
  /// **'Skip rest'**
  String get timingSkipRest;

  /// No description provided for @trackingBodyweightReps.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight reps'**
  String get trackingBodyweightReps;

  /// No description provided for @trackingDistanceTime.
  ///
  /// In en, this message translates to:
  /// **'Distance & time'**
  String get trackingDistanceTime;

  /// No description provided for @trackingReps.
  ///
  /// In en, this message translates to:
  /// **'Reps only'**
  String get trackingReps;

  /// No description provided for @trackingTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get trackingTime;

  /// No description provided for @trackingWeightReps.
  ///
  /// In en, this message translates to:
  /// **'Weight × reps'**
  String get trackingWeightReps;

  /// No description provided for @trackingWeightTime.
  ///
  /// In en, this message translates to:
  /// **'Weight & time'**
  String get trackingWeightTime;
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
