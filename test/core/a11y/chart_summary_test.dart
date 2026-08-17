import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/a11y/chart_summary.dart';

/// `F-A11Y-001` — the spoken alternative to a chart. Pure functions, so tested
/// without pumping a widget; the widgets that use them are covered in
/// test/features/a11y/accessibility_test.dart.
void main() {
  String kg(double v) => '${v.toStringAsFixed(0)} kg';

  group('trendChartSummary', () {
    test('leads with what, how many, and which way', () {
      final summary = trendChartSummary(
        metric: 'Estimated one-rep max',
        values: const [100, 102, 108],
        format: kg,
        firstLabel: '1 Mar',
        lastLabel: '15 Mar',
      );

      expect(summary, startsWith('Estimated one-rep max chart. 3 points'));
      expect(summary, contains('trending up'));
      expect(summary, contains('From 100 kg on 1 Mar to 108 kg on 15 Mar'));
      expect(summary, contains('Lowest 100 kg, highest 108 kg'));
    });

    test('names the direction it actually went', () {
      String direction(List<double> values) => trendChartSummary(
        metric: 'x',
        values: values,
        format: kg,
      ).split('trending ').last.split('.').first;

      expect(direction(const [100, 90]), 'down');
      expect(direction(const [100, 100]), 'level');
      expect(direction(const [90, 100]), 'up');
    });

    test('a lone point is not a trend, and no points is not a chart', () {
      expect(
        trendChartSummary(metric: 'x', values: const [100], format: kg),
        'x chart. One point: 100 kg.',
      );
      expect(
        trendChartSummary(metric: 'x', values: const [], format: kg),
        'x chart. No data.',
      );
    });

    test('the extremes are the series\' own, not its ends', () {
      // A dip in the middle is exactly what a listener cannot see.
      final summary = trendChartSummary(
        metric: 'x',
        values: const [100, 60, 105],
        format: kg,
      );
      expect(summary, contains('Lowest 60 kg'));
      expect(summary, contains('highest 105 kg'));
    });
  });

  group('barChartSummary', () {
    test('leads with the biggest bar, then the average and the latest', () {
      final summary = barChartSummary(
        metric: 'Weekly volume',
        bars: const [
          (label: '1 Mar', value: 1000),
          (label: '8 Mar', value: 3000),
          (label: '15 Mar', value: 2000),
        ],
        format: kg,
      );

      expect(summary, startsWith('Weekly volume chart. 3 bars.'));
      expect(summary, contains('Highest 8 Mar, 3000 kg'));
      expect(summary, contains('Average 2000 kg'));
      expect(summary, contains('Latest 15 Mar, 2000 kg'));
    });

    test('ties go to the earlier bar rather than reporting neither', () {
      final summary = barChartSummary(
        metric: 'x',
        bars: const [(label: 'a', value: 5), (label: 'b', value: 5)],
        format: kg,
      );
      expect(summary, contains('Highest a'));
    });

    test('no bars says so', () {
      expect(
        barChartSummary(metric: 'x', bars: const [], format: kg),
        'x chart. No data.',
      );
    });
  });

  group('calendarSummary', () {
    test('is a count and a window, not a shape', () {
      expect(
        calendarSummary(
          trainedDays: 9,
          totalDays: 28,
          rangeLabel: 'over the last 4 weeks',
        ),
        'Training calendar over the last 4 weeks. Trained on 9 of 28 days.',
      );
    });

    test('an empty window is stated, not divided by zero', () {
      expect(
        calendarSummary(trainedDays: 0, totalDays: 0),
        'Training calendar. No days shown.',
      );
    });
  });
}
