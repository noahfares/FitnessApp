import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/schedule_adherence.dart';

/// `F-ANA-006` — "adherence against schedule once `F-ROU-012` exists". It does
/// now, so this is the metric that closes that clause.
void main() {
  // A fortnight, Monday 2 March to Sunday 15 March 2026.
  final from = DateTime(2026, 3, 2);
  final to = DateTime(2026, 3, 15);

  test('counts scheduled days trained, over the window', () {
    // Scheduled Monday, Wednesday, Friday: six days in a fortnight.
    final result = scheduleAdherence(
      scheduledWeekdays: const {1, 3, 5},
      trainingDays: {
        DateTime(2026, 3, 2), // Mon — scheduled, trained
        DateTime(2026, 3, 4), // Wed — scheduled, trained
        DateTime(2026, 3, 9), // Mon — scheduled, trained
      },
      from: from,
      to: to,
    );

    expect(result.scheduled, 6);
    expect(result.trained, 3);
    expect(result.ratio, 0.5);
  });

  test('an extra session on an unscheduled day never counts against you', () {
    // "No shame" (§5 rule 4) as a maths decision, not only a copy one: a
    // spontaneous Sunday session is training, not a deviation.
    final result = scheduleAdherence(
      scheduledWeekdays: const {1},
      trainingDays: {
        DateTime(2026, 3, 2), // Mon — scheduled
        DateTime(2026, 3, 8), // Sun — not scheduled
      },
      from: from,
      to: to,
    );

    expect(result.scheduled, 2);
    expect(result.trained, 1);
    expect(result.unscheduledSessions, 1);
    expect(
      result.ratio,
      0.5,
      reason: 'the extra session neither helps nor hurts',
    );
  });

  test('no schedule reports no ratio rather than 0%', () {
    final result = scheduleAdherence(
      scheduledWeekdays: const {},
      trainingDays: {DateTime(2026, 3, 3)},
      from: from,
      to: to,
    );

    // 0% would be a lie about someone who never set a schedule.
    expect(result.ratio, isNull);
    expect(result.unscheduledSessions, 1);
  });

  test('training days outside the window are ignored entirely', () {
    final result = scheduleAdherence(
      scheduledWeekdays: const {1},
      trainingDays: {DateTime(2026, 2, 23), DateTime(2026, 3, 2)},
      from: from,
      to: to,
    );

    expect(result.trained, 1);
    expect(result.unscheduledSessions, 0);
  });
}
