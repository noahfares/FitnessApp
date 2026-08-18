import 'package:flutter/material.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/units/mass.dart';
import '../../../domain/progression/progression_rationale.dart';
import '../../../l10n/app_localizations.dart';

/// "You hit every set at 100 kg last time, so this is +2.5 kg." — the one
/// sentence every proposed target carries (`F-PRG-008` §1). Composed here,
/// not in `domain/`, because it needs the user's display unit
/// (docs/22-UNITS.md, `CLAUDE.md`'s canonical-units invariant): the
/// rationale itself only ever stores grams.
String progressionRationaleText(
  ProgressionRationale rationale,
  QuantityFormatter formatter,
  MassUnit unit,
  AppLocalizations l10n,
) {
  String weight(int grams) =>
      formatter.massValueOnly(Mass.grams(grams), unit, maxDecimals: 2);

  final previousWeight = rationale.previousWeightGrams;
  final previousReps = rationale.previousReps;
  final hadPrevious = previousWeight != null && previousReps != null;

  switch (rationale.outcome) {
    case ProgressionOutcome.firstRun:
      return l10n.progressionFirstRun;
    case ProgressionOutcome.manualCarryForward:
      return hadPrevious
          ? l10n.progressionCarriedForward(
              previousReps,
              weight(previousWeight),
              unit.symbol,
            )
          : l10n.progressionFirstRun;
    case ProgressionOutcome.success:
      return l10n.progressionSuccess(
        weight(previousWeight!),
        unit.symbol,
        weight(rationale.deltaGrams),
      );
    case ProgressionOutcome.partial:
      return l10n.progressionPartial;
    case ProgressionOutcome.failure:
      return l10n.progressionFailure(rationale.consecutiveFailures);
    case ProgressionOutcome.deload:
      return l10n.progressionDeload(
        rationale.consecutiveFailures,
        weight(previousWeight! + rationale.deltaGrams),
        unit.symbol,
      );
    case ProgressionOutcome.repRangeTopMet:
      return l10n.progressionRepRangeTopMet(
        weight(previousWeight!),
        unit.symbol,
        weight(rationale.deltaGrams),
      );
    case ProgressionOutcome.plateRoundingHeld:
      return l10n.progressionPlateRoundingHeld(
        weight(previousWeight!),
        unit.symbol,
      );
    case ProgressionOutcome.percentageOfTrainingMax:
      final trainingMax = rationale.trainingMaxGrams;
      final percent = rationale.percent;
      if (trainingMax == null || percent == null) {
        return l10n.progressionFromTrainingMax;
      }
      return l10n.progressionPercentOfTrainingMax(
        (percent * 100).round(),
        weight(trainingMax),
        unit.symbol,
      );
  }
}

/// Collapsed to one line, expandable on tap — same interaction as
/// `_StickyNoteText` on this screen (`F-PRG-008` §2).
class ProgressionRationaleText extends StatefulWidget {
  const ProgressionRationaleText({super.key, required this.text});

  final String text;

  @override
  State<ProgressionRationaleText> createState() =>
      _ProgressionRationaleTextState();
}

class _ProgressionRationaleTextState extends State<ProgressionRationaleText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.trending_up,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.text,
              maxLines: _expanded ? null : 1,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
