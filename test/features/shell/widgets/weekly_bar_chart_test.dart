import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/shell/widgets/weekly_bar_chart.dart';

/// Batch 3.3 — `WeeklyBarChart` (`F-ANA-004`, `F-ANA-005`, `F-THM-004`).
void main() {
  Future<void> pump(
    WidgetTester tester,
    List<WeeklyBarPoint> points, {
    bool dark = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: Scaffold(
        body: WeeklyBarChart(
          metricLabel: 'Weekly volume',
          points: points,
          valueLabel: (v) => v.toStringAsFixed(0),
          subtitle: 'Last 3 months · kg',
        ),
      ),
    ),
  );

  testWidgets('no points renders "not enough data yet"', (tester) async {
    await pump(tester, const []);
    expect(find.text('Not enough data yet'), findsOneWidget);
  });

  testWidgets('renders the chart when points exist', (tester) async {
    await pump(tester, const [
      WeeklyBarPoint(value: 1000, label: 'Aug 3'),
      WeeklyBarPoint(value: 1200, label: 'Aug 10'),
    ]);

    expect(find.text('Not enough data yet'), findsNothing);
    expect(find.text('Last 3 months · kg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a single zero-value point does not crash', (tester) async {
    await pump(tester, const [WeeklyBarPoint(value: 0, label: 'Aug 3')]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark theme without throwing (Phase 3 exit)', (
    tester,
  ) async {
    await pump(tester, const [
      WeeklyBarPoint(value: 1000, label: 'Aug 3'),
      WeeklyBarPoint(value: 1200, label: 'Aug 10'),
    ], dark: true);

    expect(tester.takeException(), isNull);
    expect(find.text('Not enough data yet'), findsNothing);
  });

  testWidgets('renders with a per-bar tap-through callback (F-ANA-016)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: WeeklyBarChart(
            metricLabel: 'Weekly volume',
            points: const [
              WeeklyBarPoint(value: 1000, label: 'Aug 3'),
              WeeklyBarPoint(value: 1200, label: 'Aug 10'),
            ],
            valueLabel: (v) => v.toStringAsFixed(0),
            onBarTap: (_, _) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
