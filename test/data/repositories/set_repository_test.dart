import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/domain/logging/warmup_generator.dart';

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

  group('rest-taken recording (F-TIM-007)', () {
    test('the first completion of a session has no rest to report', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final set = (await sets.getSets(we)).single;

      await sets.complete(set.id, weightGrams: const Value(60000));

      expect((await sets.findById(set.id))!.restTakenSeconds, isNull);
    });

    test(
      'records the gap since the previous completion in the session',
      () async {
        await makeExercise('bench');
        final we = await startWith('bench');
        final first = (await sets.getSets(we)).single;
        await sets.complete(first.id, weightGrams: const Value(60000));

        await sets.addSet(we);
        final second = (await sets.getSets(we)).last;
        clock = clock.add(const Duration(seconds: 90));
        await sets.complete(second.id, weightGrams: const Value(60000));

        expect((await sets.findById(second.id))!.restTakenSeconds, 90);
      },
    );

    test('is scoped to the session, not to one exercise — a superset '
        'partner set counts', () async {
      await makeExercise('bench');
      await makeExercise('row');
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, ['bench', 'row']);
      final rows = await workouts.watchExercises(workout.id).first;
      final benchWe = rows.firstWhere((e) => e.exerciseId == 'bench');
      final rowWe = rows.firstWhere((e) => e.exerciseId == 'row');

      final benchSet = (await sets.getSets(benchWe.workoutExerciseId)).single;
      await sets.complete(benchSet.id, weightGrams: const Value(60000));

      clock = clock.add(const Duration(seconds: 30));
      final rowSet = (await sets.getSets(rowWe.workoutExerciseId)).single;
      await sets.complete(rowSet.id, weightGrams: const Value(40000));

      expect((await sets.findById(rowSet.id))!.restTakenSeconds, 30);
    });

    test('un-ticking clears it along with the completion time', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final first = (await sets.getSets(we)).single;
      await sets.complete(first.id, weightGrams: const Value(60000));
      await sets.addSet(we);
      final second = (await sets.getSets(we)).last;
      clock = clock.add(const Duration(seconds: 60));
      await sets.complete(second.id, weightGrams: const Value(60000));

      await sets.uncomplete(second.id);

      expect((await sets.findById(second.id))!.restTakenSeconds, isNull);
    });

    test(
      'a deleted prior set is not counted as the previous completion',
      () async {
        await makeExercise('bench');
        final we = await startWith('bench');
        final first = (await sets.getSets(we)).single;
        await sets.complete(first.id, weightGrams: const Value(60000));
        await sets.deleteSet(first.id);

        await sets.addSet(we);
        final second = (await sets.getSets(we)).last;
        clock = clock.add(const Duration(seconds: 45));
        await sets.complete(second.id, weightGrams: const Value(60000));

        // The only completion left standing is this one, so there is nothing
        // prior to have rested from.
        expect((await sets.findById(second.id))!.restTakenSeconds, isNull);
      },
    );
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

  group('RPE (F-LOG-014 §1)', () {
    test('is written through and cleared the same way', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final set = (await sets.getSets(we)).single;

      await sets.setRpe(set.id, 8.5);
      expect((await sets.findById(set.id))!.rpe, 8.5);

      await sets.setRpe(set.id, null);
      expect((await sets.findById(set.id))!.rpe, isNull);
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

  group('watchLastUsedAtByExercise (F-CAT-006 §2)', () {
    test('reports the most recent session containing each exercise', () async {
      await makeExercise('bench');
      await makeExercise('squat');

      clock = DateTime(2026, 8, 1);
      final firstWe = await startWith('bench');
      await sets.complete(
        (await sets.getSets(firstWe)).single.id,
        weightGrams: const Value(100000),
        reps: const Value(5),
      );
      await workouts.finish((await workouts.findActive())!.id);

      clock = DateTime(2026, 8, 5);
      final secondWe = await startWith('bench');
      await sets.complete(
        (await sets.getSets(secondWe)).single.id,
        weightGrams: const Value(105000),
        reps: const Value(5),
      );
      await workouts.finish((await workouts.findActive())!.id);

      final lastUsed = await sets.watchLastUsedAtByExercise().first;

      expect(lastUsed['bench'], DateTime(2026, 8, 5).millisecondsSinceEpoch);
      // Never touched, so it never appears — not zero, absent.
      expect(lastUsed.containsKey('squat'), isFalse);
    });

    test('an incomplete set does not count as used', () async {
      await makeExercise('bench');
      await startWith('bench'); // Added, but never completed.

      final lastUsed = await sets.watchLastUsedAtByExercise().first;

      expect(lastUsed.containsKey('bench'), isFalse);
    });
  });

  group('watchExerciseHistory (F-ANA-002)', () {
    test('newest session first, other exercises excluded', () async {
      await makeExercise('bench');
      await makeExercise('squat');

      clock = DateTime(2026, 8, 1);
      final firstWe = await startWith('bench');
      await sets.complete(
        (await sets.getSets(firstWe)).single.id,
        weightGrams: const Value(100000),
        reps: const Value(5),
      );
      await workouts.finish((await workouts.findActive())!.id);

      clock = DateTime(2026, 8, 5);
      final squatWe = await startWith('squat');
      await sets.complete(
        (await sets.getSets(squatWe)).single.id,
        weightGrams: const Value(140000),
        reps: const Value(5),
      );
      await workouts.finish((await workouts.findActive())!.id);

      clock = DateTime(2026, 8, 8);
      final secondWe = await startWith('bench');
      await sets.complete(
        (await sets.getSets(secondWe)).single.id,
        weightGrams: const Value(105000),
        reps: const Value(5),
      );
      await workouts.finish((await workouts.findActive())!.id);

      final history = await sets.watchExerciseHistory('bench').first;

      expect(history, hasLength(2));
      expect(history[0].startedAt, DateTime(2026, 8, 8).millisecondsSinceEpoch);
      expect(history[1].startedAt, DateTime(2026, 8, 1).millisecondsSinceEpoch);
      expect(history[0].bestSet?.weightGrams, 105000);
    });

    test('an incomplete or warm-up set is excluded from volume', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final workingId = (await sets.getSets(we)).single.id;
      await sets.setType(workingId, SetType.warmup);
      await sets.complete(
        workingId,
        weightGrams: const Value(60000),
        reps: const Value(10),
      );
      final plannedId = await sets.addSet(we);
      await sets.updateValues(
        plannedId,
        weightGrams: const Value(100000),
        reps: const Value(5),
      );

      final history = await sets.watchExerciseHistory('bench').first;

      expect(history.single.volumeGrams, 0);
      expect(history.single.countedSets, isEmpty);
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

  group('insertWarmupSets (F-LOG-020)', () {
    test('inserts before existing sets, shifting their positions', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final existing = (await sets.getSets(we)).single;
      await sets.updateValues(
        existing.id,
        weightGrams: const Value(100000),
        reps: const Value(5),
      );

      await sets.insertWarmupSets(we, const [
        GeneratedWarmupSet(weightGrams: 20000, reps: 8),
        GeneratedWarmupSet(weightGrams: 60000, reps: 3),
      ]);

      final all = await sets.getSets(we);
      expect(all, hasLength(3));
      expect(all[0].setType, SetType.warmup);
      expect(all[0].weightGrams, 20000);
      expect(all[0].reps, 8);
      expect(all[1].setType, SetType.warmup);
      expect(all[1].weightGrams, 60000);
      expect(all[1].reps, 3);
      // The original working set survives, now shifted to last.
      expect(all[2].id, existing.id);
      expect(all[2].weightGrams, 100000);
      expect(all[2].position, 2);
    });

    test('an empty step list writes nothing', () async {
      await makeExercise('bench');
      final we = await startWith('bench');
      await sets.insertWarmupSets(we, const []);
      expect(await sets.getSets(we), hasLength(1));
    });
  });
}
