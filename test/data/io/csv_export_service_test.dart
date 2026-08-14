import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/core/units/unit_preferences.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/io/csv_export_service.dart';
import 'package:fitness_app/data/repositories/body_measurement_repository.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';

/// Batch 5.2 — `F-DAT-002`.
void main() {
  late AppDatabase db;
  late CsvExportService service;
  late WorkoutRepository workoutRepo;
  late SetRepository setRepo;
  late RoutineRepository routineRepo;
  late BodyMeasurementRepository measurementRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workoutRepo = WorkoutRepository(db);
    setRepo = SetRepository(db);
    routineRepo = RoutineRepository(db);
    measurementRepo = BodyMeasurementRepository(db);
    service = CsvExportService(setRepo, measurementRepo, routineRepo);
  });
  tearDown(() => db.close());

  Future<void> seedExercise() => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: 'bench',
          name: 'Bench Press',
          primaryMuscle: Muscle.chest,
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
          createdAt: 1,
          updatedAt: 1,
        ),
      );

  test('sets CSV uses the display unit in the header and values', () async {
    await seedExercise();
    final workout = await workoutRepo.start();
    await workoutRepo.addExercises(workout.id, ['bench']);
    final rows = await workoutRepo.watchExercises(workout.id).first;
    final setId = (await setRepo.getSets(
      rows.single.workoutExerciseId,
    )).single.id;
    await setRepo.complete(
      setId,
      weightGrams: const Value(100000),
      reps: const Value(5),
    );

    final csv = await service.setsCsv(const UnitPreferences(load: MassUnit.lb));

    expect(csv, contains('weight_lb'));
    expect(csv, contains('Bench Press'));
    // 100 kg ≈ 220.46 lb.
    expect(csv, contains('220.46'));
  });

  test(
    'measurements CSV converts bodyweight to the body display unit',
    () async {
      await measurementRepo.logBodyweight(
        grams: 80000,
        measuredAt: DateTime.utc(2026, 1, 1),
      );

      final csv = await service.measurementsCsv(
        const UnitPreferences(body: MassUnit.lb),
      );

      expect(csv, contains('bodyweight'));
      expect(csv, contains('lb'));
      // 80 kg ≈ 176.37 lb.
      expect(csv, contains('176.37'));
    },
  );

  test('routines CSV lists routine, day, exercise and targets', () async {
    await seedExercise();
    final routine = await routineRepo.create(name: 'Push Pull Legs');
    final day = await routineRepo.addDay(routine.id, name: 'Push');
    await routineRepo.addExercises(day.id, ['bench']);

    final csv = await service.routinesCsv(UnitPreferences.metric);

    expect(csv, contains('Push Pull Legs'));
    expect(csv, contains('Push'));
    expect(csv, contains('Bench Press'));
  });
}
