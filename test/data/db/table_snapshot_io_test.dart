import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/table_snapshot_io.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/io/json_export_service.dart';

/// Batch 5.1 — the round-trip Phase 5's own exit criterion names: "export →
/// wipe → import reproduces the database exactly, verified table by table."
void main() {
  late AppDatabase db;
  late TableSnapshotIo snapshotIo;
  late JsonExportService exportService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    snapshotIo = TableSnapshotIo(db);
    exportService = JsonExportService(db);
  });
  tearDown(() => db.close());

  Future<Map<String, dynamic>> dumpTables() async {
    final buffer = StringBuffer();
    await exportService.writeTo(buffer);
    final decoded = jsonDecode(buffer.toString()) as Map<String, dynamic>;
    return decoded['tables'] as Map<String, dynamic>;
  }

  test('export, wipe, restore reproduces every table exactly', () async {
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
    // A soft-deleted row — every read path filters `deleted_at`, so a
    // restore built on repository reads would silently drop this one.
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

    final before = await dumpTables();

    await snapshotIo.deleteAllRows();
    final afterWipe = await dumpTables();
    for (final rows in afterWipe.values) {
      expect(rows, isEmpty);
    }

    await snapshotIo.restoreFrom(before);
    final after = await dumpTables();

    expect(after, equals(before));
  });

  test('deleteAllRows empties every table', () async {
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

    await snapshotIo.deleteAllRows();

    final result = await db.customSelect('SELECT * FROM exercises').get();
    expect(result, isEmpty);
  });

  test('purgeTombstonesBefore drops only old tombstones', () async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'old-tombstone',
            name: 'Old',
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
            deletedAt: const Value(1500000),
          ),
        );
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'kept',
            name: 'Kept',
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await snapshotIo.purgeTombstonesBefore(
      DateTime.fromMillisecondsSinceEpoch(500000, isUtc: true),
    );

    final result = await db.customSelect('SELECT id FROM exercises').get();
    expect(
      result.map((r) => r.data['id']),
      containsAll(['old-tombstone', 'kept']),
    );

    await snapshotIo.purgeTombstonesBefore(
      DateTime.fromMillisecondsSinceEpoch(2000000, isUtc: true),
    );
    final afterPurge = await db.customSelect('SELECT id FROM exercises').get();
    expect(afterPurge.map((r) => r.data['id']), equals(['kept']));
  });
}
