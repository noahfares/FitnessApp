/// Least-squares linear regression, shared by the e1RM trend's optional
/// overlay (`F-ANA-003` §2) and, later, stall detection
/// (`docs/40-ANALYTICS-SPEC.md` §7, `F-ANA-009`, Phase 4) — both are the same
/// slope-of-a-series-against-its-index computation.
library;

/// `y = slope·x + intercept`.
class RegressionLine {
  const RegressionLine({required this.slope, required this.intercept});

  final double slope;
  final double intercept;

  double at(double x) => slope * x + intercept;
}

/// `null` for fewer than two points, or when every `x` is identical (a
/// vertical "line" has no slope in this form) — never a divide-by-zero.
RegressionLine? linearRegression(List<double> xs, List<double> ys) {
  if (xs.length < 2 || xs.length != ys.length) return null;

  final n = xs.length;
  final meanX = xs.reduce((a, b) => a + b) / n;
  final meanY = ys.reduce((a, b) => a + b) / n;

  var numerator = 0.0;
  var denominator = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = xs[i] - meanX;
    numerator += dx * (ys[i] - meanY);
    denominator += dx * dx;
  }
  if (denominator == 0) return null;

  final slope = numerator / denominator;
  return RegressionLine(slope: slope, intercept: meanY - slope * meanX);
}
