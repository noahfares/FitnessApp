import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/analytics/linear_regression.dart';
import 'empty_state.dart';

/// One plotted point. `x` is the point's index in the series, not a date —
/// sessions are irregularly spaced, and spacing by index keeps the line
/// readable instead of bunching a busy month against a sparse one
/// (`docs/24-DESIGN-SYSTEM.md` §Charts doesn't mandate true time-scaling, and
/// every consumer already has a date label to show per point regardless).
class TrendChartPoint {
  const TrendChartPoint({
    required this.x,
    required this.y,
    required this.label,
    this.reliable = true,
    this.workoutId,
  });

  final double x;
  final double y;

  /// Shown on the x axis and in the tooltip — e.g. a formatted date.
  final String label;

  /// Rendered as a hollow, muted dot rather than the reliable, filled one
  /// (`F-ANA-003` §3) — never hidden outright here; exclusion is the caller's
  /// decision, made before points reach this widget.
  final bool reliable;

  /// The workout this point's value came from, if any — what [onPointTap]
  /// hands back for tap-through (`F-ANA-016`). Null for a caller with no
  /// single source session to point at.
  final String? workoutId;
}

/// Line chart with an optional linear-regression overlay
/// (`F-THM-004`, `F-ANA-003` §2, component inventory `TrendChart`).
///
/// Colours come from `context.appColors.chartSeries[0]`
/// (`docs/24-DESIGN-SYSTEM.md` §Charts) — this widget only ever draws one
/// series, so the "differentiate by marker shape or dash pattern" rule for
/// multiple series doesn't apply yet; it will when a chart here plots more
/// than one line.
class TrendChart extends StatelessWidget {
  const TrendChart({
    required this.points,
    required this.valueLabel,
    super.key,
    this.subtitle,
    this.showRegression = false,
    this.onPointTap,
    this.zoomEnabled = true,
  });

  final List<TrendChartPoint> points;

  /// Formats a y value for the axis and tooltip, e.g. `'120.3 kg'`.
  final String Function(double value) valueLabel;

  /// States the date range and units (`docs/24-DESIGN-SYSTEM.md` §Charts).
  final String? subtitle;

  final bool showRegression;

  /// Tap-through to the point's source session (`F-ANA-016`). Null skips the
  /// tap gesture entirely rather than tapping to nowhere.
  final void Function(TrendChartPoint point)? onPointTap;

  /// Pinch-to-zoom on the time axis (`docs/24-DESIGN-SYSTEM.md` §Charts,
  /// `F-ANA-016`). Off for a chart embedded in a scrolling container that
  /// would otherwise fight the gesture for the same pointer.
  final bool zoomEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.length < 3) {
      return const EmptyState(
        icon: Icons.show_chart,
        title: 'Not enough data yet',
        message: 'At least three sessions are needed for a trend.',
      );
    }

    final ys = points.map((p) => p.y).toList();
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    // Never zero-based (`docs/24-DESIGN-SYSTEM.md` §Charts) — a small real
    // change would otherwise flatten to a barely-visible line. Padding keeps
    // the extreme points off the very edge of the plot.
    final padding = (maxY - minY) * 0.15 + 1;
    final chartMinY = minY - padding;
    final chartMaxY = maxY + padding;

    final seriesColor = context.appColors.chartSeries.first;
    final regression = showRegression
        ? linearRegression(
            points.map((p) => p.x).toList(),
            points.map((p) => p.y).toList(),
          )
        : null;

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
        SizedBox(
          height: 220,
          child: LineChart(
            transformationConfig: FlTransformationConfig(
              scaleAxis: zoomEnabled
                  ? FlScaleAxis.horizontal
                  : FlScaleAxis.none,
            ),
            LineChartData(
              minY: chartMinY,
              maxY: chartMaxY,
              minX: points.first.x,
              maxX: points.last.x,
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: theme.dividerColor, strokeWidth: 0.5),
              ),
              borderData: FlBorderData(show: false),
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
                      // Only the first and last label, to avoid overlapping
                      // text on a series with more than a handful of points.
                      if (index != 0 && index != points.length - 1) {
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
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      if (spot.barIndex == 0)
                        LineTooltipItem(
                          '${points[spot.spotIndex].label}\n'
                          '${valueLabel(spot.y)}',
                          theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onInverseSurface,
                          ),
                        )
                      else
                        null,
                  ],
                ),
                touchCallback: onPointTap == null
                    ? null
                    : (event, response) {
                        if (event is! FlTapUpEvent) return;
                        final spots = response?.lineBarSpots;
                        if (spots == null || spots.isEmpty) return;
                        final spot = spots.first;
                        if (spot.barIndex != 0) return;
                        onPointTap!(points[spot.spotIndex]);
                      },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (final p in points) FlSpot(p.x, p.y)],
                  isCurved: false,
                  color: seriesColor,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, bar, index) {
                      final reliable = points[index].reliable;
                      return FlDotCirclePainter(
                        radius: reliable ? 4 : 3,
                        color: reliable
                            ? seriesColor
                            : theme.colorScheme.onSurfaceVariant,
                        strokeWidth: reliable ? 0 : 1.5,
                        strokeColor: theme.colorScheme.onSurfaceVariant,
                      );
                    },
                  ),
                ),
                if (regression != null)
                  LineChartBarData(
                    spots: [
                      FlSpot(points.first.x, regression.at(points.first.x)),
                      FlSpot(points.last.x, regression.at(points.last.x)),
                    ],
                    isCurved: false,
                    color: theme.colorScheme.onSurfaceVariant,
                    barWidth: 1.5,
                    dashArray: const [6, 4],
                    dotData: const FlDotData(show: false),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
