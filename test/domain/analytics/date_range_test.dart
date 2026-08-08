import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/date_range.dart';

/// Batch 3.2 — the shared range selector's resolution rules (`F-ANA-015`).
void main() {
  final now = DateTime(2026, 8, 7);

  group('resolveRange', () {
    test('four weeks is a 28-day window ending now', () {
      final range = resolveRange(RangePreset.fourWeeks, now);
      expect(range.start, DateTime(2026, 7, 10));
      expect(range.end, now);
    });

    test('all time starts at the epoch', () {
      final range = resolveRange(RangePreset.allTime, now);
      expect(range.start, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('custom uses the given range', () {
      final custom = DateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 2, 1),
      );
      final range = resolveRange(RangePreset.custom, now, custom: custom);
      expect(range, same(custom));
    });

    test('custom with no range given falls back to all time', () {
      final range = resolveRange(RangePreset.custom, now);
      expect(range.start, DateTime.fromMillisecondsSinceEpoch(0));
      expect(range.end, now);
    });
  });

  group('DateRange.contains', () {
    test('is inclusive at both ends', () {
      final range = DateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      expect(range.contains(DateTime(2026, 1, 1)), isTrue);
      expect(range.contains(DateTime(2026, 1, 31)), isTrue);
      expect(range.contains(DateTime(2025, 12, 31)), isFalse);
      expect(range.contains(DateTime(2026, 2, 1)), isFalse);
    });
  });
}
