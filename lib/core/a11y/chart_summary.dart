/// Text alternatives for charts (`F-A11Y-001`).
///
/// "Charts carry a text summary alternative, since a line chart is otherwise
/// entirely inaccessible" — the summary a screen reader announces in place of
/// the plot. Pure Dart, no Flutter: the formatting of a value is the caller's
/// (it owns the unit preferences), and what is left is the sentence structure,
/// which is worth testing without pumping a widget.
///
/// The shape of every summary is the same on purpose: what the chart is, how
/// much of it there is, where it starts and ends, and its range. Someone
/// listening to four of these on one screen should not have to learn four
/// formats.
library;

/// A trend line: direction matters, so first and last values lead.
String trendChartSummary({
  required String metric,
  required List<double> values,
  required String Function(double value) format,
  String? firstLabel,
  String? lastLabel,
}) {
  if (values.isEmpty) return '$metric chart. No data.';
  if (values.length == 1) {
    return '$metric chart. One point: ${format(values.single)}.';
  }

  final first = values.first;
  final last = values.last;
  final direction = switch (last.compareTo(first)) {
    > 0 => 'up',
    < 0 => 'down',
    _ => 'level',
  };
  final from = firstLabel == null ? '' : ' on $firstLabel';
  final to = lastLabel == null ? '' : ' on $lastLabel';

  return '$metric chart. ${values.length} points, trending $direction. '
      'From ${format(first)}$from to ${format(last)}$to. '
      'Lowest ${format(values.reduce((a, b) => a < b ? a : b))}, '
      'highest ${format(values.reduce((a, b) => a > b ? a : b))}.';
}

/// A categorical or weekly bar chart: the biggest bar is what the eye takes
/// from it, so that leads instead of a direction.
String barChartSummary({
  required String metric,
  required List<({String label, double value})> bars,
  required String Function(double value) format,
}) {
  if (bars.isEmpty) return '$metric chart. No data.';

  final highest = bars.reduce((a, b) => a.value >= b.value ? a : b);
  final total = bars.fold<double>(0, (sum, bar) => sum + bar.value);
  final average = total / bars.length;

  return '$metric chart. ${bars.length} bars. '
      'Highest ${highest.label}, ${format(highest.value)}. '
      'Average ${format(average)}. '
      'Latest ${bars.last.label}, ${format(bars.last.value)}.';
}

/// A training calendar: a count and a rate, not a shape.
String calendarSummary({
  required int trainedDays,
  required int totalDays,
  String? rangeLabel,
}) {
  if (totalDays == 0) return 'Training calendar. No days shown.';
  final range = rangeLabel == null ? '' : ' $rangeLabel';
  return 'Training calendar$range. Trained on $trainedDays of $totalDays days.';
}
