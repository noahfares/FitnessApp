import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/io/backup_service.dart';
import 'package:fitness_app/data/io/json_export_service.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.path);
  final String path;

  @override
  Future<String?> getApplicationSupportPath() async => path;
}

/// Batch 5.2 — `F-DAT-008`.
void main() {
  late Directory tempDir;
  late AppDatabase db;
  late DateTime clock;
  late BackupService backupService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fitnessapp-backup-test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 1, 1);
    backupService = BackupService(JsonExportService(db), clock: () => clock);
  });
  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  Future<List<FileSystemEntity>> autoBackups() async {
    final dir = Directory('${tempDir.path}/backups');
    if (!dir.existsSync()) return [];
    return dir
        .list()
        .where(
          (e) => e.uri.pathSegments.last.contains('fitnessapp-autobackup-'),
        )
        .toList();
  }

  test('creates a backup when none exists yet', () async {
    final file = await backupService.maybeCreateAutomaticBackup();

    expect(file, isNotNull);
    expect(await autoBackups(), hasLength(1));
  });

  test('skips creating another backup inside the minimum interval', () async {
    await backupService.maybeCreateAutomaticBackup();
    clock = clock.add(const Duration(hours: 1));

    final second = await backupService.maybeCreateAutomaticBackup();

    expect(second, isNull);
    expect(await autoBackups(), hasLength(1));
  });

  test('creates a new backup once the interval has passed', () async {
    await backupService.maybeCreateAutomaticBackup();
    clock = clock.add(const Duration(hours: 25));

    final second = await backupService.maybeCreateAutomaticBackup();

    expect(second, isNotNull);
    expect(await autoBackups(), hasLength(2));
  });

  test('rotates old backups beyond the retention count', () async {
    for (var i = 0; i < 10; i++) {
      await backupService.maybeCreateAutomaticBackup(retentionCount: 3);
      clock = clock.add(const Duration(hours: 25));
    }

    expect(await autoBackups(), hasLength(3));
  });

  test('manual and pre-restore backups are never rotated', () async {
    await backupService.createBackup();
    for (var i = 0; i < 5; i++) {
      await backupService.maybeCreateAutomaticBackup(retentionCount: 2);
      clock = clock.add(const Duration(hours: 25));
    }

    final dir = Directory('${tempDir.path}/backups');
    final manual = await dir
        .list()
        .where((e) => e.uri.pathSegments.last.contains('fitnessapp-backup-'))
        .toList();
    expect(manual, hasLength(1));
    expect(await autoBackups(), hasLength(2));
  });
}
