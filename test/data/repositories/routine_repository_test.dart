import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';

/// `F-ROU-001`, `F-ROU-002`, `F-ROU-003`.
void main() {
  late AppDatabase db;
  late RoutineRepository repo;
  var clock = DateTime(2026, 8, 6, 18, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 8, 6, 18, 30);
    repo = RoutineRepository(db, clock: () => clock);
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

  group('routine CRUD (F-ROU-001)', () {
    test('create appends after existing routines by position', () async {
      final first = await repo.create(name: 'Push Pull Legs');
      final second = await repo.create(name: 'Upper Lower');
      expect(first.position, 0);
      expect(second.position, 1);
    });

    test('rename and setNotes trim and stamp updatedAt', () async {
      final routine = await repo.create(name: 'Original');
      clock = clock.add(const Duration(minutes: 5));
      await repo.rename(routine.id, '  Renamed  ');
      await repo.setNotes(routine.id, '  block 1  ');

      final updated = await repo.findById(routine.id);
      expect(updated!.name, 'Renamed');
      expect(updated.notes, 'block 1');
      expect(updated.updatedAt, clock.millisecondsSinceEpoch);
    });

    test(
        'archiving hides from watchAll by default but not with '
        'includeArchived', () async {
      final routine = await repo.create(name: 'Old block');
      await repo.setArchived(routine.id, isArchived: true);

      expect(await repo.watchAll().first, isEmpty);
      final withArchived = await repo.watchAll(includeArchived: true).first;
      expect(withArchived.map((r) => r.id), contains(routine.id));
    });

    test('deleting a routine tombstones it and its days and exercises',
        () async {
      final exerciseId = await makeExercise('ex1', 'Bench Press');
      final routine = await repo.create(name: 'PPL');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.addExercises(day.id, [exerciseId]);

      await repo.delete(routine.id);

      expect(await repo.findById(routine.id), isNull);
      expect(await repo.watchDays(routine.id).first, isEmpty);
      expect(await repo.watchExercises(day.id).first, isEmpty);
    });

    test('duplicate produces a fully independent copy of days and targets',
        () async {
      final exerciseId = await makeExercise('ex1', 'Bench Press');
      final routine = await repo.create(name: 'PPL');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.addExercises(day.id, [exerciseId]);
      final [original] = await repo.watchExercises(day.id).first;
      await repo.setTargets(
        original.routineExerciseId,
        targetSets: const Value(3),
        targetRepsMin: const Value(8),
        targetRepsMax: const Value(12),
      );

      final copy = await repo.duplicate(routine.id);
      final copyDays = await repo.watchDays(copy.id).first;
      expect(copyDays, hasLength(1));
      expect(copyDays.single.id, isNot(day.id));

      final copyExercises =
          await repo.watchExercises(copyDays.single.id).first;
      expect(copyExercises, hasLength(1));
      expect(
        copyExercises.single.routineExerciseId,
        isNot(original.routineExerciseId),
      );
      expect(copyExercises.single.targetSets, 3);
      expect(copyExercises.single.targetRepsMax, 12);

      // Editing the copy must never touch the original (`F-ROU-001` §2).
      await repo.setTargets(
        copyExercises.single.routineExerciseId,
        targetSets: const Value(5),
      );
      final originalAfter = await repo.watchExercises(day.id).first;
      expect(originalAfter.single.targetSets, 3);
    });
  });

  group('creating a routine from a past workout (F-ROU-001 §3)', () {
    test("logged working sets become the day's starting targets", () async {
      final exerciseId = await makeExercise('bench', 'Bench Press');
      final workouts = WorkoutRepository(db, clock: () => clock);
      final workout = await workouts.start(name: 'Push A');
      await workouts.addExercises(workout.id, [exerciseId]);
      final [we] = await workouts.watchExercises(workout.id).first;

      Future<void> logSet({required int position, required int reps}) =>
          db
              .into(db.sets)
              .insert(
                SetsCompanion.insert(
                  id: 'set-$position',
                  workoutExerciseId: we.workoutExerciseId,
                  position: position,
                  weightGrams: const Value(100000),
                  reps: Value(reps),
                  isCompleted: const Value(true),
                  createdAt: 1,
                  updatedAt: 1,
                ),
              );
      await logSet(position: 0, reps: 6);
      await logSet(position: 1, reps: 8);
      await logSet(position: 2, reps: 10);
      await workouts.finish(workout.id);

      final routine = await repo.createFromWorkout(
        workout.id,
        name: 'Push day',
      );

      expect(routine.name, 'Push day');
      final days = await repo.watchDays(routine.id).first;
      expect(days, hasLength(1));
      final [detail] = await repo.watchExercises(days.single.id).first;
      expect(detail.exerciseName, 'Bench Press');
      expect(detail.targetSets, 3);
      expect(detail.targetRepsMin, 6);
      expect(detail.targetRepsMax, 10);
      expect(detail.targetWeightGrams, 100000);
    });
  });

  group('routine days (F-ROU-002)', () {
    test('a three-day PPL routine is creatable and independently ordered',
        () async {
      final routine = await repo.create(name: 'PPL');
      await repo.addDay(routine.id, name: 'Push');
      await repo.addDay(routine.id, name: 'Pull');
      await repo.addDay(routine.id, name: 'Legs');

      final days = await repo.watchDays(routine.id).first;
      expect(days.map((d) => d.name), ['Push', 'Pull', 'Legs']);
      expect(days.map((d) => d.position), [0, 1, 2]);
    });

    test('reorderDays persists the new order', () async {
      final routine = await repo.create(name: 'PPL');
      final push = await repo.addDay(routine.id, name: 'Push');
      final pull = await repo.addDay(routine.id, name: 'Pull');

      await repo.reorderDays([pull.id, push.id]);

      final days = await repo.watchDays(routine.id).first;
      expect(days.map((d) => d.name), ['Pull', 'Push']);
    });

    test('deleting a day tombstones its exercises too', () async {
      final exerciseId = await makeExercise('ex1', 'Squat');
      final routine = await repo.create(name: 'PPL');
      final day = await repo.addDay(routine.id, name: 'Legs');
      await repo.addExercises(day.id, [exerciseId]);

      await repo.deleteDay(day.id);

      expect(await repo.findDayById(day.id), isNull);
      expect(await repo.watchExercises(day.id).first, isEmpty);
    });
  });

  group('exercise targets (F-ROU-003)', () {
    test('targets are optional — an exercise with none is valid', () async {
      final exerciseId = await makeExercise('ex1', 'Row');
      final routine = await repo.create(name: 'Pull day');
      final day = await repo.addDay(routine.id, name: 'Pull');
      await repo.addExercises(day.id, [exerciseId]);

      final [detail] = await repo.watchExercises(day.id).first;
      expect(detail.targetSets, isNull);
      expect(detail.targetRepsMin, isNull);
    });

    test('setTargets writes a rep range, weight, RPE and rest', () async {
      final exerciseId = await makeExercise('ex1', 'Squat');
      final routine = await repo.create(name: 'Leg day');
      final day = await repo.addDay(routine.id, name: 'Legs');
      await repo.addExercises(day.id, [exerciseId]);
      final [detail] = await repo.watchExercises(day.id).first;

      await repo.setTargets(
        detail.routineExerciseId,
        targetSets: const Value(4),
        targetRepsMin: const Value(6),
        targetRepsMax: const Value(10),
        targetWeightGrams: const Value(100000),
        targetRpe: const Value(8),
        restSeconds: const Value(180),
      );

      final [updated] = await repo.watchExercises(day.id).first;
      expect(updated.targetSets, 4);
      expect(updated.targetRepsMin, 6);
      expect(updated.targetRepsMax, 10);
      expect(updated.targetWeightGrams, 100000);
      expect(updated.targetRpe, 8);
      expect(updated.restSeconds, 180);
    });

    test('reorderExercises persists new positions', () async {
      final a = await makeExercise('a', 'A');
      final b = await makeExercise('b', 'B');
      final routine = await repo.create(name: 'Day');
      final day = await repo.addDay(routine.id, name: 'Day 1');
      await repo.addExercises(day.id, [a, b]);
      final before = await repo.watchExercises(day.id).first;

      await repo.reorderExercises([
        before[1].routineExerciseId,
        before[0].routineExerciseId,
      ]);

      final after = await repo.watchExercises(day.id).first;
      expect(after.map((e) => e.exerciseName), ['B', 'A']);
    });

    test('removeExercise tombstones without touching siblings', () async {
      final a = await makeExercise('a', 'A');
      final b = await makeExercise('b', 'B');
      final routine = await repo.create(name: 'Day');
      final day = await repo.addDay(routine.id, name: 'Day 1');
      await repo.addExercises(day.id, [a, b]);
      final before = await repo.watchExercises(day.id).first;

      await repo.removeExercise(before.first.routineExerciseId);

      final after = await repo.watchExercises(day.id).first;
      expect(after, hasLength(1));
      expect(after.single.exerciseName, 'B');
    });
  });
}
