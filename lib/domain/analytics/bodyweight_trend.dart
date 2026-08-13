/// Bodyweight trend smoothing (`F-BOD-003`), `docs/40-ANALYTICS-SPEC.md` §6.
///
/// Pure Dart. Raw daily bodyweight swings by kilograms from water, food and
/// time of day — the smoothed line is the only part that carries signal.
library;

import 'linear_regression.dart';

/// One observation's raw value alongside its running EMA.
class BodyweightTrendPoint {
  const BodyweightTrendPoint({
    required this.measuredAtEpochMs,
    required this.rawGrams,
    required this.emaGrams,
  });

  final int measuredAtEpochMs;
  final int rawGrams;
  final double emaGrams;
}

/// `α = 2/(N+1)`, `N = 7` by default (§6 rule 1).
///
/// The EMA advances per *observation*, not per calendar day (§6 rule 3) — the
/// same sequential formula applies whether entries are logged daily or with
/// long gaps between them, so a gap never decays the average toward zero.
/// [observations] must already be sorted oldest first.
List<BodyweightTrendPoint> bodyweightTrendEma(
  List<({int measuredAtEpochMs, int grams})> observations, {
  int windowDays = 7,
}) {
  if (observations.isEmpty) return const [];

  final alpha = 2 / (windowDays + 1);
  final result = <BodyweightTrendPoint>[];
  var ema = observations.first.grams.toDouble();
  for (var i = 0; i < observations.length; i++) {
    final o = observations[i];
    if (i > 0) ema = alpha * o.grams + (1 - alpha) * ema;
    result.add(
      BodyweightTrendPoint(
        measuredAtEpochMs: o.measuredAtEpochMs,
        rawGrams: o.grams,
        emaGrams: ema,
      ),
    );
  }
  return result;
}

/// Grams per week, computed on the smoothed series, never the raw one (§6
/// rule 4) — the least-squares slope of the EMA against elapsed days, scaled
/// to a week. Null for fewer than two points.
double? weeklyRateOfChangeGrams(List<BodyweightTrendPoint> trend) {
  if (trend.length < 2) return null;

  final firstMs = trend.first.measuredAtEpochMs;
  final xs = [
    for (final p in trend) (p.measuredAtEpochMs - firstMs) / 86400000,
  ];
  final ys = [for (final p in trend) p.emaGrams];
  final line = linearRegression(xs, ys);
  return line == null ? null : line.slope * 7;
}
