import 'package:csv/csv.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/io/import_service.dart';
import 'package:fitness_app/data/repositories/exercise_repository.dart';
import 'package:fitness_app/data/repositories/personal_record_repository.dart';
import 'package:fitness_app/domain/import/csv_import_adapter.dart';

/// Batch 5.3 — `F-DAT-005` §1, §4, §5.
void main() {
  late AppDatabase db;
  late ImportService service;
  const converter = CsvToListConverter(eol: '\n');
  const adapter = CsvImportAdapter(strongColumnMapping);

  const csv =
      'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,RPE\n'
      '2026-01-01 08:00:00,Push Day,Bench Press,1,100,5,8\n'
      '2026-01-01 08:00:00,Push Day,Bench Press,2,102.5,5,\n'
      '2026-01-01 08:00:00,Push Day,Overhead Press,1,50,8,\n';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = ImportService(
      db,
      ExerciseRepository(db),
      PersonalRecordRepository(db),
    );
  });
  tearDown(() => db.close());

  test('preview counts workouts and sets without writing anything', () async {
    final parsed = adapter.parse(converter.convert(csv));

    final preview = await service.preview(parsed);

    expect(preview.workoutCount, 1);
    expect(preview.setCount, 3);
    expect(
      preview.unmatchedExerciseNames,
      unorderedEquals(['Bench Press', 'Overhead Press']),
    );
    final rows = await db.customSelect('SELECT * FROM workouts').get();
    expect(rows, isEmpty);
  });

  test('commit creates exercises, a workout and its sets', () async {
    final parsed = adapter.parse(converter.convert(csv));

    final result = await service.commit(parsed, {
      'Bench Press': const ExerciseResolution.createCustom(),
      'Overhead Press': const ExerciseResolution.createCustom(),
    }, sourceUnit: MassUnit.kg);

    expect(result.workoutsImported, 1);
    expect(result.setsImported, 3);
    final exercises = await db.customSelect('SELECT name FROM exercises').get();
    expect(
      exercises.map((r) => r.data['name']),
      unorderedEquals(['Bench Press', 'Overhead Press']),
    );
    final sets = await db.customSelect('SELECT weight_grams FROM sets').get();
    expect(
      sets.map((r) => r.data['weight_grams']),
      containsAll([100000, 102500, 50000]),
    );
    final prs = await db.customSelect('SELECT * FROM personal_records').get();
    expect(prs, isNotEmpty);
  });

  test('a skipped exercise name imports no sets for it', () async {
    final parsed = adapter.parse(converter.convert(csv));

    final result = await service.commit(parsed, {
      'Bench Press': const ExerciseResolution.createCustom(),
      'Overhead Press': const ExerciseResolution.skip(),
    }, sourceUnit: MassUnit.kg);

    expect(result.setsImported, 2);
  });

  test('re-importing the same file does not duplicate the workout', () async {
    final parsed = adapter.parse(converter.convert(csv));
    final resolutions = {
      'Bench Press': const ExerciseResolution.createCustom(),
      'Overhead Press': const ExerciseResolution.createCustom(),
    };
    await service.commit(parsed, resolutions, sourceUnit: MassUnit.kg);

    final second = await service.commit(
      parsed,
      resolutions,
      sourceUnit: MassUnit.kg,
    );

    expect(second.workoutsImported, 0);
    expect(second.workoutsSkippedAsDuplicate, 1);
    final workouts = await db.customSelect('SELECT * FROM workouts').get();
    expect(workouts, hasLength(1));
  });
}
