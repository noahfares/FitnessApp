import 'package:flutter/material.dart';

import '../../../core/a11y/chart_summary.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/units/week_start.dart';

/// Consistency grid (`F-ANA-006`, component inventory `CalendarHeatmap`) —
/// one column per week, one cell per day. Deliberately only two states per
/// cell (trained / not) — no colour ramp by volume, no red for a miss: "no
/// loss animations, no guilt copy" (§5 rule 4) applies to colour choices
/// too, not just motion.
class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({
    required this.trainingDays,
    required this.weekStart,
    required this.now,
    super.key,
    this.weeksToShow = 12,
  });

  final Set<DateTime> trainingDays;
  final WeekStart weekStart;
  final DateTime now;
  final int weeksToShow;

  static const double _cellSize = 14;
  static const double _cellGap = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trainedColor = context.appColors.success;
    final emptyColor = theme.colorScheme.surfaceContainerHighest;
    final currentWeek = weekStart.weekStartFor(now);

    // A grid of coloured squares says nothing out loud (`F-A11Y-001`). The
    // spoken form is the count and the rate — the same two facts the grid is
    // read for — rather than an attempt to narrate its shape.
    final trainedInWindow = [
      for (var w = weeksToShow - 1; w >= 0; w--)
        for (var d = 0; d < 7; d++)
          if (trainingDays.contains(
            currentWeek.subtract(Duration(days: 7 * w - d)),
          ))
            1,
    ].length;

    return Semantics(
      label: calendarSummary(
        trainedDays: trainedInWindow,
        totalDays: weeksToShow * 7,
        rangeLabel: 'over the last $weeksToShow weeks',
      ),
      image: true,
      child: ExcludeSemantics(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var w = weeksToShow - 1; w >= 0; w--)
                Padding(
                  padding: const EdgeInsets.only(right: _cellGap),
                  child: Column(
                    children: [
                      for (var d = 0; d < 7; d++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: _cellGap),
                          child: _Cell(
                            trained: trainingDays.contains(
                              currentWeek.subtract(Duration(days: 7 * w - d)),
                            ),
                            trainedColor: trainedColor,
                            emptyColor: emptyColor,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.trained,
    required this.trainedColor,
    required this.emptyColor,
  });

  final bool trained;
  final Color trainedColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) => Container(
    width: CalendarHeatmap._cellSize,
    height: CalendarHeatmap._cellSize,
    decoration: BoxDecoration(
      color: trained ? trainedColor : emptyColor,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
