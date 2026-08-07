import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/history/workout_history.dart';

WorkoutHistoryEntry _entry({
  required String id,
  required int startedAt,
  int tzOffsetMinutes = 0,
}) => WorkoutHistoryEntry(
  id: id,
  name: 'Workout',
  startedAt: startedAt,
  startedAtTzOffsetMinutes: tzOffsetMinutes,
  endedAt: startedAt + 1000,
  exerciseCount: 1,
  completedSetCount: 1,
  totalVolumeGrams: 0,
  hasNotes: false,
);

/// Batch 1.6 — `F-LOG-011`.
void main() {
  group('WorkoutHistoryEntry.localDate (ADR-0008)', () {
    test(
      'a late-night session in a positive offset lands on the next UTC day',
      () {
        // 23:30 local, UTC+10 — 13:30 UTC the same day, but the session was
        // trained on the 7th locally.
        final startedAtUtc = DateTime.utc(2026, 8, 6, 13, 30);
        final entry = _entry(
          id: 'a',
          startedAt: startedAtUtc.millisecondsSinceEpoch,
          tzOffsetMinutes: 600,
        );
        expect(entry.localDate, DateTime(2026, 8, 6));
      },
    );

    test('a negative offset can pull the local date back a day', () {
      // 00:30 UTC, UTC-5 -> 19:30 the previous local day.
      final startedAtUtc = DateTime.utc(2026, 8, 6, 0, 30);
      final entry = _entry(
        id: 'a',
        startedAt: startedAtUtc.millisecondsSinceEpoch,
        tzOffsetMinutes: -300,
      );
      expect(entry.localDate, DateTime(2026, 8, 5));
    });
  });

  group('groupByMonth (F-LOG-011 §2)', () {
    test('splits reverse-chronological entries into calendar months', () {
      final entries = [
        _entry(
          id: 'aug-2',
          startedAt: DateTime.utc(2026, 8, 2).millisecondsSinceEpoch,
        ),
        _entry(
          id: 'aug-1',
          startedAt: DateTime.utc(2026, 8, 1).millisecondsSinceEpoch,
        ),
        _entry(
          id: 'jul-15',
          startedAt: DateTime.utc(2026, 7, 15).millisecondsSinceEpoch,
        ),
      ];

      final groups = groupByMonth(entries);

      expect(groups, hasLength(2));
      expect(groups[0].year, 2026);
      expect(groups[0].month, 8);
      expect(groups[0].entries.map((e) => e.id), ['aug-2', 'aug-1']);
      expect(groups[1].month, 7);
      expect(groups[1].entries.map((e) => e.id), ['jul-15']);
    });

    test('empty input yields no groups', () {
      expect(groupByMonth(const []), isEmpty);
    });
  });
}
