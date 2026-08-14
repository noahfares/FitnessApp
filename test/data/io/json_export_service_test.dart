import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/io/json_export_service.dart';

/// Batch 5.1 — `F-DAT-001`.
void main() {
  late AppDatabase db;
  late JsonExportService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = JsonExportService(db, clock: () => DateTime.utc(2026, 8, 13));
  });
  tearDown(() => db.close());

  test('stamps the canonical-units marker', () async {
    final buffer = StringBuffer();
    await service.writeTo(buffer);
    final result = jsonDecode(buffer.toString()) as Map<String, dynamic>;

    expect(result['units'], 'canonical-v1');
    expect(result['schemaVersion'], db.schemaVersion);
  });

  test('every table appears, even when empty', () async {
    final buffer = StringBuffer();
    await service.writeTo(buffer);
    final result = jsonDecode(buffer.toString()) as Map<String, dynamic>;
    final tables = result['tables'] as Map<String, dynamic>;

    for (final table in db.allTables) {
      expect(tables.containsKey(table.actualTableName), isTrue);
    }
  });

  test('includes tombstoned rows', () async {
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
          ),
        );
    await db.customStatement(
      "UPDATE exercises SET deleted_at = 999 WHERE id = 'deleted-one'",
    );

    final buffer = StringBuffer();
    await service.writeTo(buffer);
    final result = jsonDecode(buffer.toString()) as Map<String, dynamic>;
    final exercises =
        (result['tables'] as Map<String, dynamic>)['exercises']
            as List<dynamic>;

    expect(exercises, hasLength(1));
    expect((exercises.single as Map<String, dynamic>)['deleted_at'], 999);
  });
}
