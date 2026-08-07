import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/logging/rpe.dart';

/// Batch 2.5 — RPE and RIR (`F-LOG-014`).
void main() {
  group('rpeToRir (F-LOG-014 §2)', () {
    test('RIR = 10 − RPE', () {
      expect(rpeToRir(6.0), 4.0);
      expect(rpeToRir(8.5), 1.5);
      expect(rpeToRir(10.0), 0.0);
    });

    test('is its own inverse', () {
      for (final rpe in rpeSteps) {
        expect(rpeToRir(rpeToRir(rpe)), rpe);
      }
    });
  });

  group('displayRpe', () {
    test('null stays null in either scale', () {
      expect(displayRpe(null, RpeDisplayMode.rpe), isNull);
      expect(displayRpe(null, RpeDisplayMode.rir), isNull);
    });

    test('RPE mode passes the stored value through unchanged', () {
      expect(displayRpe(8.5, RpeDisplayMode.rpe), 8.5);
    });

    test('RIR mode converts it', () {
      expect(displayRpe(8.0, RpeDisplayMode.rir), 2.0);
    });
  });

  group('formatRpeValue (docs/22-UNITS.md §display-rules)', () {
    test('strips a trailing .0', () {
      expect(formatRpeValue(9.0), '9');
      expect(formatRpeValue(10.0), '10');
    });

    test('keeps the half-step', () {
      expect(formatRpeValue(8.5), '8.5');
    });
  });

  group('RpeSettings', () {
    test('defaults to off, in RPE rather than RIR', () {
      const settings = RpeSettings();
      expect(settings.enabled, isFalse);
      expect(settings.displayMode, RpeDisplayMode.rpe);
    });

    test('copyWith changes only what is given', () {
      const settings = RpeSettings(
        enabled: true,
        displayMode: RpeDisplayMode.rir,
      );
      final updated = settings.copyWith(enabled: false);
      expect(updated.enabled, isFalse);
      expect(updated.displayMode, RpeDisplayMode.rir);
    });
  });
}
