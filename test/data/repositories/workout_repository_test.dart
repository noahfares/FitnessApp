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
      expect(
        workout.startedAtTzOffsetMinutes,
        clock.timeZoneOffset.inMinutes,
      );
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
}
