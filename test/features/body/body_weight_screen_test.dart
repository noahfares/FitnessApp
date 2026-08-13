import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/body_measurement_repository.dart';
import 'package:fitness_app/features/body/presentation/body_weight_screen.dart';
import 'package:fitness_app/features/body/presentation/log_bodyweight_sheet.dart';
import 'package:fitness_app/features/body/presentation/log_measurement_sheet.dart';
import 'package:fitness_app/features/body/presentation/tracked_measurements_sheet.dart';

import '../../support/harness.dart';

/// Batch 1.8 — `F-BOD-001`.
void main() {
  late AppDatabase db;
  late BodyMeasurementRepository repo;

  setUp(() {
    db = testDatabase();
    repo = BodyMeasurementRepository(db, clock: () => DateTime(2026, 8, 6));
  });

  testWidgets('empty state offers to log the first entry', (tester) async {
    await pumpScreen(tester, const BodyWeightScreen(), db: db);

    expect(find.text('No bodyweight logged yet'), findsOneWidget);
    expect(find.text('Log bodyweight'), findsWidgets);
  });

  testWidgets('logging a weight shows up in the history list', (tester) async {
    await pumpScreen(tester, const BodyWeightScreen(), db: db);

    await tester.tap(find.text('Log bodyweight').first);
    await tester.pumpAndSettle();
    expect(find.byType(LogBodyweightSheet), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '82.5');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.byType(LogBodyweightSheet), findsNothing);
    expect(find.text('82.5 kg'), findsOneWidget);
  });

  testWidgets('a logged entry can be deleted with confirmation', (
    tester,
  ) async {
    await repo.logBodyweight(grams: 80000);
    await pumpScreen(tester, const BodyWeightScreen(), db: db);

    expect(find.text('80 kg'), findsOneWidget);

    await tester.drag(find.text('80 kg'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No bodyweight logged yet'), findsOneWidget);
  });

  testWidgets(
    'tracking a measurement type shows its section, untracking hides it',
    (tester) async {
      await pumpScreen(tester, const BodyWeightScreen(), db: db);

      // Nothing tracked by default (F-BOD-002's own spec).
      expect(find.text('Waist'), findsNothing);

      await tester.tap(find.byTooltip('Measurements to track'));
      await tester.pumpAndSettle();
      expect(find.byType(TrackedMeasurementsSheet), findsOneWidget);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Waist'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(1, 1)); // dismiss the sheet
      await tester.pumpAndSettle();

      expect(find.text('Waist'), findsOneWidget);
      expect(find.text('Not logged yet.'), findsOneWidget);

      // Untracking hides the section again.
      await tester.tap(find.byTooltip('Measurements to track'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SwitchListTile, 'Waist'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(1, 1));
      await tester.pumpAndSettle();

      expect(find.text('Waist'), findsNothing);
    },
  );

  testWidgets('logging a tracked circumference shows up in its section', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const BodyWeightScreen(),
      db: db,
      prefs: const {
        'body.trackedMeasurementTypes': ['waist'],
      },
    );

    await tester.tap(find.byTooltip('Log Waist'));
    await tester.pumpAndSettle();
    expect(find.byType(LogMeasurementSheet), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '85');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.byType(LogMeasurementSheet), findsNothing);
    expect(find.text('85 cm'), findsOneWidget);
  });

  testWidgets('logging a tracked body-fat percentage formats as a percent', (
    tester,
  ) async {
    await repo.logMeasurement(
      type: MeasurementType.bodyFatPercent,
      valueCanonical: 1850,
    );
    await pumpScreen(
      tester,
      const BodyWeightScreen(),
      db: db,
      prefs: const {
        'body.trackedMeasurementTypes': ['bodyFatPercent'],
      },
    );

    expect(find.text('18.5%'), findsOneWidget);
  });
}
