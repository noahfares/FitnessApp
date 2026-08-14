import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/table_snapshot_io.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/io/backup_service.dart';
import 'package:fitness_app/data/io/json_export_service.dart';
import 'package:fitness_app/data/io/restore_service.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.path);
  final String path;

  @override
  Future<String?> getApplicationSupportPath() async => path;
}

/// Batch 5.1 — `F-DAT-004`.
void main() {
  late Directory tempDir;
  late AppDatabase db;
  late RestoreService restoreService;
  late BackupService backupService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fitnessapp-restore-test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    db = AppDatabase(NativeDatabase.memory());
    backupService = BackupService(JsonExportService(db));
    restoreService = RestoreService(db, backupService, TableSnapshotIo(db));
  });
  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  test('restores a valid backup and returns success', () async {
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
    final backupFile = await backupService.createBackup();

    // Mutate the database so the restore has something real to reverse.
    await db.customStatement("DELETE FROM exercises WHERE id = 'bench'");

    final result = await restoreService.restoreFrom(backupFile);

    expect(result.outcome, RestoreOutcome.success);
    final rows = await db.customSelect('SELECT id FROM exercises').get();
    expect(rows.map((r) => r.data['id']), contains('bench'));
  });

  test('refuses a file with the wrong schema version', () async {
    final file = File('${tempDir.path}/bad.json');
    await file.writeAsString(
      jsonEncode({
        'schemaVersion': db.schemaVersion + 1,
        'appVersion': '0.0.0',
        'tables': <String, dynamic>{},
      }),
    );

    final result = await restoreService.restoreFrom(file);

    expect(result.outcome, RestoreOutcome.versionMismatch);
  });

  test('refuses a file that is not valid JSON', () async {
    final file = File('${tempDir.path}/garbage.json');
    await file.writeAsString('not json');

    final result = await restoreService.restoreFrom(file);

    expect(result.outcome, RestoreOutcome.invalidFile);
  });

  test('a failed restore leaves the existing database untouched', () async {
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
    final file = File('${tempDir.path}/bad-version.json');
    await file.writeAsString(
      jsonEncode({
        'schemaVersion': db.schemaVersion + 1,
        'appVersion': '0.0.0',
        'tables': <String, dynamic>{},
      }),
    );

    await restoreService.restoreFrom(file);

    final rows = await db.customSelect('SELECT id FROM exercises').get();
    expect(rows.map((r) => r.data['id']), contains('bench'));
  });
}
