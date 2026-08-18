import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/a11y/chart_summary.dart';
import '../../../core/a11y/motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'empty_state.dart';
import '../../../core/l10n/l10n.dart';

/// One bar.
class WeeklyBarPoint {
  const WeeklyBarPoint({required this.value, required this.label});

  final double value;

  /// Shown on the x axis and in the tooltip — e.g. a formatted week-start date.
  final String label;
}

/// Weekly bar chart (`F-THM-004`, `F-ANA-004`/`F-ANA-005`, component
/// inventory `BarChart`).
///
/// Always zero-based on Y — unlike `TrendChart`, bar length itself encodes
/// magnitude (`docs/24-DESIGN-SYSTEM.md` §Charts), so a non-zero baseline
/// would misrepresent every bar's proportions.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    required this.points,
    required this.valueLabel,
    required this.metricLabel,
    super.key,
    this.subtitle,
    this.onBarTap,
    this.referenceBand,
  });

  final List<WeeklyBarPoint> points;
  final String Function(double value) valueLabel;

  /// What the bars measure, in words — "Weekly volume", "Hard sets for chest".
  /// The opening of the spoken alternative (`F-A11Y-001`).
  final String metricLabel;

  final String? subtitle;

  /// A shaded band behind the bars — "common volume targets"
  /// (`F-ANA-005` §2). Drawn as a range rather than a single line because the
  /// evidence is a range: presenting one number as *the* answer would be
  /// making a prescription out of a rough guide, which this app does not do.
  final ({double min, double max, String label})? referenceBand;

  /// Per-bar tap-through (`F-ANA-016`) — e.g. scoping a drill-down list to
  /// the tapped week. Null skips the tap gesture entirely. The index is
  /// into [points], so the caller can map back to its own richer data for
  /// the same bar (`WeeklyBarPoint` itself only carries a display label).
  final void Function(int index, WeeklyBarPoint point)? onBarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.isEmpty) {
      return EmptyState(
        icon: Icons.bar_chart,
        title: context.l10n.shellNotEnoughDataYet,
        message: context.l10n.shellLogAFewSessionsTo,
      );
    }

    final band = referenceBand;
    final maxValue = [
      ...points.map((p) => p.value),
      // The band has to fit, or a chart whose bars are all below the
      // recommended range would simply not show the range.
      if (band != null) band.max,
    ].reduce((a, b) => a > b ? a : b);
    final barColor = context.appColors.chartSeries.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (band != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 10,
                  decoration: BoxDecoration(
                    color: context.appColors.success.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // The band is shaded, and shading is colour — so it is also
                // named, in words, right here (`F-A11Y-003`).
                Expanded(
                  child: Text(
                    band.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Replaced, not annotated, for a screen reader (`F-A11Y-001`): the
        // bars themselves carry no semantics, and fl_chart's axis labels read
        // as loose numbers if left exposed underneath the summary.
        Semantics(
          label: barChartSummary(
            metric: band == null ? metricLabel : '$metricLabel, ${band.label}',
            bars: [
              for (final point in points)
                (label: point.label, value: point.value),
            ],
            format: valueLabel,
          ),
          image: true,
          child: ExcludeSemantics(
            child: SizedBox(
              height: 200,
              child: BarChart(
                duration: motionDuration(
                  context,
                  const Duration(milliseconds: 150),
                ),
                BarChartData(
                  minY: 0,
                  maxY: maxValue == 0 ? 1 : maxValue * 1.15,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: theme.dividerColor, strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(show: false),
                  rangeAnnotations: RangeAnnotations(
                    horizontalRangeAnnotations: [
                      if (band != null)
                        HorizontalRangeAnnotation(
                          y1: band.min,
                          y2: band.max,
                          color: context.appColors.success.withValues(
                            alpha: 0.12,
                          ),
                        ),
                    ],
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, meta) => Text(
                          valueLabel(value),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          if (index != 0 &&
                              index != points.length - 1 &&
                              points.length > 2) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            points[index].label,
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            '${points[group.x].label}\n${valueLabel(rod.toY)}',
                            theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.onInverseSurface,
                            ),
                          ),
                    ),
                    touchCallback: onBarTap == null
                        ? null
                        : (event, response) {
                            if (event is! FlTapUpEvent) return;
                            final spot = response?.spot;
                            if (spot == null) return;
                            final index = spot.touchedBarGroupIndex;
                            onBarTap!(index, points[index]);
                          },
                  ),
                  barGroups: [
                    for (var i = 0; i < points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: points[i].value,
                            color: barColor,
                            width: 14,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
