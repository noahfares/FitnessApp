import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/repositories/progress_photo_repository.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.path);
  final String path;

  @override
  Future<String?> getApplicationSupportPath() async => path;
}

/// Batch 5.4 — `F-BOD-004`.
void main() {
  late Directory tempDir;
  late Directory supportDir;
  late AppDatabase db;
  late ProgressPhotoRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fitnessapp-photo-test');
    supportDir = Directory('${tempDir.path}/support')..createSync();
    PathProviderPlatform.instance = _FakePathProvider(supportDir.path);
    db = AppDatabase(NativeDatabase.memory());
    repo = ProgressPhotoRepository(db);
  });
  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  Future<File> sourceImage() async {
    final file = File('${tempDir.path}/source.jpg');
    await file.writeAsBytes([1, 2, 3, 4]);
    return file;
  }

  test('copies the source file into app-private storage', () async {
    final source = await sourceImage();

    final id = await repo.addPhoto(source, takenAt: DateTime.utc(2026, 1, 1));

    final photos = await repo.watchAll().first;
    expect(photos, hasLength(1));
    expect(photos.single.id, id);
    final stored = await repo.resolveFile(photos.single.filePath);
    expect(stored.existsSync(), isTrue);
    expect(await stored.readAsBytes(), [1, 2, 3, 4]);
  });

  test('does not touch the original source file', () async {
    final source = await sourceImage();

    await repo.addPhoto(source);

    expect(source.existsSync(), isTrue);
  });

  test('deleting tombstones the row and removes the file', () async {
    final source = await sourceImage();
    final id = await repo.addPhoto(source);
    final filePath = (await repo.watchAll().first).single.filePath;
    final storedFile = await repo.resolveFile(filePath);
    expect(storedFile.existsSync(), isTrue);

    await repo.deletePhoto(id);

    expect(await repo.watchAll().first, isEmpty);
    expect(storedFile.existsSync(), isFalse);
    final rows = await db.customSelect('SELECT * FROM progress_photos').get();
    expect(rows, hasLength(1));
    expect(rows.single.data['deleted_at'], isNotNull);
  });

  test('watchAll orders most recent first', () async {
    final source = await sourceImage();
    await repo.addPhoto(source, takenAt: DateTime.utc(2026, 1, 1));
    await repo.addPhoto(source, takenAt: DateTime.utc(2026, 6, 1));

    final photos = await repo.watchAll().first;

    expect(
      photos.first.takenAt,
      DateTime.utc(2026, 6, 1).millisecondsSinceEpoch,
    );
  });
}
