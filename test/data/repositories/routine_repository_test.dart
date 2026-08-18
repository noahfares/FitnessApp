import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/domain/progression/progression_rule.dart';
import 'package:fitness_app/domain/routines/starter_programs.dart';

/// `F-ROU-001`, `F-ROU-002`, `F-ROU-003`, `F-ROU-004`, `F-ROU-007`,
/// `F-ROU-008`, `F-ROU-009`.
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

    test('archiving hides from watchAll by default but not with '
        'includeArchived', () async {
      final routine = await repo.create(name: 'Old block');
      await repo.setArchived(routine.id, isArchived: true);

      expect(await repo.watchAll().first, isEmpty);
      final withArchived = await repo.watchAll(includeArchived: true).first;
      expect(withArchived.map((r) => r.id), contains(routine.id));
    });

    test(
      'deleting a routine tombstones it and its days and exercises',
      () async {
        final exerciseId = await makeExercise('ex1', 'Bench Press');
        final routine = await repo.create(name: 'PPL');
        final day = await repo.addDay(routine.id, name: 'Push');
        await repo.addExercises(day.id, [exerciseId]);

        await repo.delete(routine.id);

        expect(await repo.findById(routine.id), isNull);
        expect(await repo.watchDays(routine.id).first, isEmpty);
        expect(await repo.watchExercises(day.id).first, isEmpty);
      },
    );

    test(
      'duplicate produces a fully independent copy of days and targets',
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

        final copyExercises = await repo
            .watchExercises(copyDays.single.id)
            .first;
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
      },
    );

    test('duplicate carries the progression rule to the copy', () async {
      final exerciseId = await makeExercise('ex1', 'Bench Press');
      final routine = await repo.create(name: 'PPL');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.addExercises(day.id, [exerciseId]);
      final [original] = await repo.watchExercises(day.id).first;
      await repo.setProgressionRule(
        original.routineExerciseId,
        const LinearProgressionRule(
          config: LinearProgressionConfig(incrementGrams: 2500),
        ),
      );

      final copy = await repo.duplicate(routine.id);
      final [copyDay] = await repo.watchDays(copy.id).first;
      final [copyExercise] = await repo.watchExercises(copyDay.id).first;

      expect(copyExercise.progressionRule, isA<LinearProgressionRule>());
    });
  });

  group('progression rule assignment (F-PRG-007)', () {
    test('a routine exercise defaults to manual carry-forward', () async {
      final exerciseId = await makeExercise('ex1', 'Bench Press');
      final routine = await repo.create(name: 'PPL');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.addExercises(day.id, [exerciseId]);

      final [exercise] = await repo.watchExercises(day.id).first;
      expect(exercise.progressionRule, isA<ManualCarryForwardRule>());
    });

    test('assigning a linear rule persists its config', () async {
      final exerciseId = await makeExercise('ex1', 'Bench Press');
      final routine = await repo.create(name: 'PPL');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.addExercises(day.id, [exerciseId]);
      final [exercise] = await repo.watchExercises(day.id).first;

      await repo.setProgressionRule(
        exercise.routineExerciseId,
        const LinearProgressionRule(
          config: LinearProgressionConfig(
            incrementGrams: 5000,
            failureThreshold: 2,
            deloadFraction: 0.15,
          ),
        ),
      );

      final [updated] = await repo.watchExercises(day.id).first;
      final rule = updated.progressionRule as LinearProgressionRule;
      expect(rule.config.incrementGrams, 5000);
      expect(rule.config.failureThreshold, 2);
      expect(rule.config.deloadFraction, 0.15);
    });

    test('clearing the rule reverts to manual carry-forward', () async {
      final exerciseId = await makeExercise('ex1', 'Bench Press');
      final routine = await repo.create(name: 'PPL');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.addExercises(day.id, [exerciseId]);
      final [exercise] = await repo.watchExercises(day.id).first;
      await repo.setProgressionRule(
        exercise.routineExerciseId,
        const LinearProgressionRule(
          config: LinearProgressionConfig(incrementGrams: 2500),
        ),
      );

      await repo.setProgressionRule(exercise.routineExerciseId, null);

      final [cleared] = await repo.watchExercises(day.id).first;
      expect(cleared.progressionRule, isA<ManualCarryForwardRule>());
    });
  });

  group('creating a routine from a past workout (F-ROU-001 §3)', () {
    test("logged working sets become the day's starting targets", () async {
      final exerciseId = await makeExercise('bench', 'Bench Press');
      final workouts = WorkoutRepository(db, clock: () => clock);
      final workout = await workouts.start(name: 'Push A');
      await workouts.addExercises(workout.id, [exerciseId]);
      final [we] = await workouts.watchExercises(workout.id).first;

      Future<void> logSet({required int position, required int reps}) => db
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
    test(
      'a three-day PPL routine is creatable and independently ordered',
      () async {
        final routine = await repo.create(name: 'PPL');
        await repo.addDay(routine.id, name: 'Push');
        await repo.addDay(routine.id, name: 'Pull');
        await repo.addDay(routine.id, name: 'Legs');

        final days = await repo.watchDays(routine.id).first;
        expect(days.map((d) => d.name), ['Push', 'Pull', 'Legs']);
        expect(days.map((d) => d.position), [0, 1, 2]);
      },
    );

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

  group('folders (F-ROU-007)', () {
    test('a routine can be moved into and out of a folder', () async {
      final folder = await repo.createFolder('Current block');
      final routine = await repo.create(name: 'PPL');

      await repo.setFolder(routine.id, folder.id);
      expect((await repo.findById(routine.id))!.folderId, folder.id);

      await repo.setFolder(routine.id, null);
      expect((await repo.findById(routine.id))!.folderId, isNull);
    });

    test(
      'deleting a folder moves its routines to no folder, not orphaned',
      () async {
        final folder = await repo.createFolder('Old block');
        final routine = await repo.create(name: 'PPL');
        await repo.setFolder(routine.id, folder.id);

        await repo.deleteFolder(folder.id);

        expect(await repo.watchFolders().first, isEmpty);
        expect((await repo.findById(routine.id))!.folderId, isNull);
      },
    );

    test('folders order by position', () async {
      await repo.createFolder('First');
      await repo.createFolder('Second');

      final folders = await repo.watchFolders().first;
      expect(folders.map((f) => f.name), ['First', 'Second']);
    });
  });

  group('archiving (F-ROU-008, F-ROU-009)', () {
    test('duplicating names the copy distinguishably', () async {
      final routine = await repo.create(name: 'PPL');
      final copy = await repo.duplicate(routine.id);
      expect(copy.name, isNot(routine.name));
      expect(copy.name, contains(routine.name));
    });

    test('an archived routine stays fully startable, just hidden from the '
        'main list', () async {
      final exerciseId = await makeExercise('sq', 'Squat');
      final routine = await repo.create(name: 'Legs');
      final day = await repo.addDay(routine.id, name: 'Day 1');
      await repo.addExercises(day.id, [exerciseId]);

      await repo.setArchived(routine.id, isArchived: true);

      expect(await repo.watchAll().first, isEmpty);
      final withArchived = await repo.watchAll(includeArchived: true).first;
      expect(withArchived.single.id, routine.id);
      // Everything needed to start from this day is still there.
      expect(await repo.watchDays(routine.id).first, hasLength(1));
      expect(await repo.watchExercises(day.id).first, hasLength(1));

      await repo.setArchived(routine.id, isArchived: false);
      expect(await repo.watchAll().first, hasLength(1));
    });
  });

  group('supersets (F-ROU-005)', () {
    test('groupExercises assigns a shared group id to every member', () async {
      final bench = await makeExercise('bench', 'Bench Press');
      final fly = await makeExercise('fly', 'Cable Fly');
      final routine = await repo.create(name: 'Push');
      final day = await repo.addDay(routine.id, name: 'Day 1');
      await repo.addExercises(day.id, [bench, fly]);
      final rows = await repo.watchExercises(day.id).first;

      await repo.groupExercises([
        for (final row in rows) row.routineExerciseId,
      ]);

      final grouped = await repo.watchExercises(day.id).first;
      expect(grouped[0].groupId, isNotNull);
      expect(grouped[0].groupId, grouped[1].groupId);
    });

    test('ungroupExercises clears group id for every member', () async {
      final bench = await makeExercise('bench', 'Bench Press');
      final fly = await makeExercise('fly', 'Cable Fly');
      final routine = await repo.create(name: 'Push');
      final day = await repo.addDay(routine.id, name: 'Day 1');
      await repo.addExercises(day.id, [bench, fly]);
      final rows = await repo.watchExercises(day.id).first;
      await repo.groupExercises([
        for (final row in rows) row.routineExerciseId,
      ]);
      final groupId = (await repo.watchExercises(day.id).first).first.groupId;

      await repo.ungroupExercises(groupId!);

      final ungrouped = await repo.watchExercises(day.id).first;
      expect(ungrouped.every((row) => row.groupId == null), isTrue);
    });

    test(
      'removing a member down to a single survivor dissolves the group',
      () async {
        final bench = await makeExercise('bench', 'Bench Press');
        final fly = await makeExercise('fly', 'Cable Fly');
        final routine = await repo.create(name: 'Push');
        final day = await repo.addDay(routine.id, name: 'Day 1');
        await repo.addExercises(day.id, [bench, fly]);
        final rows = await repo.watchExercises(day.id).first;
        await repo.groupExercises([
          for (final row in rows) row.routineExerciseId,
        ]);

        await repo.removeExercise(rows[0].routineExerciseId);

        final remaining = await repo.watchExercises(day.id).first;
        expect(remaining.single.groupId, isNull);
      },
    );

    test('duplicating a day gives its superset a fresh group id', () async {
      final bench = await makeExercise('bench', 'Bench Press');
      final fly = await makeExercise('fly', 'Cable Fly');
      final routine = await repo.create(name: 'Push');
      final day = await repo.addDay(routine.id, name: 'Day 1');
      await repo.addExercises(day.id, [bench, fly]);
      final rows = await repo.watchExercises(day.id).first;
      await repo.groupExercises([
        for (final row in rows) row.routineExerciseId,
      ]);
      final originalGroupId =
          (await repo.watchExercises(day.id).first).first.groupId;

      final copy = await repo.duplicate(routine.id);
      final copyDay = (await repo.watchDays(copy.id).first).first;
      final copiedRows = await repo.watchExercises(copyDay.id).first;

      expect(copiedRows[0].groupId, isNotNull);
      expect(copiedRows[0].groupId, copiedRows[1].groupId);
      expect(copiedRows[0].groupId, isNot(originalGroupId));
    });

    test('dragging a member out of a superset dissolves the group', () async {
      final bench = await makeExercise('bench', 'Bench Press');
      final fly = await makeExercise('fly', 'Cable Fly');
      final row = await makeExercise('row', 'Cable Row');
      final routine = await repo.create(name: 'Push');
      final day = await repo.addDay(routine.id, name: 'Day 1');
      await repo.addExercises(day.id, [bench, fly, row]);
      final rows = await repo.watchExercises(day.id).first;
      // Group the first two (bench, fly); leave "row" standalone.
      await repo.groupExercises([
        rows[0].routineExerciseId,
        rows[1].routineExerciseId,
      ]);
      final grouped = await repo.watchExercises(day.id).first;
      expect(grouped.where((r) => r.groupId != null), hasLength(2));

      // Drag "row" between the two grouped members — the group is no
      // longer contiguous.
      await repo.reorderExercises([
        rows[0].routineExerciseId,
        rows[2].routineExerciseId,
        rows[1].routineExerciseId,
      ]);

      final after = await repo.watchExercises(day.id).first;
      expect(after.every((r) => r.groupId == null), isTrue);
    });
  });

  group('scheduling (F-ROU-012)', () {
    test('setScheduledWeekdays persists ISO weekdays', () async {
      final routine = await repo.create(name: 'Push Pull Legs');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.setScheduledWeekdays(day.id, [1, 3, 5]);

      final updated = await repo.findDayById(day.id);
      expect(updated!.scheduledWeekdays, [1, 3, 5]);
    });

    test(
      'watchDaysForWeekday returns only days scheduled for that day',
      () async {
        final routine = await repo.create(name: 'Push Pull Legs');
        final push = await repo.addDay(routine.id, name: 'Push');
        final pull = await repo.addDay(routine.id, name: 'Pull');
        await repo.setScheduledWeekdays(push.id, [1, 4]);
        await repo.setScheduledWeekdays(pull.id, [2, 5]);

        final monday = await repo.watchDaysForWeekday(1).first;
        expect(monday, hasLength(1));
        expect(monday.single.dayName, 'Push');

        final wednesday = await repo.watchDaysForWeekday(3).first;
        expect(wednesday, isEmpty);
      },
    );

    test('an archived routine\'s scheduled days are excluded', () async {
      final routine = await repo.create(name: 'Push Pull Legs');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.setScheduledWeekdays(day.id, [1]);
      await repo.setArchived(routine.id, isArchived: true);

      expect(await repo.watchDaysForWeekday(1).first, isEmpty);
    });

    test('a deleted day is excluded even if still "scheduled"', () async {
      final routine = await repo.create(name: 'Push Pull Legs');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.setScheduledWeekdays(day.id, [1]);
      await repo.deleteDay(day.id);

      expect(await repo.watchDaysForWeekday(1).first, isEmpty);
    });

    test('duplicate carries the source day\'s schedule over', () async {
      final routine = await repo.create(name: 'Push Pull Legs');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.setScheduledWeekdays(day.id, [1, 4]);

      final copy = await repo.duplicate(routine.id);
      final copiedDays = await repo.watchDays(copy.id).first;
      expect(copiedDays.single.scheduledWeekdays, [1, 4]);
    });
  });

  group('importStarterProgram (F-ROU-015)', () {
    Future<void> makeExternalExercise(String externalId, String name) async {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'ex-$externalId',
              externalId: Value(externalId),
              name: name,
              primaryMuscle: Muscle.chest,
              equipment: Equipment.barbell,
              trackingType: TrackingType.weightReps,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
    }

    test(
      'imports days, exercises and targets, resolving by externalId',
      () async {
        await makeExternalExercise('barbell-bench-press', 'Bench Press');
        await makeExternalExercise('overhead-press', 'Overhead Press');

        const program = StarterProgram(
          id: 'test-program',
          name: 'Test Program',
          summary: 'summary',
          attribution: 'Structure by Someone',
          attributionUrl: 'https://example.com',
          days: [
            StarterProgramDay(
              name: 'Day 1',
              loadingNotes: 'notes',
              exercises: [
                StarterProgramExercise(
                  exerciseExternalId: 'barbell-bench-press',
                  targetSets: 3,
                  targetRepsMin: 5,
                  targetRepsMax: 5,
                ),
                StarterProgramExercise(exerciseExternalId: 'overhead-press'),
              ],
            ),
          ],
        );

        final result = await repo.importStarterProgram(program);

        expect(result.skippedExternalIds, isEmpty);
        final routine = await repo.findById(result.routineId);
        expect(routine!.name, 'Test Program');
        expect(routine.notes, 'Structure by Someone');

        final days = await repo.watchDays(result.routineId).first;
        expect(days.single.name, 'Day 1');
        expect(days.single.notes, 'notes');

        final exercises = await repo.watchExercises(days.single.id).first;
        expect(exercises.map((e) => e.exerciseName), [
          'Bench Press',
          'Overhead Press',
        ]);
        expect(exercises.first.targetSets, 3);
        expect(exercises.first.targetRepsMin, 5);
      },
    );

    test(
      'skips and reports an exercise the catalogue has no row for',
      () async {
        await makeExternalExercise('barbell-bench-press', 'Bench Press');

        const program = StarterProgram(
          id: 'test-program',
          name: 'Test Program',
          summary: 'summary',
          attribution: 'Structure by Someone',
          attributionUrl: 'https://example.com',
          days: [
            StarterProgramDay(
              name: 'Day 1',
              exercises: [
                StarterProgramExercise(
                  exerciseExternalId: 'barbell-bench-press',
                ),
                StarterProgramExercise(exerciseExternalId: 'does-not-exist'),
              ],
            ),
          ],
        );

        final result = await repo.importStarterProgram(program);

        expect(result.skippedExternalIds, ['does-not-exist']);
        final days = await repo.watchDays(result.routineId).first;
        final exercises = await repo.watchExercises(days.single.id).first;
        expect(exercises, hasLength(1));
        expect(exercises.single.exerciseName, 'Bench Press');
      },
    );

    test('groups exercises sharing a groupKey into one superset', () async {
      await makeExternalExercise('barbell-bench-press', 'Bench Press');
      await makeExternalExercise('overhead-press', 'Overhead Press');

      const program = StarterProgram(
        id: 'test-program',
        name: 'Test Program',
        summary: 'summary',
        attribution: 'Structure by Someone',
        attributionUrl: 'https://example.com',
        days: [
          StarterProgramDay(
            name: 'Day 1',
            exercises: [
              StarterProgramExercise(
                exerciseExternalId: 'barbell-bench-press',
                groupKey: 'a',
              ),
              StarterProgramExercise(
                exerciseExternalId: 'overhead-press',
                groupKey: 'a',
              ),
            ],
          ),
        ],
      );

      final result = await repo.importStarterProgram(program);
      final days = await repo.watchDays(result.routineId).first;
      final exercises = await repo.watchExercises(days.single.id).first;

      expect(exercises[0].groupId, isNotNull);
      expect(exercises[0].groupId, exercises[1].groupId);
    });

    test('importing twice never links the two routines together', () async {
      await makeExternalExercise('barbell-bench-press', 'Bench Press');

      const program = StarterProgram(
        id: 'test-program',
        name: 'Test Program',
        summary: 'summary',
        attribution: 'Structure by Someone',
        attributionUrl: 'https://example.com',
        days: [
          StarterProgramDay(
            name: 'Day 1',
            exercises: [
              StarterProgramExercise(exerciseExternalId: 'barbell-bench-press'),
            ],
          ),
        ],
      );

      final first = await repo.importStarterProgram(program);
      final second = await repo.importStarterProgram(program);

      expect(first.routineId, isNot(second.routineId));
      await repo.delete(first.routineId);
      expect(await repo.findById(second.routineId), isNotNull);
    });
  });

  group('rolling rotation (F-ROU-012)', () {
    test('proposes the day after whichever was last trained', () async {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'bench',
              name: 'Bench',
              primaryMuscle: Muscle.chest,
              equipment: Equipment.barbell,
              trackingType: TrackingType.weightReps,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      final routine = await repo.create(name: 'A/B');
      final a = await repo.addDay(routine.id, name: 'A');
      final b = await repo.addDay(routine.id, name: 'B');
      await repo.addExercises(a.id, ['bench']);
      await repo.addExercises(b.id, ['bench']);

      // Nothing trained yet: the rotation starts at the first day.
      expect((await repo.watchRotationDays().first).single.dayName, 'A');

      final workouts = WorkoutRepository(db);
      final first = await workouts.startFromRoutineDay(a.id);
      await workouts.finish(first.id);

      expect((await repo.watchRotationDays().first).single.dayName, 'B');

      final second = await workouts.startFromRoutineDay(b.id);
      await workouts.finish(second.id);

      // And it wraps.
      expect((await repo.watchRotationDays().first).single.dayName, 'A');
    });

    test('a routine on fixed weekdays is left to the calendar', () async {
      final routine = await repo.create(name: 'PPL');
      final day = await repo.addDay(routine.id, name: 'Push');
      await repo.setScheduledWeekdays(day.id, const [1]);

      // Two "next" cards for one routine would be two different answers to
      // the same question.
      expect(await repo.watchRotationDays().first, isEmpty);
    });
  });
}
