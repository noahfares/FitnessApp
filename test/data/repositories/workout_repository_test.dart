import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/domain/progression/progression_rationale.dart';
import 'package:fitness_app/domain/progression/progression_rule.dart';

/// `F-LOG-001`, `F-LOG-002`, `F-LOG-007`.
void main() {
  late AppDatabase db;
  late WorkoutRepository repo;
  var clock = DateTime(2026, 8, 6, 18, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 8, 6, 18, 30);
    repo = WorkoutRepository(db, clock: () => clock);
  });
  tearDown(() => db.close());

  Future<String> makeExercise(String id, String name) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: id,
            name: name,
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    return id;
  }

  group('starting (F-LOG-001)', () {
    test('records the local offset beside the timestamp', () async {
      final workout = await repo.start();

      expect(workout.startedAt, clock.millisecondsSinceEpoch);
      expect(workout.endedAt, isNull);
      // Without the offset it is impossible to reconstruct which local day a
      // session belongs to (ADR-0008).
      expect(workout.startedAtTzOffsetMinutes, clock.timeZoneOffset.inMinutes);
    });

    test('names the session after the time of day when given nothing', () {
      expect(
        WorkoutRepository.defaultNameFor(DateTime(2026, 8, 6, 7)),
        'Morning Workout',
      );
      expect(
        WorkoutRepository.defaultNameFor(DateTime(2026, 8, 6, 13)),
        'Afternoon Workout',
      );
      expect(
        WorkoutRepository.defaultNameFor(DateTime(2026, 8, 6, 21)),
        'Evening Workout',
      );
    });

    test('a supplied name wins, trimmed; blank falls back', () async {
      expect((await repo.start(name: '  Push A  ')).name, 'Push A');
      await repo.finish((await repo.findActive())!.id);
      expect((await repo.start(name: '   ')).name, 'Evening Workout');
    });

    test('refuses a second in-progress workout', () async {
      final first = await repo.start();

      // Which session was meant to survive is not this layer's decision
      // (`F-LOG-001` §3).
      await expectLater(
        repo.start(),
        throwsA(isA<ActiveWorkoutExistsException>()),
      );
      expect((await repo.findActive())!.id, first.id);
    });

    test('finishing frees the slot', () async {
      final first = await repo.start();
      await repo.finish(first.id);

      expect(await repo.findActive(), isNull);
      final second = await repo.start();
      expect(second.id, isNot(first.id));
    });

    test('watchActive re-emits as the session opens and closes', () async {
      final seen = <String?>[];
      final sub = repo.watchActive().listen((w) => seen.add(w?.id));

      final workout = await repo.start();
      await repo.finish(workout.id);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(seen.first, isNull);
      expect(seen, contains(workout.id));
      expect(seen.last, isNull);
    });
  });

  group('adding exercises (F-LOG-002)', () {
    test('appends in selection order, each with one empty set ready', () async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('squat', 'Back Squat');
      final workout = await repo.start();

      await repo.addExercises(workout.id, ['squat', 'bench']);

      final rows = await repo.watchExercises(workout.id).first;
      expect([for (final r in rows) r.name], ['Back Squat', 'Bench Press']);
      expect([for (final r in rows) r.position], [0, 1]);
      // Ready to log against, rather than needing an "add set" tap first.
      expect(rows.every((r) => r.setCount == 1), isTrue);
      expect(rows.every((r) => r.completedSetCount == 0), isTrue);
    });

    test('a second batch continues the positions', () async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('squat', 'Back Squat');
      final workout = await repo.start();

      await repo.addExercises(workout.id, ['bench']);
      await repo.addExercises(workout.id, ['squat']);

      final rows = await repo.watchExercises(workout.id).first;
      expect([for (final r in rows) r.position], [0, 1]);
    });

    test('the same exercise may appear twice in one session', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();

      // Doing a movement again at the end is legitimate, so this is
      // deliberately not de-duplicated.
      await repo.addExercises(workout.id, ['bench', 'bench']);

      final rows = await repo.watchExercises(workout.id).first;
      expect(rows, hasLength(2));
      expect(rows[0].workoutExerciseId, isNot(rows[1].workoutExerciseId));
    });

    test('adding nothing writes nothing', () async {
      final workout = await repo.start();
      await repo.addExercises(workout.id, const []);
      expect(await repo.watchExercises(workout.id).first, isEmpty);
    });

    test('a tombstoned exercise still renders inside the session', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);

      await (db.update(db.exercises)..where((e) => e.id.equals('bench'))).write(
        const ExercisesCompanion(deletedAt: Value(999)),
      );

      // History referencing a deleted exercise must still render
      // (docs/21-DATA-MODEL.md §deletion-policy).
      final rows = await repo.watchExercises(workout.id).first;
      expect(rows.single.name, 'Bench Press');
    });

    test('counts completed sets per exercise', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);

      final we = (await repo.watchExercises(workout.id).first).single;
      await db
          .into(db.sets)
          .insert(
            SetsCompanion.insert(
              id: 's-2',
              workoutExerciseId: we.workoutExerciseId,
              position: 1,
              isCompleted: const Value(true),
              createdAt: 1,
              updatedAt: 1,
            ),
          );

      final after = (await repo.watchExercises(workout.id).first).single;
      expect(after.setCount, 2);
      expect(after.completedSetCount, 1);
    });
  });

  group('tally', () {
    test('is empty until a set is completed', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);

      final tally = await repo.tally(workout.id);
      expect(tally.exercises, 1);
      expect(tally.completedSets, 0);
      // An empty finish would leave a junk history entry (`F-LOG-001` §6).
      expect(tally.isEmpty, isTrue);
    });

    test('counts completed sets across exercises', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final we = (await repo.watchExercises(workout.id).first).single;

      await (db.update(db.sets)
            ..where((s) => s.workoutExerciseId.equals(we.workoutExerciseId)))
          .write(const SetsCompanion(isCompleted: Value(true)));

      final tally = await repo.tally(workout.id);
      expect(tally.completedSets, 1);
      expect(tally.isEmpty, isFalse);
    });
  });

  group('discard (F-LOG-001 §5)', () {
    test('tombstones the session and everything in it', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);

      clock = DateTime(2026, 8, 6, 19);
      await repo.discard(workout.id);

      // Gone from every read...
      expect(await repo.findActive(), isNull);
      expect(await repo.findById(workout.id), isNull);
      expect(await repo.watchExercises(workout.id).first, isEmpty);

      // ...but nothing was destroyed. ADR-0008 explicitly overrides the
      // hard-delete this feature was originally written against.
      final rawWorkouts = await db.select(db.workouts).get();
      final rawExercises = await db.select(db.workoutExercises).get();
      final rawSets = await db.select(db.sets).get();
      expect(rawWorkouts, hasLength(1));
      expect(rawExercises, hasLength(1));
      expect(rawSets, hasLength(1));
      for (final stamp in [
        rawWorkouts.single.deletedAt,
        rawExercises.single.deletedAt,
        rawSets.single.deletedAt,
      ]) {
        expect(stamp, clock.millisecondsSinceEpoch);
      }
    });

    test('frees the in-progress slot', () async {
      final workout = await repo.start();
      await repo.discard(workout.id);

      // The partial unique index excludes tombstoned rows, so a discarded
      // session does not block the next one.
      expect((await repo.start()).id, isNot(workout.id));
    });

    test('leaves another session untouched', () async {
      await makeExercise('bench', 'Bench Press');
      final keep = await repo.start();
      await repo.addExercises(keep.id, ['bench']);
      await repo.finish(keep.id);

      final scratch = await repo.start();
      await repo.discard(scratch.id);

      expect(await repo.findById(keep.id), isNotNull);
      expect(await repo.watchExercises(keep.id).first, hasLength(1));
    });
  });

  /// Completes the sole set of [workoutExerciseId] with [weightGrams] ×
  /// [reps], so history queries have something to aggregate.
  Future<void> completeSet(
    String workoutExerciseId, {
    required int weightGrams,
    required int reps,
  }) async {
    final set =
        (await (db.select(db.sets)
                  ..where((s) => s.workoutExerciseId.equals(workoutExerciseId)))
                .get())
            .first;
    await (db.update(db.sets)..where((s) => s.id.equals(set.id))).write(
      SetsCompanion(
        isCompleted: const Value(true),
        weightGrams: Value(weightGrams),
        reps: Value(reps),
      ),
    );
  }

  group('watchHistory (F-LOG-011)', () {
    test('only finished sessions, newest first', () async {
      await makeExercise('bench', 'Bench Press');
      final older = await repo.start(name: 'Older');
      await repo.addExercises(older.id, ['bench']);
      await completeSet(
        (await repo.watchExercises(older.id).first).single.workoutExerciseId,
        weightGrams: 100000,
        reps: 5,
      );
      await repo.finish(older.id);

      clock = DateTime(2026, 8, 7);
      final newer = await repo.start(name: 'Newer');
      await repo.addExercises(newer.id, ['bench']);
      await repo.finish(newer.id);

      // The still in-progress session never shows up in history.
      await repo.start(name: 'Still going');

      final history = await repo.watchHistory().first;
      expect([for (final h in history) h.name], ['Newer', 'Older']);
      expect(history.last.totalVolumeGrams, 500000);
      expect(history.last.completedSetCount, 1);
    });

    test('excludes the warm-up from the volume total', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final we = (await repo.watchExercises(workout.id).first).single;
      await db
          .into(db.sets)
          .insert(
            SetsCompanion.insert(
              id: 'warmup-set',
              workoutExerciseId: we.workoutExerciseId,
              position: 1,
              setType: const Value(SetType.warmup),
              isCompleted: const Value(true),
              weightGrams: const Value(60000),
              reps: const Value(10),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await completeSet(we.workoutExerciseId, weightGrams: 100000, reps: 5);
      await repo.finish(workout.id);

      final history = await repo.watchHistory().first;
      // Only the working set counts: the seeded empty set plus the warm-up's
      // own weight must not leak in (`F-LOG-005`).
      expect(history.single.totalVolumeGrams, 500000);
    });

    test('matches by workout name or by an exercise inside it', () async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('squat', 'Back Squat');
      final byName = await repo.start(name: 'Leg Day');
      await repo.addExercises(byName.id, ['squat']);
      await repo.finish(byName.id);

      clock = DateTime(2026, 8, 7);
      final byExercise = await repo.start(name: 'Push A');
      await repo.addExercises(byExercise.id, ['bench']);
      await repo.finish(byExercise.id);

      expect((await repo.watchHistory(query: 'leg').first).map((h) => h.name), [
        'Leg Day',
      ]);
      expect(
        (await repo.watchHistory(query: 'bench').first).map((h) => h.name),
        ['Push A'],
      );
      expect(await repo.watchHistory(query: 'nonexistent').first, isEmpty);
    });

    test('limit bounds how many rows come back', () async {
      await makeExercise('bench', 'Bench Press');
      for (var i = 0; i < 3; i++) {
        clock = DateTime(2026, 8, 6 + i);
        final workout = await repo.start(name: 'Session $i');
        await repo.addExercises(workout.id, ['bench']);
        await repo.finish(workout.id);
      }

      expect(await repo.watchHistory(limit: 2).first, hasLength(2));
    });
  });

  group('editing a past workout (F-LOG-009)', () {
    test('rename, reschedule and notes all write through', () async {
      final workout = await repo.start();
      await repo.finish(workout.id);

      await repo.rename(workout.id, '  Heavy day  ');
      final rescheduled = DateTime(2026, 1, 1, 9);
      await repo.reschedule(workout.id, rescheduled);
      await repo.setWorkoutNotes(workout.id, '  felt strong  ');

      final updated = await repo.findById(workout.id);
      expect(updated!.name, 'Heavy day');
      expect(updated.startedAt, rescheduled.millisecondsSinceEpoch);
      expect(
        updated.startedAtTzOffsetMinutes,
        rescheduled.timeZoneOffset.inMinutes,
      );
      expect(updated.notes, 'felt strong');
    });

    test('a blank note clears rather than storing empty text', () async {
      final workout = await repo.start();
      await repo.setWorkoutNotes(workout.id, 'first');
      await repo.setWorkoutNotes(workout.id, '   ');
      expect((await repo.findById(workout.id))!.notes, isNull);
    });

    test('exercise notes are independent of the workout note', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final we = (await repo.watchExercises(workout.id).first).single;

      await repo.setExerciseNotes(we.workoutExerciseId, 'seat pin 4');

      final after = (await repo.watchExercises(workout.id).first).single;
      expect(after.notes, 'seat pin 4');
    });

    test('removing an exercise cascades its sets', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final we = (await repo.watchExercises(workout.id).first).single;

      await repo.removeExerciseFromWorkout(we.workoutExerciseId);

      expect(await repo.watchExercises(workout.id).first, isEmpty);
      final rawSets = await db.select(db.sets).get();
      expect(rawSets.single.deletedAt, isNotNull);
    });

    test('deleteWorkout tombstones the same way discard does', () async {
      final workout = await repo.start();
      await repo.finish(workout.id);

      await repo.deleteWorkout(workout.id);

      expect(await repo.findById(workout.id), isNull);
      expect((await db.select(db.workouts).get()).single.deletedAt, isNotNull);
    });
  });

  group('createRetroactive (F-LOG-009 §4)', () {
    test('logs an already-finished session at the chosen time', () async {
      final startedAt = DateTime(2026, 1, 1, 8);
      final endedAt = DateTime(2026, 1, 1, 9);

      final workout = await repo.createRetroactive(
        name: 'Remembered leg day',
        startedAt: startedAt,
        endedAt: endedAt,
      );

      expect(workout.name, 'Remembered leg day');
      expect(workout.startedAt, startedAt.millisecondsSinceEpoch);
      expect(workout.endedAt, endedAt.millisecondsSinceEpoch);
      // It does not occupy the active-workout slot.
      expect(await repo.findActive(), isNull);
    });

    test('a blank name falls back the same way a live session does', () async {
      final workout = await repo.createRetroactive(
        name: '  ',
        startedAt: DateTime(2026, 1, 1, 8),
        endedAt: DateTime(2026, 1, 1, 9),
      );
      expect(workout.name, 'Morning Workout');
    });
  });

  group('summaryStats (F-LOG-018)', () {
    test(
      'totals the session and compares it to the last of the same name',
      () async {
        await makeExercise('bench', 'Bench Press');
        final first = await repo.start(name: 'Push A');
        await repo.addExercises(first.id, ['bench']);
        await completeSet(
          (await repo.watchExercises(first.id).first).single.workoutExerciseId,
          weightGrams: 90000,
          reps: 5,
        );
        await repo.finish(first.id);

        clock = DateTime(2026, 8, 13);
        final second = await repo.start(name: 'Push A');
        await repo.addExercises(second.id, ['bench']);
        await completeSet(
          (await repo.watchExercises(second.id).first).single.workoutExerciseId,
          weightGrams: 100000,
          reps: 5,
        );
        await repo.finish(second.id);

        final stats = await repo.summaryStats(second.id);
        expect(stats.totalVolumeGrams, 500000);
        expect(stats.completedSetCount, 1);
        expect(stats.exerciseCount, 1);
        expect(stats.muscles, {Muscle.chest});
        expect(stats.previous, isNotNull);
        expect(stats.previous!.totalVolumeGrams, 450000);
      },
    );

    test('a first-ever session has no previous to compare against', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start(name: 'Push A');
      await repo.addExercises(workout.id, ['bench']);
      await repo.finish(workout.id);

      expect((await repo.summaryStats(workout.id)).previous, isNull);
    });
  });

  group('starting from a routine day (F-ROU-010)', () {
    late RoutineRepository routines;

    setUp(() {
      routines = RoutineRepository(db, clock: () => clock);
    });

    Future<String> makeDayWithTarget() async {
      await makeExercise('squat', 'Back Squat');
      final routine = await routines.create(name: 'Leg day');
      final day = await routines.addDay(routine.id, name: 'Legs');
      await routines.addExercises(day.id, ['squat']);
      final [detail] = await routines.watchExercises(day.id).first;
      await routines.setTargets(
        detail.routineExerciseId,
        targetSets: const Value(3),
        targetRepsMin: const Value(6),
        targetRepsMax: const Value(10),
        targetWeightGrams: const Value(100000),
      );
      return day.id;
    }

    test('creates the right number of set rows, named and provenanced from '
        'the day', () async {
      final dayId = await makeDayWithTarget();

      final workout = await repo.startFromRoutineDay(dayId);

      expect(workout.name, 'Legs');
      expect(workout.sourceRoutineDayId, dayId);
      final [exercise] = await repo.watchExercises(workout.id).first;
      expect(exercise.setCount, 3);
      expect(exercise.target!.repsMin, 6);
      expect(exercise.target!.repsMax, 10);
      expect(exercise.target!.weightGrams, 100000);
      // The copy is complete, not a live reference: rows are unfinished
      // targets, not already-logged values (`F-ROU-010` §1, §5).
      final sets = await db.select(db.sets).get();
      expect(sets, hasLength(3));
      expect(
        sets.every((s) => !s.isCompleted && s.weightGrams == null),
        isTrue,
      );
    });

    test('editing the routine afterwards does not alter the workout', () async {
      final dayId = await makeDayWithTarget();
      final workout = await repo.startFromRoutineDay(dayId);
      final [before] = await repo.watchExercises(workout.id).first;

      final [detail] = await routines.watchExercises(dayId).first;
      await routines.setTargets(
        detail.routineExerciseId,
        targetSets: const Value(10),
        targetWeightGrams: const Value(1),
      );

      final [after] = await repo.watchExercises(workout.id).first;
      expect(after.setCount, before.setCount);
      expect(after.target!.weightGrams, before.target!.weightGrams);
    });

    test(
      'editing the routine after the workout is finished leaves the '
      'historical record unchanged too (Phase 2 exit criterion, ADR-0004)',
      () async {
        final dayId = await makeDayWithTarget();
        final workout = await repo.startFromRoutineDay(dayId);
        final [beforeFinish] = await repo.watchExercises(workout.id).first;
        await repo.finish(workout.id);

        // Not just re-targeted — the routine day is torn down entirely, the
        // most destructive edit a routine can receive.
        final [detail] = await routines.watchExercises(dayId).first;
        await routines.removeExercise(detail.routineExerciseId);
        final day = (await routines.findDayById(dayId))!;
        await routines.delete(day.routineId);

        final history = await repo.watchHistory().first;
        expect(history, hasLength(1));
        final [afterEdit] = await repo.watchExercises(workout.id).first;
        expect(afterEdit.exerciseId, beforeFinish.exerciseId);
        expect(afterEdit.setCount, beforeFinish.setCount);
        expect(afterEdit.target!.weightGrams, beforeFinish.target!.weightGrams);
        expect(afterEdit.target!.repsMin, beforeFinish.target!.repsMin);
      },
    );

    test(
      'deleting the routine mid-workout does not break the session',
      () async {
        final dayId = await makeDayWithTarget();
        final workout = await repo.startFromRoutineDay(dayId);
        final day = (await routines.findDayById(dayId))!;

        await routines.delete(day.routineId);

        // The snapshot copy lives entirely in `workout_exercises`/`sets`, so
        // deleting the routine it came from removes nothing from the session
        // (`ADR-0004`).
        final reloaded = await repo.findById(workout.id);
        expect(reloaded, isNotNull);
        final exercises = await repo.watchExercises(workout.id).first;
        expect(exercises, hasLength(1));
      },
    );

    test('a day with no targets behaves like an empty workout with the '
        'right exercises', () async {
      await makeExercise('row', 'Cable Row');
      final routine = await routines.create(name: 'Pull day');
      final day = await routines.addDay(routine.id, name: 'Pull');
      await routines.addExercises(day.id, ['row']);

      final workout = await repo.startFromRoutineDay(day.id);

      final [exercise] = await repo.watchExercises(workout.id).first;
      expect(exercise.setCount, 1);
      expect(exercise.target!.isEmpty, isTrue);
    });

    test('refuses a second in-progress workout', () async {
      final dayId = await makeDayWithTarget();
      await repo.start();

      await expectLater(
        repo.startFromRoutineDay(dayId),
        throwsA(isA<ActiveWorkoutExistsException>()),
      );
    });

    test(
      "carries the routine day's superset grouping into the session",
      () async {
        await makeExercise('bench', 'Bench Press');
        await makeExercise('fly', 'Cable Fly');
        final routine = await routines.create(name: 'Push');
        final day = await routines.addDay(routine.id, name: 'Day 1');
        await routines.addExercises(day.id, ['bench', 'fly']);
        final rows = await routines.watchExercises(day.id).first;
        await routines.groupExercises([
          for (final row in rows) row.routineExerciseId,
        ]);

        final workout = await repo.startFromRoutineDay(day.id);

        final exercises = await repo.watchExercises(workout.id).first;
        expect(exercises[0].groupId, isNotNull);
        expect(exercises[0].groupId, exercises[1].groupId);
      },
    );
  });

  group('progression-proposed targets (F-PRG-001, batch 4.1)', () {
    late RoutineRepository routines;
    late SetRepository sets;

    setUp(() {
      routines = RoutineRepository(db, clock: () => clock);
      sets = SetRepository(db, clock: () => clock);
    });

    Future<String> makeDayWithRule(ProgressionRule rule) async {
      await makeExercise('bench', 'Bench Press');
      final routine = await routines.create(name: 'Push');
      final day = await routines.addDay(routine.id, name: 'Push');
      await routines.addExercises(day.id, ['bench']);
      final [detail] = await routines.watchExercises(day.id).first;
      await routines.setTargets(
        detail.routineExerciseId,
        targetSets: const Value(3),
        targetRepsMin: const Value(5),
        targetRepsMax: const Value(5),
        targetWeightGrams: const Value(100000),
      );
      await routines.setProgressionRule(detail.routineExerciseId, rule);
      return day.id;
    }

    test('first start with a linear rule proposes the routine\'s own static '
        'target — there is no history yet to progress from', () async {
      final dayId = await makeDayWithRule(
        const LinearProgressionRule(
          config: LinearProgressionConfig(incrementGrams: 2500),
        ),
      );

      final workout = await repo.startFromRoutineDay(dayId);
      final [exercise] = await repo.watchExercises(workout.id).first;

      expect(exercise.target!.weightGrams, 100000);
      expect(exercise.target!.rationale!.outcome, ProgressionOutcome.firstRun);
    });

    test('a second start after a fully successful session proposes the '
        'incremented weight, not the routine\'s static target', () async {
      final dayId = await makeDayWithRule(
        const LinearProgressionRule(
          config: LinearProgressionConfig(incrementGrams: 2500),
        ),
      );

      final first = await repo.startFromRoutineDay(dayId);
      final [firstExercise] = await repo.watchExercises(first.id).first;
      for (final set in await sets.getSets(firstExercise.workoutExerciseId)) {
        await sets.complete(
          set.id,
          weightGrams: const Value(100000),
          reps: const Value(5),
        );
      }
      await repo.finish(first.id);
      clock = clock.add(const Duration(days: 2));

      final second = await repo.startFromRoutineDay(dayId);
      final [secondExercise] = await repo.watchExercises(second.id).first;

      expect(secondExercise.target!.weightGrams, 102500);
      expect(
        secondExercise.target!.rationale!.outcome,
        ProgressionOutcome.success,
      );
    });

    test('three consecutive failed sessions propose a deloaded weight, and say '
        'so — not silently the same weight a fourth time', () async {
      final dayId = await makeDayWithRule(
        const LinearProgressionRule(
          config: LinearProgressionConfig(
            incrementGrams: 2500,
            failureThreshold: 3,
            deloadFraction: 0.10,
          ),
        ),
      );

      Future<String> startFailAndFinish() async {
        final workout = await repo.startFromRoutineDay(dayId);
        final [exercise] = await repo.watchExercises(workout.id).first;
        for (final set in await sets.getSets(exercise.workoutExerciseId)) {
          await sets.complete(
            set.id,
            weightGrams: const Value(100000),
            reps: const Value(3), // below the 5-rep target: a failure
          );
        }
        await repo.finish(workout.id);
        clock = clock.add(const Duration(days: 2));
        return workout.id;
      }

      await startFailAndFinish();
      await startFailAndFinish();
      await startFailAndFinish();

      final fourth = await repo.startFromRoutineDay(dayId);
      final [exercise] = await repo.watchExercises(fourth.id).first;

      expect(exercise.target!.weightGrams, 90000);
      expect(exercise.target!.rationale!.outcome, ProgressionOutcome.deload);
    });

    test('manual carry-forward (the default) carries the last logged weight '
        'forward with no automated increment', () async {
      final dayId = await makeDayWithRule(const ManualCarryForwardRule());

      final first = await repo.startFromRoutineDay(dayId);
      final [firstExercise] = await repo.watchExercises(first.id).first;
      for (final set in await sets.getSets(firstExercise.workoutExerciseId)) {
        await sets.complete(
          set.id,
          weightGrams: const Value(105000),
          reps: const Value(5),
        );
      }
      await repo.finish(first.id);
      clock = clock.add(const Duration(days: 2));

      final second = await repo.startFromRoutineDay(dayId);
      final [secondExercise] = await repo.watchExercises(second.id).first;

      expect(secondExercise.target!.weightGrams, 105000);
      expect(
        secondExercise.target!.rationale!.outcome,
        ProgressionOutcome.manualCarryForward,
      );
    });

    test("a configured rep range survives a second start unchanged — "
        "progression owns the weight, not the range", () async {
      await makeExercise('bench', 'Bench Press');
      final routine = await routines.create(name: 'Push');
      final day = await routines.addDay(routine.id, name: 'Push');
      await routines.addExercises(day.id, ['bench']);
      final [detail] = await routines.watchExercises(day.id).first;
      await routines.setTargets(
        detail.routineExerciseId,
        targetSets: const Value(3),
        targetRepsMin: const Value(8),
        targetRepsMax: const Value(12),
        targetWeightGrams: const Value(100000),
      );
      await routines.setProgressionRule(
        detail.routineExerciseId,
        const LinearProgressionRule(
          config: LinearProgressionConfig(incrementGrams: 2500),
        ),
      );

      final first = await repo.startFromRoutineDay(day.id);
      final [firstExercise] = await repo.watchExercises(first.id).first;
      for (final set in await sets.getSets(firstExercise.workoutExerciseId)) {
        await sets.complete(
          set.id,
          weightGrams: const Value(100000),
          reps: const Value(10),
        );
      }
      await repo.finish(first.id);
      clock = clock.add(const Duration(days: 2));

      final second = await repo.startFromRoutineDay(day.id);
      final [secondExercise] = await repo.watchExercises(second.id).first;

      expect(secondExercise.target!.weightGrams, 102500);
      expect(secondExercise.target!.repsMin, 8);
      expect(secondExercise.target!.repsMax, 12);
    });
  });

  group('a full training week from routine days (Phase 2 exit criterion)', () {
    test(
      'each day starts clean, pre-filled, and finishing frees the next',
      () async {
        final routines = RoutineRepository(db, clock: () => clock);
        final sets = SetRepository(db, clock: () => clock);
        await makeExercise('bench', 'Bench Press');
        await makeExercise('row', 'Barbell Row');
        await makeExercise('squat', 'Back Squat');
        final routine = await routines.create(name: 'Push Pull Legs');

        Future<String> makeDay(String name, String exerciseId) async {
          final day = await routines.addDay(routine.id, name: name);
          await routines.addExercises(day.id, [exerciseId]);
          final [detail] = await routines.watchExercises(day.id).first;
          await routines.setTargets(
            detail.routineExerciseId,
            targetSets: const Value(3),
            targetRepsMin: const Value(6),
            targetRepsMax: const Value(10),
            targetWeightGrams: const Value(80000),
          );
          return day.id;
        }

        final pushDay = await makeDay('Push', 'bench');
        final pullDay = await makeDay('Pull', 'row');
        final legsDay = await makeDay('Legs', 'squat');

        for (final (dayId, exerciseId) in [
          (pushDay, 'bench'),
          (pullDay, 'row'),
          (legsDay, 'squat'),
        ]) {
          // Refused while yesterday's session is still open would mean the
          // week cannot actually run end to end.
          final workout = await repo.startFromRoutineDay(dayId);

          final [exercise] = await repo.watchExercises(workout.id).first;
          expect(exercise.exerciseId, exerciseId);
          expect(exercise.target!.repsMin, 6);
          expect(exercise.target!.repsMax, 10);
          expect(exercise.target!.weightGrams, 80000);
          expect(exercise.setCount, 3);

          for (final set in await sets.getSets(exercise.workoutExerciseId)) {
            await sets.complete(
              set.id,
              weightGrams: const Value(80000),
              reps: const Value(8),
            );
          }
          await repo.finish(workout.id);

          clock = clock.add(const Duration(days: 2));
        }

        final history = await repo.watchHistory().first;
        expect(history.map((w) => w.name), ['Legs', 'Pull', 'Push']);
      },
    );
  });

  group('supersets in the logger (F-LOG-015)', () {
    Future<(String, String)> makeTwoExerciseWorkout() async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('fly', 'Cable Fly');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench', 'fly']);
      final [a, b] = await repo.watchExercises(workout.id).first;
      return (a.workoutExerciseId, b.workoutExerciseId);
    }

    test('groupExercises assigns a shared group id to every member', () async {
      final (a, b) = await makeTwoExerciseWorkout();

      await repo.groupExercises([a, b]);

      final exercises = await repo
          .watchExercises((await repo.findActive())!.id)
          .first;
      expect(exercises[0].groupId, isNotNull);
      expect(exercises[0].groupId, exercises[1].groupId);
    });

    test('toggleGroupWithNext groups two ungrouped exercises', () async {
      final (a, b) = await makeTwoExerciseWorkout();

      await repo.toggleGroupWithNext(a, b);

      final exercises = await repo
          .watchExercises((await repo.findActive())!.id)
          .first;
      expect(exercises[0].groupId, isNotNull);
      expect(exercises[0].groupId, exercises[1].groupId);
    });

    test('toggleGroupWithNext breaks an existing group', () async {
      final (a, b) = await makeTwoExerciseWorkout();
      await repo.groupExercises([a, b]);

      await repo.toggleGroupWithNext(a, b);

      final exercises = await repo
          .watchExercises((await repo.findActive())!.id)
          .first;
      expect(exercises.every((e) => e.groupId == null), isTrue);
    });

    test(
      'removing a member down to a single survivor dissolves the group',
      () async {
        final (a, b) = await makeTwoExerciseWorkout();
        await repo.groupExercises([a, b]);

        await repo.removeExerciseFromWorkout(a);

        final exercises = await repo
            .watchExercises((await repo.findActive())!.id)
            .first;
        expect(exercises.single.groupId, isNull);
      },
    );
  });

  group('reordering exercises mid-session (F-LOG-010 §1)', () {
    test('persists the new order', () async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('fly', 'Cable Fly');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench', 'fly']);
      final [a, b] = await repo.watchExercises(workout.id).first;

      await repo.reorderExercises([b.workoutExerciseId, a.workoutExerciseId]);

      final reordered = await repo.watchExercises(workout.id).first;
      expect(reordered[0].workoutExerciseId, b.workoutExerciseId);
      expect(reordered[1].workoutExerciseId, a.workoutExerciseId);
    });

    test('dissolves a group a drag pulls apart', () async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('fly', 'Cable Fly');
      await makeExercise('row', 'Barbell Row');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench', 'fly', 'row']);
      final [a, b, c] = await repo.watchExercises(workout.id).first;
      await repo.groupExercises([a.workoutExerciseId, b.workoutExerciseId]);

      // Pulling the row between bench and fly breaks their adjacency.
      await repo.reorderExercises([
        a.workoutExerciseId,
        c.workoutExerciseId,
        b.workoutExerciseId,
      ]);

      final exercises = await repo.watchExercises(workout.id).first;
      expect(exercises.every((e) => e.groupId == null), isTrue);
    });
  });

  group('swapping an exercise mid-session (F-LOG-010 §2)', () {
    test('with nothing logged yet, retires the old row outright', () async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('incline', 'Incline Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final original = (await repo.watchExercises(workout.id).first).single;

      await repo.swapExercise(original.workoutExerciseId, 'incline');

      final exercises = await repo.watchExercises(workout.id).first;
      expect(exercises.single.exerciseId, 'incline');
      expect(
        exercises.single.workoutExerciseId,
        isNot(original.workoutExerciseId),
      );
    });

    test('with a completed set, leaves the original standing', () async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('incline', 'Incline Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final original = (await repo.watchExercises(workout.id).first).single;
      await completeSet(
        original.workoutExerciseId,
        weightGrams: 90000,
        reps: 5,
      );

      await repo.swapExercise(original.workoutExerciseId, 'incline');

      final exercises = await repo.watchExercises(workout.id).first;
      expect(exercises, hasLength(2));
      expect(exercises[0].exerciseId, 'bench');
      expect(exercises[0].completedSetCount, 1);
      expect(exercises[1].exerciseId, 'incline');
      expect(exercises[1].completedSetCount, 0);
    });

    test('never rewrites the original row\'s exercise_id', () async {
      await makeExercise('bench', 'Bench Press');
      await makeExercise('incline', 'Incline Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final original = (await repo.watchExercises(workout.id).first).single;
      await completeSet(
        original.workoutExerciseId,
        weightGrams: 90000,
        reps: 5,
      );

      await repo.swapExercise(original.workoutExerciseId, 'incline');

      final originalRow = await (db.select(
        db.workoutExercises,
      )..where((we) => we.id.equals(original.workoutExerciseId))).getSingle();
      expect(originalRow.exerciseId, 'bench');
    });
  });

  group('undoing an exercise removal (F-LOG-022 §3)', () {
    test('restores the exercise and the sets it cascaded', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final we = (await repo.watchExercises(workout.id).first).single;

      final tombstonedAt = await repo.removeExerciseFromWorkout(
        we.workoutExerciseId,
      );
      await repo.restoreExercise(we.workoutExerciseId, tombstonedAt);

      final exercises = await repo.watchExercises(workout.id).first;
      expect(exercises.single.workoutExerciseId, we.workoutExerciseId);
      final rawSets = await db.select(db.sets).get();
      expect(rawSets.single.deletedAt, isNull);
    });

    test('does not resurrect a set deleted before the removal', () async {
      await makeExercise('bench', 'Bench Press');
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);
      final we = (await repo.watchExercises(workout.id).first).single;
      final firstSetId =
          (await (db.select(db.sets)..where(
                    (s) => s.workoutExerciseId.equals(we.workoutExerciseId),
                  ))
                  .get())
              .single
              .id;
      await (db.update(db.sets)..where((s) => s.id.equals(firstSetId))).write(
        const SetsCompanion(deletedAt: Value(1)),
      );
      final newSetId = await SetRepository(
        db,
        clock: () => clock,
      ).addSet(we.workoutExerciseId);

      final tombstonedAt = await repo.removeExerciseFromWorkout(
        we.workoutExerciseId,
      );
      await repo.restoreExercise(we.workoutExerciseId, tombstonedAt);

      final firstSet = await (db.select(
        db.sets,
      )..where((s) => s.id.equals(firstSetId))).getSingle();
      final newSet = await (db.select(
        db.sets,
      )..where((s) => s.id.equals(newSetId))).getSingle();
      expect(firstSet.deletedAt, 1);
      expect(newSet.deletedAt, isNull);
    });
  });

  group('repeating a past session (F-LOG-016)', () {
    test(
      'carries exercises, order and derived targets, sets left empty',
      () async {
        await makeExercise('bench', 'Bench Press');
        final first = await repo.start(name: 'Push A');
        await repo.addExercises(first.id, ['bench']);
        await completeSet(
          (await repo.watchExercises(first.id).first).single.workoutExerciseId,
          weightGrams: 90000,
          reps: 5,
        );
        await repo.finish(first.id);

        clock = DateTime(2026, 8, 13);
        final second = await repo.startFromWorkout(first.id);

        expect(second.name, 'Push A');
        expect(second.id, isNot(first.id));
        final exercises = await repo.watchExercises(second.id).first;
        expect(exercises.single.exerciseId, 'bench');
        expect(exercises.single.target?.sets, 1);
        expect(exercises.single.target?.weightGrams, 90000);
        final sets = await repo
            .watchExercises(second.id)
            .first
            .then((e) => e.single);
        expect(sets.setCount, 1);
        expect(sets.completedSetCount, 0);
      },
    );

    test('refuses when a session is already in progress', () async {
      await repo.start();
      final finished = await repo.createRetroactive(
        name: 'Old one',
        startedAt: DateTime(2026, 1, 1),
        endedAt: DateTime(2026, 1, 1, 1),
      );

      expect(
        () => repo.startFromWorkout(finished.id),
        throwsA(isA<ActiveWorkoutExistsException>()),
      );
    });
  });

  group('per-side weight entry (F-LOG-017)', () {
    test('watchExercises carries the exercise\'s entry mode', () async {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'curl',
              name: 'Dumbbell Curl',
              primaryMuscle: Muscle.biceps,
              equipment: Equipment.dumbbell,
              trackingType: TrackingType.weightReps,
              weightEntryMode: const Value(WeightEntryMode.perSide),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['curl']);

      final exercise = (await repo.watchExercises(workout.id).first).single;
      expect(exercise.weightEntryMode, WeightEntryMode.perSide);
    });

    test(
      'volume counts total load regardless of entry mode (acceptance)',
      () async {
        await db
            .into(db.exercises)
            .insert(
              ExercisesCompanion.insert(
                id: 'curl',
                name: 'Dumbbell Curl',
                primaryMuscle: Muscle.biceps,
                equipment: Equipment.dumbbell,
                trackingType: TrackingType.weightReps,
                weightEntryMode: const Value(WeightEntryMode.perSide),
                createdAt: 1,
                updatedAt: 1,
              ),
            );
        final workout = await repo.start();
        await repo.addExercises(workout.id, ['curl']);
        // 20 kg per side is stored as 40 kg total — the UI layer's job, not
        // this one's — and volume must use exactly that stored total, never
        // a re-halved figure.
        await completeSet(
          (await repo.watchExercises(workout.id).first)
              .single
              .workoutExerciseId,
          weightGrams: 40000,
          reps: 10,
        );
        await repo.finish(workout.id);

        final stats = await repo.summaryStats(workout.id);
        expect(stats.totalVolumeGrams, 400000);
      },
    );
  });
}
