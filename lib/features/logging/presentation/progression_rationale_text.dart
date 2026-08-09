import 'package:flutter/material.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/units/mass.dart';
import '../../../domain/progression/progression_rationale.dart';

/// "You hit every set at 100 kg last time, so this is +2.5 kg." — the one
/// sentence every proposed target carries (`F-PRG-008` §1). Composed here,
/// not in `domain/`, because it needs the user's display unit
/// (docs/22-UNITS.md, `CLAUDE.md`'s canonical-units invariant): the
/// rationale itself only ever stores grams.
String progressionRationaleText(
  ProgressionRationale rationale,
  QuantityFormatter formatter,
  MassUnit unit,
) {
  String weight(int grams) =>
      formatter.massValueOnly(Mass.grams(grams), unit, maxDecimals: 2);

  final previousWeight = rationale.previousWeightGrams;
  final previousReps = rationale.previousReps;
  final hadPrevious = previousWeight != null && previousReps != null;

  switch (rationale.outcome) {
    case ProgressionOutcome.firstRun:
      return "No history for this exercise yet — using the routine's own "
          'target.';
    case ProgressionOutcome.manualCarryForward:
      return hadPrevious
          ? 'Carried forward from last time: $previousReps at '
                '${weight(previousWeight)} ${unit.symbol}.'
          : "No history yet — using the routine's own target.";
    case ProgressionOutcome.success:
      return 'You hit every set at ${weight(previousWeight!)} '
          '${unit.symbol} last time, so this is +'
          '${weight(rationale.deltaGrams)} ${unit.symbol}.';
    case ProgressionOutcome.partial:
      return 'Some sets missed target last time — repeating the same '
          'weight.';
    case ProgressionOutcome.failure:
      return 'Missed target last time (${rationale.consecutiveFailures} in '
          'a row) — repeating the same weight.';
    case ProgressionOutcome.deload:
      return 'Missed target ${rationale.consecutiveFailures} sessions in a '
          'row — deloading to ${weight(previousWeight! + rationale.deltaGrams)} '
          '${unit.symbol}.';
    case ProgressionOutcome.repRangeTopMet:
      return 'You hit the top of your rep range at '
          '${weight(previousWeight!)} ${unit.symbol} last time, so this is +'
          '${weight(rationale.deltaGrams)} ${unit.symbol} — back to the '
          'bottom of the range.';
    case ProgressionOutcome.plateRoundingHeld:
      return "The next jump isn't assemblable from your plates, so weight "
          'stays at ${weight(previousWeight!)} ${unit.symbol} and reps go up '
          'by one instead.';
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
