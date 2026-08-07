import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/repositories/body_measurement_repository.dart';
import 'package:fitness_app/features/body/presentation/body_weight_screen.dart';
import 'package:fitness_app/features/body/presentation/log_bodyweight_sheet.dart';

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
}
