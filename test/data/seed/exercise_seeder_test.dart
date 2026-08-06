import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/seed/exercise_seeder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  var clock = 1000;
  int now() => clock++;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = 1000;
  });
  tearDown(() => db.close());

  /// Serves a synthetic catalogue so tests do not depend on the real asset's
  /// contents, which will keep changing.
  ///
  /// The evict is essential: `rootBundle` caches by key, so without it every
  /// test after the first silently reads the first test's payload.
  void mockAsset(Map<String, dynamic> payload, {String path = 'test-seed'}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          if (key != path) return null;
          final bytes = utf8.encode(jsonEncode(payload));
          return ByteData.view(Uint8List.fromList(bytes).buffer);
        });
    rootBundle.evict(path);
  }

  Map<String, dynamic> record({
    String externalId = 'barbell-bench-press',
    String uuid = 'uuid-bench',
    String name = 'Bench Press',
    String primary = 'chest',
    List<String> secondary = const ['triceps'],
    String equipment = 'barbell',
    String tracking = 'weightReps',
    List<String> aliases = const ['bp'],
  }) => {
    'uuid': uuid,
    'externalId': externalId,
    'name': name,
    'primaryMuscle': primary,
    'secondaryMuscles': secondary,
    'equipment': equipment,
    'trackingType': tracking,
    'aliases': aliases,
  };

  group('first launch', () {
    test('populates the catalogue', () async {
      mockAsset({
        'seedVersion': 1,
        'exercises': [
          record(),
          record(
            externalId: 'squat',
            uuid: 'uuid-squat',
            name: 'Back Squat',
            primary: 'quads',
          ),
        ],
      });

      final result = await ExerciseSeeder(
        db,
        assetPath: 'test-seed',
      ).seedIfNeeded(now: now);

      expect(result.inserted, 2);
      final rows = await db.select(db.exercises).get();
      expect(rows, hasLength(2));

      final bench = rows.firstWhere(
        (e) => e.externalId == 'barbell-bench-press',
      );
      expect(bench.id, 'uuid-bench');
      expect(bench.name, 'Bench Press');
      expect(bench.primaryMuscle, Muscle.chest);
      expect(bench.secondaryMuscles, ['triceps']);
      expect(bench.equipment, Equipment.barbell);
      expect(bench.trackingType, TrackingType.weightReps);
      expect(bench.aliases, ['bp']);
      // Stamped so re-seeding can tell it has not been edited.
      expect(bench.seedUpdatedAt, bench.updatedAt);
    });

    test('is a no-op on the second call', () async {
      mockAsset({
        'seedVersion': 1,
        'exercises': [record()],
      });
      final seeder = ExerciseSeeder(db, assetPath: 'test-seed');

      await seeder.seedIfNeeded(now: now);
      final second = await seeder.seedIfNeeded(now: now);

      expect(second.didAnything, isFalse);
      expect(await db.select(db.exercises).get(), hasLength(1));
    });
  });

  group('upgrade', () {
    test('adds new records without duplicating existing ones', () async {
      mockAsset({
        'seedVersion': 1,
        'exercises': [record()],
      });
      await ExerciseSeeder(db, assetPath: 'test-seed').seedIfNeeded(now: now);

      mockAsset({
        'seedVersion': 2,
        'exercises': [
          record(),
          record(
            externalId: 'deadlift',
            uuid: 'uuid-dl',
            name: 'Deadlift',
            primary: 'lowerBack',
          ),
        ],
      });
      final result = await ExerciseSeeder(
        db,
        assetPath: 'test-seed',
      ).seedIfNeeded(now: now);

      expect(result.inserted, 1);
      expect(await db.select(db.exercises).get(), hasLength(2));
    });

    test('an upstream rename updates in place, keeping the row id', () async {
      // Matching on external_id rather than name is what makes this possible.
      // Matching on name would create a duplicate and orphan every logged set.
      mockAsset({
        'seedVersion': 1,
        'exercises': [record()],
      });
      await ExerciseSeeder(db, assetPath: 'test-seed').seedIfNeeded(now: now);

      mockAsset({
        'seedVersion': 2,
        'exercises': [record(name: 'Barbell Bench Press')],
      });
      final result = await ExerciseSeeder(
        db,
        assetPath: 'test-seed',
      ).seedIfNeeded(now: now);

      expect(result.updated, 1);
      final rows = await db.select(db.exercises).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'uuid-bench');
      expect(rows.single.name, 'Barbell Bench Press');
    });

    test('a user edit is never overwritten', () async {
      mockAsset({
        'seedVersion': 1,
        'exercises': [record()],
      });
      await ExerciseSeeder(db, assetPath: 'test-seed').seedIfNeeded(now: now);

      // The user renames it and adds a sticky note.
      await (db.update(
        db.exercises,
      )..where((e) => e.id.equals('uuid-bench'))).write(
        ExercisesCompanion(
          name: const Value('Comp Bench'),
          notes: const Value('pause 1s'),
          updatedAt: Value(now()),
        ),
      );

      mockAsset({
        'seedVersion': 2,
        'exercises': [record(name: 'Barbell Bench Press')],
      });
      final result = await ExerciseSeeder(
        db,
        assetPath: 'test-seed',
      ).seedIfNeeded(now: now);

      expect(result.skipped, 1);
      expect(result.updated, 0);
      final row = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('uuid-bench'))).getSingle();
      expect(row.name, 'Comp Bench');
      expect(row.notes, 'pause 1s');
    });

    test('an unedited row survives repeated re-seeds', () async {
      // The regression this column exists for. Comparing updatedAt to createdAt
      // instead would mark every row as edited after the first re-seed, so
      // upstream corrections would silently stop applying.
      mockAsset({
        'seedVersion': 1,
        'exercises': [record()],
      });
      await ExerciseSeeder(db, assetPath: 'test-seed').seedIfNeeded(now: now);

      for (var version = 2; version <= 4; version++) {
        mockAsset({
          'seedVersion': version,
          'exercises': [record(name: 'Bench v$version')],
        });
        final result = await ExerciseSeeder(
          db,
          assetPath: 'test-seed',
        ).seedIfNeeded(now: now);
        expect(result.updated, 1, reason: 're-seed $version did not apply');
        expect(result.skipped, 0, reason: 're-seed $version wrongly skipped');
      }

      final row = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('uuid-bench'))).getSingle();
      expect(row.name, 'Bench v4');
    });

    test('user-set fields survive a legitimate update', () async {
      mockAsset({
        'seedVersion': 1,
        'exercises': [record()],
      });
      await ExerciseSeeder(db, assetPath: 'test-seed').seedIfNeeded(now: now);

      // Favouriting is not an edit to catalogue-owned data, so the row stays
      // seed-clean — but the flag must still survive the refresh.
      await (db.update(db.exercises)..where((e) => e.id.equals('uuid-bench')))
          .write(const ExercisesCompanion(isFavorite: Value(true)));

      mockAsset({
        'seedVersion': 2,
        'exercises': [record(name: 'Barbell Bench Press')],
      });
      await ExerciseSeeder(db, assetPath: 'test-seed').seedIfNeeded(now: now);

      final row = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('uuid-bench'))).getSingle();
      expect(row.isFavorite, isTrue);
    });
  });

  group('custom exercises', () {
    test('are never touched by seeding', () async {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'custom-1',
              name: 'My Machine Thing',
              primaryMuscle: Muscle.chest,
              equipment: Equipment.machine,
              trackingType: TrackingType.weightReps,
              isCustom: const Value(true),
              createdAt: 1,
              updatedAt: 1,
            ),
          );

      mockAsset({
        'seedVersion': 1,
        'exercises': [record()],
      });
      await ExerciseSeeder(db, assetPath: 'test-seed').seedIfNeeded(now: now);

      final custom = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('custom-1'))).getSingle();
      expect(custom.name, 'My Machine Thing');
      expect(custom.externalId, isNull);
    });
  });

  group('strict parsing', () {
    test('an unknown muscle throws rather than defaulting', () async {
      // A silently mis-categorised exercise corrupts every sets-per-muscle
      // figure downstream (F-ANA-005), so failing loudly is correct.
      mockAsset({
        'seedVersion': 1,
        'exercises': [record(primary: 'quadriceps')],
      });

      await expectLater(
        ExerciseSeeder(db, assetPath: 'test-seed').seedIfNeeded(now: now),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
