import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/a11y/chart_summary.dart';
import '../../../core/theme/app_colors.dart';

/// One axis of the radar: a label and a value already normalised to 0..1.
class RadarAxis {
  const RadarAxis({
    required this.label,
    required this.value,
    required this.displayValue,
  });

  final String label;

  /// 0..1, relative to whatever the caller decided the maximum is. Normalising
  /// outside the widget is deliberate: "relative to the hardest-trained group"
  /// and "relative to a target" are different questions, and the widget should
  /// not silently pick one.
  final double value;

  /// What the value actually is, in words — read out in the spoken summary and
  /// shown beside the label, so nothing here depends on judging an area by eye.
  final String displayValue;
}

/// Relative volume by muscle group (`F-ANA-008`).
///
/// Drawn with `CustomPaint` rather than pulled from a chart library:
/// `fl_chart`'s own radar wants its own data model and theming, and this is a
/// polygon, a few rings and some labels. `BodyMapHeatOverlay` made the same
/// call for the same reason.
///
/// A radar chart is genuinely hard to read precisely — that is a property of
/// the form, not of this implementation — so every axis carries its number as
/// text as well. The shape is the summary; the numbers are the data.
class RadarChart extends StatelessWidget {
  const RadarChart({
    required this.axes,
    required this.metricLabel,
    super.key,
    this.size = 220,
  });

  final List<RadarAxis> axes;
  final String metricLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (axes.length < 3) return const SizedBox.shrink();

    return Column(
      children: [
        Semantics(
          label: barChartSummary(
            metric: metricLabel,
            bars: [
              for (final axis in axes) (label: axis.label, value: axis.value),
            ],
            // The spoken form uses each axis's own words, not a normalised
            // fraction nobody can act on.
            format: (value) {
              final axis = axes.firstWhere(
                (a) => a.value == value,
                orElse: () => axes.first,
              );
              return axis.displayValue;
            },
          ),
          image: true,
          child: ExcludeSemantics(
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _RadarPainter(
                  axes: axes,
                  fill: context.appColors.chartSeries.first,
                  grid: theme.dividerColor,
                  labelStyle:
                      theme.textTheme.bodySmall ??
                      const TextStyle(fontSize: 12),
                  labelColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // The table under the shape: a radar is a shape-comparison tool, and
        // reading a value off one is guesswork without this.
        Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            for (final axis in axes)
              Text(
                '${axis.label} ${axis.displayValue}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.axes,
    required this.fill,
    required this.grid,
    required this.labelStyle,
    required this.labelColor,
  });

  final List<RadarAxis> axes;
  final Color fill;
  final Color grid;
  final TextStyle labelStyle;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    // Room for the labels, which sit outside the outermost ring.
    final radius = math.min(size.width, size.height) / 2 - 28;
    final gridPaint = Paint()
      ..color = grid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final ring in [0.25, 0.5, 0.75, 1.0]) {
      canvas.drawPath(_polygon(centre, radius * ring, (_) => 1), gridPaint);
    }
    for (var i = 0; i < axes.length; i++) {
      canvas.drawLine(centre, _point(centre, radius, i, 1), gridPaint);
    }

    canvas.drawPath(
      _polygon(centre, radius, (i) => axes[i].value.clamp(0.0, 1.0)),
      Paint()
        ..color = fill.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      _polygon(centre, radius, (i) => axes[i].value.clamp(0.0, 1.0)),
      Paint()
        ..color = fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = 0; i < axes.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: axes[i].label,
          style: labelStyle.copyWith(color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final anchor = _point(centre, radius + 16, i, 1);
      painter.paint(
        canvas,
        anchor - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  Path _polygon(Offset centre, double radius, double Function(int) scale) {
    final path = Path();
    for (var i = 0; i < axes.length; i++) {
      final point = _point(centre, radius, i, scale(i));
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  Offset _point(Offset centre, double radius, int index, double scale) {
    // Starting at twelve o'clock and going clockwise, which is how everyone
    // reads a dial.
    final angle = -math.pi / 2 + (2 * math.pi * index / axes.length);
    return centre + Offset(math.cos(angle), math.sin(angle)) * (radius * scale);
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.axes != axes || oldDelegate.fill != fill;
}
