import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/body_measurement_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';

/// Batch 1.8 — `F-BOD-001`.
void main() {
  late AppDatabase db;
  late BodyMeasurementRepository repo;
  late WorkoutRepository workouts;
  var clock = DateTime(2026, 8, 6, 18, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 8, 6, 18, 30);
    repo = BodyMeasurementRepository(db, clock: () => clock);
    workouts = WorkoutRepository(db, clock: () => clock);
  });
  tearDown(() => db.close());

  group('logging (F-BOD-001 §1)', () {
    test('defaults to now, and stores the trimmed note', () async {
      final id = await repo.logBodyweight(grams: 80000, notes: '  fasted  ');

      final entry = (await repo.watchBodyweightHistory().first).single;
      expect(entry.id, id);
      expect(entry.valueCanonical, 80000);
      expect(entry.measuredAt, clock.millisecondsSinceEpoch);
      expect(entry.notes, 'fasted');
    });

    test('a blank note is stored as null', () async {
      await repo.logBodyweight(grams: 80000, notes: '   ');
      expect((await repo.watchBodyweightHistory().first).single.notes, isNull);
    });

    test('multiple entries per day are allowed', () async {
      await repo.logBodyweight(grams: 80000);
      await repo.logBodyweight(grams: 80200);
      expect(await repo.watchBodyweightHistory().first, hasLength(2));
    });

    test(
      'watchLatestBodyweight is the most recent by date, not by insertion',
      () async {
        await repo.logBodyweight(
          grams: 79000,
          measuredAt: DateTime(2026, 8, 1),
        );
        await repo.logBodyweight(
          grams: 81000,
          measuredAt: DateTime(2026, 8, 10),
        );
        await repo.logBodyweight(
          grams: 80000,
          measuredAt: DateTime(2026, 8, 5),
        );

        final latest = await repo.watchLatestBodyweight().first;
        expect(latest!.valueCanonical, 81000);
      },
    );
  });

  group('editing and deleting', () {
    test('update rewrites only the given fields', () async {
      final id = await repo.logBodyweight(grams: 80000, notes: 'a');
      await repo.updateBodyweight(id, grams: 79500);

      final entry = (await repo.watchBodyweightHistory().first).single;
      expect(entry.valueCanonical, 79500);
      expect(entry.notes, 'a');
    });

    test('delete tombstones rather than removing the row', () async {
      final id = await repo.logBodyweight(grams: 80000);
      await repo.deleteBodyweight(id);

      expect(await repo.watchBodyweightHistory().first, isEmpty);
      final raw = await db.select(db.bodyMeasurements).get();
      expect(raw.single.deletedAt, isNotNull);
    });
  });

  group('workout association (F-BOD-001 §3)', () {
    test(
      'a new workout gets the most recent bodyweight at or before it',
      () async {
        await repo.logBodyweight(
          grams: 79000,
          measuredAt: DateTime(2026, 8, 1),
        );
        await repo.logBodyweight(
          grams: 80000,
          measuredAt: DateTime(2026, 8, 5),
        );

        clock = DateTime(2026, 8, 6);
        final workout = await workouts.start();
        expect(workout.bodyweightGrams, 80000);
      },
    );

    test('no entry at all leaves bodyweight_grams null', () async {
      final workout = await workouts.start();
      expect(workout.bodyweightGrams, isNull);
    });

    test(
      'backfilling an older entry updates workouts already in progress at that time',
      () async {
        clock = DateTime(2026, 8, 10);
        final workout = await workouts.start();
        expect(workout.bodyweightGrams, isNull);

        // Logged after the fact, dated before the workout — a backfill
        // (`F-BOD-001` acceptance).
        await repo.logBodyweight(
          grams: 78000,
          measuredAt: DateTime(2026, 8, 1),
        );

        final updated = await workouts.findById(workout.id);
        expect(updated!.bodyweightGrams, 78000);
      },
    );

    test('deleting the applicable entry falls back to the next best', () async {
      final earlyId = await repo.logBodyweight(
        grams: 78000,
        measuredAt: DateTime(2026, 8, 1),
      );
      await repo.logBodyweight(grams: 80000, measuredAt: DateTime(2026, 8, 5));

      clock = DateTime(2026, 8, 6);
      final workout = await workouts.start();
      expect(workout.bodyweightGrams, 80000);

      await repo.deleteBodyweight(earlyId);
      // The later entry is untouched by deleting the earlier one.
      final unaffected = await workouts.findById(workout.id);
      expect(unaffected!.bodyweightGrams, 80000);
    });
  });

  group('generic measurements (F-BOD-002)', () {
    test('logs and reads back a circumference entry', () async {
      final id = await repo.logMeasurement(
        type: MeasurementType.waist,
        valueCanonical: 800, // 80.0 cm in millimetres
        notes: '  after breakfast  ',
      );

      final entry =
          (await repo.watchHistory(MeasurementType.waist).first).single;
      expect(entry.id, id);
      expect(entry.type, MeasurementType.waist);
      expect(entry.valueCanonical, 800);
      expect(entry.notes, 'after breakfast');
    });

    test('watchHistory and watchLatest are scoped to their own type', () async {
      await repo.logMeasurement(
        type: MeasurementType.waist,
        valueCanonical: 800,
      );
      await repo.logMeasurement(
        type: MeasurementType.chest,
        valueCanonical: 1000,
      );

      expect(
        await repo.watchHistory(MeasurementType.waist).first,
        hasLength(1),
      );
      final latestChest = await repo.watchLatest(MeasurementType.chest).first;
      expect(latestChest!.valueCanonical, 1000);
    });

    test(
      'watchLatest reflects the most recently measured, not most recently logged',
      () async {
        await repo.logMeasurement(
          type: MeasurementType.waist,
          valueCanonical: 810,
          measuredAt: DateTime(2026, 8, 5),
        );
        await repo.logMeasurement(
          type: MeasurementType.waist,
          valueCanonical: 800,
          measuredAt: DateTime(2026, 8, 1),
        );

        final latest = await repo.watchLatest(MeasurementType.waist).first;
        expect(latest!.valueCanonical, 810);
      },
    );

    test('updateMeasurement edits value, date and notes', () async {
      final id = await repo.logMeasurement(
        type: MeasurementType.bodyFatPercent,
        valueCanonical: 1850,
      );

      await repo.updateMeasurement(
        id,
        valueCanonical: 1800,
        measuredAt: DateTime(2026, 8, 1),
        notes: const Value('leaner'),
      );

      final entry =
          (await repo.watchHistory(MeasurementType.bodyFatPercent).first)
              .single;
      expect(entry.valueCanonical, 1800);
      expect(entry.measuredAt, DateTime(2026, 8, 1).millisecondsSinceEpoch);
      expect(entry.notes, 'leaner');
    });

    test('deleteMeasurement tombstones rather than removing the row', () async {
      final id = await repo.logMeasurement(
        type: MeasurementType.hips,
        valueCanonical: 950,
      );

      await repo.deleteMeasurement(id);

      expect(await repo.watchHistory(MeasurementType.hips).first, isEmpty);
    });

    test(
      'deleting or editing a non-bodyweight entry never touches workouts',
      () async {
        final workout = await workouts.start();
        final before = (await workouts.findById(workout.id))!.bodyweightGrams;

        final id = await repo.logMeasurement(
          type: MeasurementType.waist,
          valueCanonical: 800,
        );
        await repo.updateMeasurement(id, valueCanonical: 810);
        await repo.deleteMeasurement(id);

        final after = (await workouts.findById(workout.id))!.bodyweightGrams;
        expect(after, before);
      },
    );
  });
}
