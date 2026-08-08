import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/core/units/week_start.dart';
import 'package:fitness_app/features/shell/widgets/calendar_heatmap.dart';

/// Batch 3.4 — `CalendarHeatmap` (`F-ANA-006`).
void main() {
  testWidgets('renders one cell per day across the shown weeks, no crash', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: CalendarHeatmap(
            trainingDays: {DateTime(2026, 8, 3), DateTime(2026, 8, 5)},
            weekStart: WeekStart.monday,
            now: DateTime(2026, 8, 7),
            weeksToShow: 4,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    // 4 weeks x 7 days = 28 cells.
    expect(find.byType(Container), findsNWidgets(28));
  });

  testWidgets('an empty training day set still renders without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: CalendarHeatmap(
            trainingDays: const {},
            weekStart: WeekStart.sunday,
            now: DateTime(2026, 8, 7),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
