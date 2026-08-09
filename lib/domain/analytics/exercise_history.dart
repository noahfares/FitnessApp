/// Per-exercise history (`F-ANA-002`).
///
/// Reverse-chronological sessions containing one exercise, each summarised by
/// its best set — the one that set that session's e1RM
/// (docs/40-ANALYTICS-SPEC.md §1 rule 4: the maximum e1RM across the
/// session's counted sets, not the heaviest set and not the last one — and
/// its total volume load (§2). Pure Dart: the repository is responsible for
/// scoping rows to one exercise and ordering sessions newest-first; this only
/// summarises what it's given.
library;

import 'analytics_boundary.dart';
import 'e1rm.dart';

/// One set as the per-exercise history screen needs it.
class ExerciseHistorySet {
  const ExerciseHistorySet({
    required this.setType,
    required this.isCompleted,
    this.weightGrams,
    this.reps,
    this.rpe,
  });

  final String setType;
  final bool isCompleted;
  final int? weightGrams;
  final int? reps;

  /// Logged difficulty, always stored as RPE regardless of display mode
  /// (`F-LOG-014`). Null when nothing was recorded.
  final double? rpe;
}

/// One session containing the exercise, and every set logged for it there.
class ExerciseHistorySession {
  ExerciseHistorySession({
    required this.workoutId,
    required this.workoutName,
    required this.startedAt,
    required this.startedAtTzOffsetMinutes,
    required List<ExerciseHistorySet> sets,
  }) : sets = List.of(sets);

  final String workoutId;
  final String workoutName;

  /// UTC epoch milliseconds.
  final int startedAt;
  final int startedAtTzOffsetMinutes;

  /// Mutable so the repository can append rows for the same session as it
  /// streams them in (mirrors `MonthGroup` in `domain/history/workout_history.dart`).
  final List<ExerciseHistorySet> sets;

  /// The local calendar date the session started on — never derived from UTC
  /// alone (ADR-0008), same rule as `WorkoutHistoryEntry.localDate`.
  DateTime get localDate {
    final utc = DateTime.fromMillisecondsSinceEpoch(startedAt, isUtc: true);
    final local = utc.add(Duration(minutes: startedAtTzOffsetMinutes));
    return DateTime(local.year, local.month, local.day);
  }

  List<ExerciseHistorySet> get countedSets => sets
      .where(
        (s) => isCountedSet(setType: s.setType, isCompleted: s.isCompleted),
      )
      .toList();

  /// Total volume load (§2). Zero, not null, when nothing weight-bearing was
  /// counted — consistent with every other volume total in the app.
  int get volumeGrams {
    var total = 0;
    for (final s in countedSets) {
      final weight = s.weightGrams;
      final reps = s.reps;
      if (weight == null || reps == null) continue;
      total += weight * reps;
    }
    return total;
  }

  /// The counted set that set this session's e1RM, or null if none has a
  /// computable one.
  ExerciseHistorySet? get bestSet {
    ExerciseHistorySet? best;
    int? bestE1rm;
    for (final s in countedSets) {
      final weight = s.weightGrams;
      final reps = s.reps;
      if (weight == null || reps == null) continue;
      final e1rm = epley1Rm(weightGrams: weight, reps: reps);
      if (e1rm == null) continue;
      if (bestE1rm == null || e1rm > bestE1rm) {
        bestE1rm = e1rm;
        best = s;
      }
    }
    return best;
  }

  /// Session e1RM (§1 rule 4) — the e1RM of [bestSet], or null.
  int? get bestE1rmGrams {
    final best = bestSet;
    if (best == null) return null;
    return epley1Rm(weightGrams: best.weightGrams!, reps: best.reps!);
  }
}
