import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/analytics/weekly_insights.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalog/presentation/exercise_labels.dart';

/// "Chest volume is up 40% versus your 4-week average." (`F-ANA-013` §1) —
/// composed here, not in `domain/`, for the same reason
/// `progressionRationaleText` lives outside `domain/`: it needs the user's
/// display unit and a muscle's display label, both presentation concerns.
String weeklyInsightText(
  WeeklyInsight insight,
  QuantityFormatter formatter,
  MassUnit unit,
  AppLocalizations l10n,
) {
  String muscleLabel(String? name) {
    if (name == null) return l10n.analyticsThisMuscle;
    // No DB-level guarantee every stored name is still a recognised
    // `Muscle` (same reasoning `F-ROU-011`'s preview chart already used) —
    // the raw name is still a readable fallback.
    return Muscle.values.asNameMap()[name]?.label(l10n) ?? name;
  }

  switch (insight.kind) {
    case InsightKind.muscleVolumeChange:
      final percent =
          insight.previousValue == null || insight.previousValue == 0
          ? 0.0
          : (insight.currentValue - insight.previousValue!) /
                insight.previousValue!;
      final direction = percent >= 0 ? 'up' : 'down';
      return '${muscleLabel(insight.muscle)} volume is $direction '
          '${(percent.abs() * 100).round()}% versus your 4-week average.';
    case InsightKind.exerciseE1rmNewHigh:
      final deltaGrams = (insight.currentValue - (insight.previousValue ?? 0))
          .round();
      final name = insight.exerciseName ?? l10n.analyticsThisExercise;
      return '$name e1RM up '
          '${formatter.massValueOnly(Mass.grams(deltaGrams), unit, maxDecimals: 1)} '
          '${unit.symbol} this week.';
    case InsightKind.muscleSetsLastWeek:
      final sets = insight.currentValue;
      final formatted = sets == sets.roundToDouble()
          ? sets.toStringAsFixed(0)
          : sets.toStringAsFixed(1);
      return '${muscleLabel(insight.muscle)}: $formatted sets last week.';
  }
}
