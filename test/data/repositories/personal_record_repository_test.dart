import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/personal_record_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/domain/analytics/personal_records.dart';

/// Batch 2.6 — PR detection and celebration (`F-LOG-013`).
void main() {
  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  late PersonalRecordRepository records;
  var clock = DateTime(2026, 8, 7, 18, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 8, 7, 18, 30);
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
    records = PersonalRecordRepository(db, clock: () => clock);
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

  /// Logs one completed set of [exerciseId] in the active session, starting
  /// one first if none is running and adding the exercise if it isn't in it
  /// yet. Returns the new set's id.
  Future<String> logSet(
    String exerciseId, {
    required int weightGrams,
    required int reps,
  }) async {
    var active = await workouts.findActive();
    active ??= await workouts.start();

    final exercises = await workouts.watchExercises(active.id).first;
    if (!exercises.any((e) => e.exerciseId == exerciseId)) {
      await workouts.addExercises(active.id, [exerciseId]);
    }
    final refreshed = await workouts.watchExercises(active.id).first;
    final we = refreshed
        .firstWhere((e) => e.exerciseId == exerciseId)
        .workoutExerciseId;

    final setId = await sets.addSet(we);
    await sets.complete(
      setId,
      weightGrams: Value(weightGrams),
      reps: Value(reps),
    );
    return setId;
  }

  /// Cached records still live — matches the filter every real read applies
  /// (ADR-0008), unlike a bare table select which would also surface
  /// tombstoned rows a demotion left behind.
  Future<List<PersonalRecord>> live() =>
      (db.select(db.personalRecords)..where((p) => p.deletedAt.isNull())).get();

  group('evaluateSet (F-LOG-013 §1)', () {
    test('the first-ever set is recorded silently, on every kind', () async {
      await makeExercise('bench');
      final setId = await logSet('bench', weightGrams: 60000, reps: 10);

      final hits = await records.evaluateSet(setId);

      expect(hits, isEmpty);
      final stored = await live();
      // maxWeight, maxRepsAtWeight, bestE1rm recorded silently; maxSessionVolume
      // is evaluated separately at session finish.
      expect(
        stored.map((r) => r.kind),
        containsAll([
          PrKind.maxWeight,
          PrKind.maxRepsAtWeight,
          PrKind.bestE1rm,
        ]),
      );
    });

    test(
      'fixture: 102.5×5 beats bestE1rm and maxRepsAtWeight but not maxWeight '
      '(docs/40-ANALYTICS-SPEC.md §4 fixture prDetection)',
      () async {
        await makeExercise('bench');
        await records.evaluateSet(
          await logSet('bench', weightGrams: 100000, reps: 5),
        );
        await workouts.finish((await workouts.findActive())!.id);
        clock = clock.add(const Duration(days: 2));
        await records.evaluateSet(
          await logSet('bench', weightGrams: 105000, reps: 3),
        );
        await workouts.finish((await workouts.findActive())!.id);
        clock = clock.add(const Duration(days: 2));

        final setId = await logSet('bench', weightGrams: 102500, reps: 5);
        final hits = await records.evaluateSet(setId);

        expect(hits.map((h) => h.kind), [
          PrDetectionKind.bestE1rm,
          PrDetectionKind.maxRepsAtWeight,
        ]);
        expect(hits[0].value, 119583);
        expect(hits[1].qualifierGrams, 102500);
      },
    );

    test('a tie is not a record', () async {
      await makeExercise('bench');
      final first = await logSet('bench', weightGrams: 100000, reps: 5);
      await records.evaluateSet(first);

      final second = await logSet('bench', weightGrams: 100000, reps: 5);
      final hits = await records.evaluateSet(second);

      expect(hits, isEmpty);
    });

    test('a warm-up set can never set a record', () async {
      await makeExercise('bench');
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, ['bench']);
      final we = (await workouts.watchExercises(workout.id).first)
          .single
          .workoutExerciseId;
      final setId = await sets.addSet(we);
      await sets.setType(setId, SetType.warmup);
      await sets.complete(
        setId,
        weightGrams: const Value(200000),
        reps: const Value(20),
      );

      final hits = await records.evaluateSet(setId);
      expect(hits, isEmpty);
    });

    test('deleting a PR set and rebuilding demotes to the next best '
        '(acceptance: deleting a PR set correctly demotes)', () async {
      await makeExercise('bench');
      final first = await logSet('bench', weightGrams: 100000, reps: 5);
      await records.evaluateSet(first);
      await workouts.finish((await workouts.findActive())!.id);
      clock = clock.add(const Duration(days: 2));

      final second = await logSet('bench', weightGrams: 110000, reps: 5);
      await records.evaluateSet(second);

      var stored = await live();
      expect(
        stored.where((r) => r.kind == PrKind.maxWeight).single.value,
        110000,
      );

      await sets.deleteSet(second);
      await records.rebuildForExercise('bench');

      stored = await live();
      final maxWeight = stored.where((r) => r.kind == PrKind.maxWeight).single;
      expect(maxWeight.value, 100000);
      expect(maxWeight.setId, first);
    });
  });

  group('evaluateSessionVolume', () {
    test('records the session total once final, not partial sums', () async {
      await makeExercise('bench');
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, ['bench']);
      final we = (await workouts.watchExercises(workout.id).first)
          .single
          .workoutExerciseId;

      final s1 = await sets.addSet(we);
      await sets.complete(
        s1,
        weightGrams: const Value(100000),
        reps: const Value(5),
      );
      await records.evaluateSet(s1);
      final s2 = await sets.addSet(we);
      await sets.complete(
        s2,
        weightGrams: const Value(100000),
        reps: const Value(5),
      );
      await records.evaluateSet(s2);

      // Nothing recorded yet — live evaluation never touches volume.
      var stored = await live();
      expect(stored.where((r) => r.kind == PrKind.maxSessionVolume), isEmpty);

      await records.evaluateSessionVolume(workout.id);

      stored = await live();
      final volume = stored
          .where((r) => r.kind == PrKind.maxSessionVolume)
          .single;
      expect(volume.value, 1000000); // (100kg×5 + 100kg×5) in grams
      expect(volume.setId, isNull);
    });

    test(
      'is idempotent — calling twice does not duplicate the record',
      () async {
        await makeExercise('bench');
        final workout = await workouts.start();
        await workouts.addExercises(workout.id, ['bench']);
        final we = (await workouts.watchExercises(workout.id).first)
            .single
            .workoutExerciseId;
        final s1 = await sets.addSet(we);
        await sets.complete(
          s1,
          weightGrams: const Value(100000),
          reps: const Value(5),
        );

        await records.evaluateSessionVolume(workout.id);
        await records.evaluateSessionVolume(workout.id);

        final stored = await live();
        expect(
          stored.where((r) => r.kind == PrKind.maxSessionVolume),
          hasLength(1),
        );
      },
    );
  });

  group('rebuildAll', () {
    test('recomputes every exercise with counted sets', () async {
      await makeExercise('bench');
      await makeExercise('squat');
      await logSet('bench', weightGrams: 100000, reps: 5);
      final workout = (await workouts.findActive())!;
      await workouts.addExercises(workout.id, ['squat']);
      final squatWe = (await workouts.watchExercises(workout.id).first)
          .firstWhere((e) => e.exerciseId == 'squat')
          .workoutExerciseId;
      final squatSet = await sets.addSet(squatWe);
      await sets.complete(
        squatSet,
        weightGrams: const Value(140000),
        reps: const Value(3),
      );

      await records.rebuildAll();

      final stored = await live();
      expect(stored.map((r) => r.exerciseId).toSet(), {'bench', 'squat'});
    });
  });

  group('watchTimeline (F-ANA-007)', () {
    test('newest first, with the exercise name', () async {
      await makeExercise('bench');

      clock = DateTime(2026, 8, 1);
      final firstSet = await logSet('bench', weightGrams: 100000, reps: 5);
      await records.evaluateSet(firstSet);

      clock = DateTime(2026, 8, 5);
      final secondSet = await logSet('bench', weightGrams: 105000, reps: 5);
      await records.evaluateSet(secondSet);

      final timeline = await records.watchTimeline().first;

      expect(timeline, isNotEmpty);
      expect(timeline.first.exerciseName, 'bench');
      // Newest achievement first.
      for (var i = 1; i < timeline.length; i++) {
        expect(
          timeline[i - 1].achievedAt,
          greaterThanOrEqualTo(timeline[i].achievedAt),
        );
      }
    });

    test('a deleted exercise is excluded', () async {
      await makeExercise('bench');
      final setId = await logSet('bench', weightGrams: 100000, reps: 5);
      await records.evaluateSet(setId);

      await (db.update(db.exercises)..where((e) => e.id.equals('bench'))).write(
        ExercisesCompanion(deletedAt: Value(clock.millisecondsSinceEpoch)),
      );

      expect(await records.watchTimeline().first, isEmpty);
    });
  });
}
