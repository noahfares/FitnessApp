import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/personal_record_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/seed/demo_data_seeder.dart';
import 'package:fitness_app/data/seed/exercise_seeder.dart';

/// The debug-only "Load sample data" action (Settings › Data).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('produces 8 weeks of finished sessions and derived data', () async {
    await ExerciseSeeder(db).seedIfNeeded(now: () => 1);

    final now = DateTime(2026, 8, 14);
    await DemoDataSeeder(db).seed(now: now);

    final workouts =
        await (db.select(db.workouts)
              ..where((w) => w.deletedAt.isNull())
              ..where((w) => w.endedAt.isNotNull()))
            .get();
    // 3 sessions/week * 8 weeks.
    expect(workouts, hasLength(24));

    final bench = await (db.select(
      db.exercises,
    )..where((e) => e.externalId.equals('barbell-bench-press'))).getSingle();

    final sets = SetRepository(db);
    final history = await sets.getExerciseHistory(bench.id);
    expect(history, hasLength(8)); // one push day per week
    for (final session in history) {
      expect(session.countedSets, hasLength(3));
    }

    final body = await (db.select(
      db.bodyMeasurements,
    )..where((m) => m.type.equalsValue(MeasurementType.bodyweight))).get();
    expect(body, hasLength(8));

    // Real repository writes mean personal records are already cached —
    // this seeder never pokes the table directly.
    final prs = await PersonalRecordRepository(
      db,
    ).recordsForWorkout(workouts.first.id);
    expect(prs, isA<List>()); // no crash reading it; content varies by week
  });

  test('throws a clear error if the catalogue seed has not run', () async {
    expect(
      () => DemoDataSeeder(db).seed(now: DateTime(2026, 8, 14)),
      throwsA(isA<StateError>()),
    );
  });
}
