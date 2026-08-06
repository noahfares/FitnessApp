import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/app_version.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/io/json_dump_service.dart';

/// Batch 1.8 — `F-DAT-011`.
void main() {
  late AppDatabase db;
  late JsonDumpService service;
  final clock = DateTime.utc(2026, 8, 6, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = JsonDumpService(db, clock: () => clock);
  });
  tearDown(() => db.close());

  Future<Map<String, dynamic>> dump() async {
    final buffer = StringBuffer();
    await service.writeTo(buffer);
    return jsonDecode(buffer.toString()) as Map<String, dynamic>;
  }

  test('is valid JSON and stamps the schema and app version', () async {
    final result = await dump();

    expect(result['schemaVersion'], db.schemaVersion);
    expect(result['appVersion'], appVersion);
    expect(result['exportedAt'], clock.millisecondsSinceEpoch);
  });

  test('every table appears, even when empty', () async {
    final result = await dump();
    final tables = result['tables'] as Map<String, dynamic>;

    for (final table in db.allTables) {
      expect(
        tables.containsKey(table.actualTableName),
        isTrue,
        reason: '${table.actualTableName} missing from the dump',
      );
      expect(tables[table.actualTableName], isA<List<dynamic>>());
    }
  });

  test('rows come out with raw column names and canonical values', () async {
    await db
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

    final result = await dump();
    final exercises =
        (result['tables'] as Map<String, dynamic>)['exercises']
            as List<dynamic>;
    final row = exercises.single as Map<String, dynamic>;

    expect(row['id'], 'bench');
    expect(row['name'], 'Bench Press');
    expect(row['primary_muscle'], 'chest');
    expect(row['is_custom'], anyOf(0, false));
  });

  test('tombstoned rows are included, not filtered', () async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'deleted-one',
            name: 'Gone',
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
            deletedAt: const Value(999),
          ),
        );

    final result = await dump();
    final exercises =
        (result['tables'] as Map<String, dynamic>)['exercises']
            as List<dynamic>;
    expect(exercises, hasLength(1));
    expect((exercises.single as Map<String, dynamic>)['deleted_at'], 999);
  });
}
