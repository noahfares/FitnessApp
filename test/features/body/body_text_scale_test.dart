import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/repositories/body_measurement_repository.dart';
import 'package:fitness_app/features/body/presentation/body_weight_screen.dart';
import 'package:fitness_app/features/body/presentation/progress_photos_screen.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — the body screen stacks a trend chart, weekly rate of
/// change, and one section per tracked measurement type; worth checking with
/// real entries logged, not just its own empty state.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'the body screen, with logged entries, renders at 200% with no overflow',
    (tester) async {
      final db = testDatabase();
      final repo = BodyMeasurementRepository(
        db,
        clock: () => DateTime(2026, 8, 6),
      );
      await repo.logBodyweight(grams: 80000);
      await repo.logBodyweight(grams: 79500);

      await pumpScreen(
        tester,
        const BodyWeightScreen(),
        db: db,
        now: DateTime(2026, 8, 6),
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('progress photos, empty, renders at 200% with no overflow', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ProgressPhotosScreen(),
      db: testDatabase(),
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });
}
