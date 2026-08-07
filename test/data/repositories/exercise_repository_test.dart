import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/exercise_repository.dart';

void main() {
  late AppDatabase db;
  late ExerciseRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ExerciseRepository(
      db,
      clock: () => DateTime.fromMillisecondsSinceEpoch(5000),
    );
  });
  tearDown(() => db.close());

  Future<Exercise> makeCustom({String id = 'ex-1', String name = 'My Lift'}) =>
      repo.createCustom(
        id: id,
        name: name,
        primaryMuscle: Muscle.chest,
        equipment: Equipment.machine,
        trackingType: TrackingType.weightReps,
      );

  group('custom exercises (F-CAT-003)', () {
    test('are created and immediately usable', () async {
      final created = await makeCustom();

      expect(created.name, 'My Lift');
      expect(created.isCustom, isTrue);
      expect(created.externalId, isNull);
      // Never seeded, so re-seeding can never touch it.
      expect(created.seedUpdatedAt, isNull);
      expect(await repo.getAll(), hasLength(1));
    });

    test('names are trimmed but duplicates are allowed', () async {
      // "Bench Press (Smith)" is legitimate — a duplicate warns, never blocks.
      await makeCustom(id: 'a', name: '  Bench Press  ');
      expect((await repo.findById('a'))!.name, 'Bench Press');

      await makeCustom(id: 'b', name: 'Bench Press');
      expect(await repo.getAll(), hasLength(2));
      expect(await repo.nameExists('bench press'), isTrue);
      expect(await repo.nameExists('Bench Press', excludingId: 'a'), isTrue);
      expect(await repo.nameExists('Squat'), isFalse);
    });
  });

  group('weight entry mode (F-LOG-017 §2)', () {
    test('defaults per equipment when not given', () async {
      final dumbbell = await repo.createCustom(
        id: 'db',
        name: 'DB Curl',
        primaryMuscle: Muscle.biceps,
        equipment: Equipment.dumbbell,
        trackingType: TrackingType.weightReps,
      );
      final barbell = await repo.createCustom(
        id: 'bb',
        name: 'BB Curl',
        primaryMuscle: Muscle.biceps,
        equipment: Equipment.barbell,
        trackingType: TrackingType.weightReps,
      );

      expect(dumbbell.weightEntryMode, WeightEntryMode.perSide);
      expect(barbell.weightEntryMode, WeightEntryMode.total);
    });

    test('an explicit mode overrides the equipment default', () async {
      final created = await repo.createCustom(
        id: 'db',
        name: 'DB Curl',
        primaryMuscle: Muscle.biceps,
        equipment: Equipment.dumbbell,
        trackingType: TrackingType.weightReps,
        weightEntryMode: WeightEntryMode.total,
      );

      expect(created.weightEntryMode, WeightEntryMode.total);
    });
  });

  group('soft delete is enforced by the repository', () {
    test('deleted rows vanish from reads but survive in the table', () async {
      await makeCustom();
      await repo.delete('ex-1');

      expect(await repo.getAll(), isEmpty);
      expect(await repo.findById('ex-1'), isNull);

      // Still physically present — that is what makes restore trivial.
      final raw = await db.select(db.exercises).get();
      expect(raw, hasLength(1));
      expect(raw.single.deletedAt, isNotNull);
    });

    test('restore brings it back intact', () async {
      await makeCustom();
      await repo.delete('ex-1');
      await repo.restore('ex-1');

      final row = await repo.findById('ex-1');
      expect(row, isNotNull);
      expect(row!.name, 'My Lift');
    });
  });

  group('archive is separate from delete', () {
    test('archived rows leave pickers but stay reachable', () async {
      await makeCustom();
      await repo.setArchived('ex-1', isArchived: true);

      expect(await repo.getAll(), isEmpty);
      expect(await repo.getAll(includeArchived: true), hasLength(1));
      // Not a tombstone — findById still resolves it for history rendering.
      expect(await repo.findById('ex-1'), isNotNull);
    });
  });

  group('every write stamps updated_at', () {
    test('so seeding can tell the row was edited', () async {
      await makeCustom();
      final before = (await repo.findById('ex-1'))!.updatedAt;

      repo = ExerciseRepository(
        db,
        clock: () => DateTime.fromMillisecondsSinceEpoch(9000),
      );
      await repo.setNotes('ex-1', 'seat height 4');

      final after = (await repo.findById('ex-1'))!;
      expect(after.notes, 'seat height 4');
      expect(after.updatedAt, 9000);
      expect(after.updatedAt, isNot(before));
    });
  });

  group('watchAll', () {
    test('emits again when the catalogue changes', () async {
      final emissions = <int>[];
      final sub = repo.watchAll().listen((rows) => emissions.add(rows.length));

      await makeCustom(id: 'a', name: 'A');
      await makeCustom(id: 'b', name: 'B');
      await repo.delete('a');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      // Reactive by construction — no manual invalidation anywhere.
      expect(emissions.last, 1);
      expect(emissions.length, greaterThan(1));
    });

    test('is alphabetical', () async {
      await makeCustom(id: 'c', name: 'Squat');
      await makeCustom(id: 'a', name: 'Bench Press');
      await makeCustom(id: 'b', name: 'Deadlift');

      final names = (await repo.getAll()).map((e) => e.name).toList();
      expect(names, ['Bench Press', 'Deadlift', 'Squat']);
    });
  });

  group('bulkArchiveByEquipment (F-CAT-009 §4)', () {
    test(
      'archives every non-archived exercise of that equipment only',
      () async {
        await repo.createCustom(
          id: 'cable-1',
          name: 'Cable Fly',
          primaryMuscle: Muscle.chest,
          equipment: Equipment.cable,
          trackingType: TrackingType.weightReps,
        );
        await repo.createCustom(
          id: 'cable-2',
          name: 'Cable Row',
          primaryMuscle: Muscle.upperBack,
          equipment: Equipment.cable,
          trackingType: TrackingType.weightReps,
        );
        await repo.createCustom(
          id: 'bb-1',
          name: 'Bench Press',
          primaryMuscle: Muscle.chest,
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
        );
        // Already archived — must not be double-counted.
        await repo.createCustom(
          id: 'cable-3',
          name: 'Already Archived',
          primaryMuscle: Muscle.chest,
          equipment: Equipment.cable,
          trackingType: TrackingType.weightReps,
        );
        await repo.setArchived('cable-3', isArchived: true);

        final count = await repo.bulkArchiveByEquipment(Equipment.cable);

        expect(count, 2);
        expect((await repo.findById('cable-1'))!.archivedAt, isNotNull);
        expect((await repo.findById('cable-2'))!.archivedAt, isNotNull);
        // The barbell exercise is untouched.
        expect((await repo.findById('bb-1'))!.archivedAt, isNull);
      },
    );

    test('archiving nothing returns zero', () async {
      final count = await repo.bulkArchiveByEquipment(Equipment.kettlebell);
      expect(count, 0);
    });
  });

  group('hasHistory', () {
    test('is false for an unused exercise', () async {
      await makeCustom();
      expect(await repo.hasHistory('ex-1'), isFalse);
    });

    test('is true once a workout references it', () async {
      await makeCustom();
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'w-1',
              name: 'Push',
              startedAt: 1,
              startedAtTzOffsetMinutes: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we-1',
              workoutId: 'w-1',
              exerciseId: 'ex-1',
              position: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );

      // Deleting an exercise with history must archive rather than remove.
      expect(await repo.hasHistory('ex-1'), isTrue);
    });
  });
}
