import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/shell/widgets/trend_chart.dart';

/// Batch 3.2 — `TrendChart` (`F-ANA-003`, `F-THM-004`).
void main() {
  Future<void> pump(
    WidgetTester tester,
    List<TrendChartPoint> points, {
    bool dark = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: Scaffold(
        body: TrendChart(
          metricLabel: 'Estimated one-rep max',
          points: points,
          valueLabel: (v) => '${v.toStringAsFixed(1)} kg',
          subtitle: 'Last 3 months · kg',
        ),
      ),
    ),
  );

  testWidgets('fewer than three points renders "not enough data yet"', (
    tester,
  ) async {
    await pump(tester, const [
      TrendChartPoint(x: 0, y: 100, label: 'Jan 1'),
      TrendChartPoint(x: 1, y: 105, label: 'Jan 8'),
    ]);

    expect(find.text('Not enough data yet'), findsOneWidget);
  });

  testWidgets('three or more points renders the chart, not the empty state', (
    tester,
  ) async {
    await pump(tester, const [
      TrendChartPoint(x: 0, y: 100, label: 'Jan 1'),
      TrendChartPoint(x: 1, y: 105, label: 'Jan 8'),
      TrendChartPoint(x: 2, y: 110, label: 'Jan 15'),
    ]);

    expect(find.text('Not enough data yet'), findsNothing);
    expect(find.text('Last 3 months · kg'), findsOneWidget);
  });

  testWidgets('an unreliable point does not crash rendering', (tester) async {
    await pump(tester, const [
      TrendChartPoint(x: 0, y: 100, label: 'Jan 1'),
      TrendChartPoint(x: 1, y: 105, label: 'Jan 8', reliable: false),
      TrendChartPoint(x: 2, y: 110, label: 'Jan 15'),
    ]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark theme without throwing (Phase 3 exit)', (
    tester,
  ) async {
    await pump(tester, const [
      TrendChartPoint(x: 0, y: 100, label: 'Jan 1'),
      TrendChartPoint(x: 1, y: 105, label: 'Jan 8'),
      TrendChartPoint(x: 2, y: 110, label: 'Jan 15'),
    ], dark: true);

    expect(tester.takeException(), isNull);
    expect(find.text('Not enough data yet'), findsNothing);
  });

  testWidgets(
    'a muted secondary scatter renders without crashing (F-BOD-003)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: TrendChart(
              metricLabel: 'Estimated one-rep max',
              points: const [
                TrendChartPoint(x: 0, y: 100, label: 'Jan 1'),
                TrendChartPoint(x: 1, y: 102, label: 'Jan 8'),
                TrendChartPoint(x: 2, y: 104, label: 'Jan 15'),
              ],
              secondaryPoints: const [
                TrendChartPoint(x: 0, y: 99, label: ''),
                TrendChartPoint(x: 1, y: 106, label: ''),
                TrendChartPoint(x: 2, y: 101, label: ''),
              ],
              valueLabel: (v) => v.toStringAsFixed(1),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Not enough data yet'), findsNothing);
    },
  );

  testWidgets(
    'renders with a tap-through callback and zoom disabled (F-ANA-016)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: TrendChart(
              metricLabel: 'Estimated one-rep max',
              points: const [
                TrendChartPoint(x: 0, y: 100, label: 'Jan 1', workoutId: 'w1'),
                TrendChartPoint(x: 1, y: 105, label: 'Jan 8', workoutId: 'w2'),
                TrendChartPoint(x: 2, y: 110, label: 'Jan 15', workoutId: 'w3'),
              ],
              valueLabel: (v) => '${v.toStringAsFixed(1)} kg',
              zoomEnabled: false,
              onPointTap: (_) {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );
}
