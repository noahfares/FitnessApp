import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';

/// Batch 1.4 — the `sets` table (`F-LOG-003`, `F-LOG-004`, `F-LOG-005`,
/// `F-LOG-023`).
void main() {
  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  var clock = DateTime(2026, 8, 6, 18, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 8, 6, 18, 30);
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
  });
  tearDown(() => db.close());

  Future<void> makeExercise(String id) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: id,
            name: id,
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
  }

  /// A session with one exercise, returning its `workout_exercises` id.
  Future<String> startWith(String exerciseId) async {
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, [exerciseId]);
    final rows = await workouts.watchExercises(workout.id).first;
    return rows.single.workoutExerciseId;
  }

  group('adding sets (F-LOG-003 §5)', () {
    test('a new set is pre-filled from the one above it', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final first = (await sets.getSets(we)).single;
      await sets.complete(
        first.id,
        weightGrams: const Value(100000),
        reps: const Value(8),
      );

      await sets.addSet(we);
      final rows = await sets.getSets(we);

      expect(rows, hasLength(2));
      expect(rows.last.weightGrams, 100000);
      expect(rows.last.reps, 8);
      // Pre-filled, but not pre-completed: only the lifter says a set happened.
      expect(rows.last.isCompleted, isFalse);
      expect(rows.last.position, 1);
    });

    test('the set type is carried down too', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final first = (await sets.getSets(we)).single;
      await sets.setType(first.id, SetType.warmup);

      await sets.addSet(we);

      // Promoting it silently would write a wrong `set_type`, which is the one
      // thing on the row that cannot be recovered later (`F-LOG-005`).
      expect((await sets.getSets(we)).last.setType, SetType.warmup);
    });
  });

  group('completion (F-LOG-003 §3)', () {
    test('stores the completion time and its local offset', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final set = (await sets.getSets(we)).single;

      await sets.complete(set.id, weightGrams: const Value(60000));

      final stored = (await sets.findById(set.id))!;
      expect(stored.isCompleted, isTrue);
      expect(stored.completedAt, clock.millisecondsSinceEpoch);
      // Rest intervals are derived from these afterwards (`F-TIM-007`).
      expect(stored.completedAtTzOffsetMinutes, clock.timeZoneOffset.inMinutes);
    });

    test('un-ticking keeps the values but clears the completion time', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final set = (await sets.getSets(we)).single;
      await sets.complete(
        set.id,
        weightGrams: const Value(60000),
        reps: const Value(5),
      );

      await sets.uncomplete(set.id);

      final stored = (await sets.findById(set.id))!;
      expect(stored.isCompleted, isFalse);
      expect(stored.weightGrams, 60000);
      expect(stored.reps, 5);
      // A stale completion time would corrupt every rest interval derived from
      // consecutive completions.
      expect(stored.completedAt, isNull);
    });

    test('a zero-weight set is valid, not an empty one', () async {
      await makeExercise('dip');
      final we = await startWith('dip');
      final set = (await sets.getSets(we)).single;

      await sets.complete(
        set.id,
        weightGrams: const Value(0),
        reps: const Value(12),
      );

      expect((await sets.findById(set.id))!.weightGrams, 0);
    });
  });

  group('deleting (F-LOG-003 §6)', () {
    test('a deleted set is tombstoned and undo restores it', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final set = (await sets.getSets(we)).single;

      await sets.deleteSet(set.id);
      expect(await sets.getSets(we), isEmpty);
      // Tombstoned, not destroyed (ADR-0008) — which is what makes undo a
      // field update rather than a resurrection.
      expect(await db.select(db.sets).get(), hasLength(1));

      await sets.restoreSet(set.id);
      expect(await sets.getSets(we), hasLength(1));
    });
  });

  group('notes (F-LOG-023)', () {
    test('an empty note is stored as no note at all', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final set = (await sets.getSets(we)).single;

      await sets.setNote(set.id, '  Left shoulder twinged  ');
      expect((await sets.findById(set.id))!.notes, 'Left shoulder twinged');

      await sets.setNote(set.id, '   ');
      // "Has a note" stays a single null check everywhere it is asked.
      expect((await sets.findById(set.id))!.notes, isNull);
    });
  });

  group('ghost values (F-LOG-004)', () {
    /// A finished session of [exerciseId] with the given completed sets.
    Future<void> logSession(
      String exerciseId,
      DateTime when,
      List<({int weight, int reps, SetType type})> performed,
    ) async {
      clock = when;
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, [exerciseId]);
      final we = (await workouts.watchExercises(workout.id).first)
          .single
          .workoutExerciseId;

      final existing = (await sets.getSets(we)).single;
      for (var i = 0; i < performed.length; i++) {
        final id = i == 0 ? existing.id : await sets.addSet(we);
        await sets.setType(id, performed[i].type);
        await sets.complete(
          id,
          weightGrams: Value(performed[i].weight),
          reps: Value(performed[i].reps),
        );
      }
      await workouts.finish(workout.id);
    }

    test('a first-ever session has no ghost, rather than a zero', () async {
      await makeExercise('bench');
      expect(await sets.ghostSetsFor('bench'), isEmpty);
    });

    test('reads the most recent finished session containing it', () async {
      await makeExercise('bench');
      await logSession('bench', DateTime(2026, 7, 1), [
        (weight: 90000, reps: 8, type: SetType.working),
      ]);
      await logSession('bench', DateTime(2026, 7, 8), [
        (weight: 100000, reps: 8, type: SetType.working),
        (weight: 100000, reps: 6, type: SetType.working),
      ]);

      final ghosts = await sets.ghostSetsFor('bench');
      expect([for (final g in ghosts) g.weightGrams], [100000, 100000]);
      expect([for (final g in ghosts) g.reps], [8, 6]);
      expect(
        ghosts.first.performedAt,
        DateTime(2026, 7, 8).millisecondsSinceEpoch,
      );
    });

    test('the session in progress is not its own ghost', () async {
      await makeExercise('bench');
      await logSession('bench', DateTime(2026, 7, 1), [
        (weight: 90000, reps: 8, type: SetType.working),
      ]);

      clock = DateTime(2026, 7, 8);
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, ['bench']);
      final we = (await workouts.watchExercises(workout.id).first)
          .single
          .workoutExerciseId;
      await sets.complete(
        (await sets.getSets(we)).single.id,
        weightGrams: const Value(105000),
        reps: const Value(5),
      );

      // Today's numbers are not last time's.
      expect((await sets.ghostSetsFor('bench')).single.weightGrams, 90000);
    });

    test('an abandoned exercise contributes only what was completed', () async {
      await makeExercise('bench');
      clock = DateTime(2026, 7, 1);
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, ['bench']);
      final we = (await workouts.watchExercises(workout.id).first)
          .single
          .workoutExerciseId;
      final first = (await sets.getSets(we)).single;
      await sets.complete(
        first.id,
        weightGrams: const Value(80000),
        reps: const Value(10),
      );
      // Started, never finished — someone racked it and left.
      await sets.addSet(we);
      await workouts.finish(workout.id);

      expect(await sets.ghostSetsFor('bench'), hasLength(1));
    });

    test(
      'discarding the previous session falls back to the one before',
      () async {
        await makeExercise('bench');
        await logSession('bench', DateTime(2026, 7, 1), [
          (weight: 90000, reps: 8, type: SetType.working),
        ]);
        await logSession('bench', DateTime(2026, 7, 8), [
          (weight: 100000, reps: 8, type: SetType.working),
        ]);
        expect((await sets.ghostSetsFor('bench')).single.weightGrams, 100000);

        final recent = (await db.select(db.workouts).get())
            .where(
              (w) => w.startedAt == DateTime(2026, 7, 8).millisecondsSinceEpoch,
            )
            .single;
        await workouts.discard(recent.id);

        expect((await sets.ghostSetsFor('bench')).single.weightGrams, 90000);
      },
    );

    test(
      'warm-ups come back labelled, so they can be matched as warm-ups',
      () async {
        await makeExercise('bench');
        await logSession('bench', DateTime(2026, 7, 1), [
          (weight: 40000, reps: 10, type: SetType.warmup),
          (weight: 100000, reps: 5, type: SetType.working),
        ]);

        final ghosts = await sets.ghostSetsFor('bench');
        expect([for (final g in ghosts) g.setType], ['warmup', 'working']);
      },
    );

    test('stays under the 50 ms budget with years of history', () async {
      // The hottest path in the app, run on every exercise open
      // (docs/60-ENGINEERING.md §performance-budgets). Three years of training
      // four times a week, five exercises a session, four sets each.
      await makeExercise('bench');
      for (var i = 1; i < 6; i++) {
        await makeExercise('other$i');
      }

      final start = DateTime(2023, 8, 6);
      await db.transaction(() async {
        for (var session = 0; session < 600; session++) {
          final startedAt = start
              .add(Duration(days: session * 2))
              .millisecondsSinceEpoch;
          final workoutId = 'w$session';
          await db.customStatement(
            'INSERT INTO workouts (id, user_id, name, started_at, '
            'started_at_tz_offset_minutes, ended_at, created_at, updated_at) '
            'VALUES (?, ?, ?, ?, 0, ?, ?, ?)',
            [
              workoutId,
              'local',
              'Session $session',
              startedAt,
              startedAt + 3600000,
              startedAt,
              startedAt,
            ],
          );
          for (var e = 0; e < 5; e++) {
            final weId = 'we-$session-$e';
            await db.customStatement(
              'INSERT INTO workout_exercises (id, user_id, workout_id, '
              'exercise_id, position, created_at, updated_at) '
              'VALUES (?, ?, ?, ?, ?, ?, ?)',
              [
                weId,
                'local',
                workoutId,
                e == 0 ? 'bench' : 'other$e',
                e,
                startedAt,
                startedAt,
              ],
            );
            for (var s = 0; s < 4; s++) {
              await db.customStatement(
                'INSERT INTO sets (id, user_id, workout_exercise_id, position, '
                'set_type, weight_grams, reps, is_completed, completed_at, '
                'created_at, updated_at) '
                'VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)',
                [
                  's-$session-$e-$s',
                  'local',
                  weId,
                  s,
                  'working',
                  100000 + s * 1000,
                  8,
                  startedAt,
                  startedAt,
                  startedAt,
                ],
              );
            }
          }
        }
      });

      // Warm the query plan once; the budget is about steady-state opens, not
      // about the first statement prepared after launch.
      await sets.ghostSetsFor('bench');

      final stopwatch = Stopwatch()..start();
      final ghosts = await sets.ghostSetsFor('bench');
      stopwatch.stop();

      expect(ghosts, hasLength(4));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason:
            'ghost lookup over 12,000 sets took '
            '${stopwatch.elapsedMilliseconds} ms',
      );
    });
  });
}
