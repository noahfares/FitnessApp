import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/stall_detection.dart';

/// `docs/40-ANALYTICS-SPEC.md` §7, `docs/fixtures/analytics.json#slope`.
void main() {
  group('detectStall', () {
    test('fewer than 5 sessions gives no verdict — silence, not a guess', () {
      final sessions = [
        for (var i = 0; i < 4; i++)
          SessionE1rm(date: DateTime(2026, 1, 1 + i * 7), e1rmGrams: 100000),
      ];
      expect(detectStall(sessions), isNull);
    });

    test('matches the spec fixture — stalled at 0.01 kg/session', () {
      const e1rmKg = [126.7, 127.5, 127.0, 127.2, 126.9];
      final sessions = [
        for (var i = 0; i < e1rmKg.length; i++)
          SessionE1rm(
            // Weekly sessions — five weeks comfortably clears the 3-week span.
            date: DateTime(2026, 1, 1 + i * 7),
            e1rmGrams: (e1rmKg[i] * 1000).round(),
          ),
      ];

      final verdict = detectStall(sessions);

      expect(verdict, isNotNull);
      expect(verdict!.stalled, isTrue);
      expect(verdict.slopeGramsPerSession, closeTo(10, 0.5)); // 0.01 kg
      expect(verdict.windowSize, 5);
    });

    test('a clear upward slope is not stalled', () {
      final sessions = [
        for (var i = 0; i < 5; i++)
          SessionE1rm(
            date: DateTime(2026, 1, 1 + i * 7),
            e1rmGrams: 100000 + i * 5000, // +5 kg/session
          ),
      ];

      final verdict = detectStall(sessions);

      expect(verdict!.stalled, isFalse);
    });

    test(
      'a flat slope within one week is not flagged — time condition (§7 rule 3)',
      () {
        final sessions = [
          for (var i = 0; i < 5; i++)
            SessionE1rm(
              // All within the same week: two sessions of the same lift
              // done close together must not be flagged.
              date: DateTime(2026, 1, 1 + i),
              e1rmGrams: 100000,
            ),
        ];

        final verdict = detectStall(sessions);

        expect(verdict!.stalled, isFalse);
      },
    );

    test('only the trailing window is considered', () {
      final sessions = [
        // An old, wildly different run that should be dropped once there
        // are more than windowSize sessions.
        for (var i = 0; i < 3; i++)
          SessionE1rm(
            date: DateTime(2025, 1, 1 + i * 7),
            e1rmGrams: 50000 + i * 20000,
          ),
        for (var i = 0; i < 5; i++)
          SessionE1rm(date: DateTime(2026, 1, 1 + i * 7), e1rmGrams: 100000),
      ];

      final verdict = detectStall(sessions, windowSize: 5);

      expect(verdict!.windowSize, 5);
      expect(verdict.stalled, isTrue);
    });
  });
}
