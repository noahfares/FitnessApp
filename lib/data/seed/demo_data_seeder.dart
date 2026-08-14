import 'package:drift/drift.dart' show Value;

import '../db/app_database.dart';
import '../repositories/body_measurement_repository.dart';
import '../repositories/set_repository.dart';
import '../repositories/workout_repository.dart';

/// Debug-only sample history (Settings › Data, `kDebugMode` gated) — enough
/// realistic weeks that the analytics screens (weekly insights, stall
/// detection, ACWR, muscle balance, the body map) have something to show
/// without hand-logging workouts one at a time. Never reachable in a release
/// build; see `DataScreen`'s own gate.
///
/// Uses the real repositories — `WorkoutRepository.start`/`finish`,
/// `SetRepository.addSet`/`complete` — exactly as a live session would, so
/// every derived table (personal records, `workouts.bodyweight_grams`,
/// rest-taken seconds) comes out the same way real use would produce it,
/// rather than being poked in directly.
class DemoDataSeeder {
  const DemoDataSeeder(this._db);

  final AppDatabase _db;

  static const List<_ExercisePlan> _pushDay = [
    _ExercisePlan(
      externalId: 'barbell-bench-press',
      startGrams: 60000,
      weeklyIncrementGrams: 1250,
      sets: 3,
      reps: 5,
    ),
    _ExercisePlan(
      externalId: 'overhead-press',
      startGrams: 40000,
      weeklyIncrementGrams: 1000,
      sets: 3,
      reps: 5,
    ),
    _ExercisePlan(
      externalId: 'triceps-pushdown',
      startGrams: 25000,
      weeklyIncrementGrams: 500,
      sets: 3,
      reps: 12,
    ),
  ];

  static const List<_ExercisePlan> _pullDay = [
    _ExercisePlan(
      externalId: 'conventional-deadlift',
      startGrams: 100000,
      weeklyIncrementGrams: 2500,
      sets: 1,
      reps: 5,
    ),
    _ExercisePlan(
      externalId: 'barbell-row',
      startGrams: 55000,
      weeklyIncrementGrams: 1250,
      sets: 3,
      reps: 8,
    ),
    _ExercisePlan(
      externalId: 'barbell-curl',
      startGrams: 20000,
      weeklyIncrementGrams: 500,
      sets: 3,
      reps: 10,
    ),
  ];

  static const List<_ExercisePlan> _legDay = [
    _ExercisePlan(
      externalId: 'back-squat',
      startGrams: 80000,
      weeklyIncrementGrams: 2500,
      sets: 3,
      reps: 5,
    ),
  ];

  static const int _weeks = 8;

  /// Seeds 8 weeks of a Push/Pull/Legs split (3 sessions a week, ending
  /// [now]), plus a weekly bodyweight entry. Safe to run more than once —
  /// each call adds another 8 weeks' worth rather than checking for or
  /// replacing anything already there, matching every other write in this
  /// app (nothing here is a singleton).
  Future<void> seed({DateTime? now}) async {
    final resolvedNow = now ?? DateTime.now();
    final wantedExternalIds = [
      for (final plan in [..._pushDay, ..._pullDay, ..._legDay])
        plan.externalId,
    ];
    final exerciseIds = await _resolveExternalIds(wantedExternalIds);
    final missing = wantedExternalIds.toSet().difference(
      exerciseIds.keys.toSet(),
    );
    if (missing.isNotEmpty) {
      // The catalogue seed (`F-CAT-001`) hasn't run yet, or shipped a
      // different set of `external_id`s than this expects — fail loudly
      // rather than seeding a partial, confusing history.
      throw StateError(
        'Demo data needs these exercises in the catalogue first: '
        '${missing.join(', ')}',
      );
    }

    var clock = resolvedNow.subtract(const Duration(days: _weeks * 7));
    final workouts = WorkoutRepository(_db, clock: () => clock);
    final sets = SetRepository(_db, clock: () => clock);
    final body = BodyMeasurementRepository(_db, clock: () => clock);

    for (var week = 0; week < _weeks; week++) {
      final weekStart = resolvedNow.subtract(
        Duration(days: (_weeks - week) * 7),
      );

      await body.logBodyweight(
        // A slow, realistic drift rather than a flat line.
        grams: 78000 + (week * 150) - (week.isEven ? 300 : 0),
        measuredAt: weekStart,
      );

      for (final (dayOffset, plan) in [
        (1, _pushDay),
        (3, _pullDay),
        (5, _legDay),
      ]) {
        clock = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + dayOffset,
          18,
        );
        final workout = await workouts.start();
        await workouts.addExercises(workout.id, [
          for (final p in plan) exerciseIds[p.externalId]!,
        ]);
        final sessionExercises = await workouts
            .watchExercises(workout.id)
            .first;

        for (final p in plan) {
          final we = sessionExercises
              .firstWhere((e) => e.exerciseId == exerciseIds[p.externalId])
              .workoutExerciseId;
          final weight = p.startGrams + p.weeklyIncrementGrams * week;

          for (var setIndex = 0; setIndex < p.sets; setIndex++) {
            final setId = await sets.addSet(we);
            // A missed rep here and there — realistic, and enough variance
            // that not every session reads as a flawless success.
            final missedRep =
                week > 2 && week % 5 == 0 && setIndex == p.sets - 1;
            await sets.complete(
              setId,
              weightGrams: Value(weight),
              reps: Value(missedRep ? p.reps - 1 : p.reps),
            );
            // ~90 s between sets — real rest, so `F-TIM-007`'s recorded
            // interval and `F-ANA-012`'s compliance figure have something
            // to read.
            clock = clock.add(const Duration(seconds: 90));
          }
        }

        await workouts.finish(workout.id);
      }
    }
  }

  Future<Map<String, String>> _resolveExternalIds(
    List<String> externalIds,
  ) async {
    final rows = await (_db.select(
      _db.exercises,
    )..where((e) => e.externalId.isIn(externalIds))).get();
    return {
      for (final row in rows)
        if (row.externalId != null) row.externalId!: row.id,
    };
  }
}

class _ExercisePlan {
  const _ExercisePlan({
    required this.externalId,
    required this.startGrams,
    required this.weeklyIncrementGrams,
    required this.sets,
    required this.reps,
  });

  final String externalId;
  final int startGrams;
  final int weeklyIncrementGrams;
  final int sets;
  final int reps;
}
