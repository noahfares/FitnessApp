import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';

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
}
