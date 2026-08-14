import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/ids/uuid.dart';
import '../db/app_database.dart';

/// Date-tagged progress photos (`F-BOD-004`).
///
/// The file lives in app-private storage under its own subdirectory, never
/// in the database — [ProgressPhoto.filePath] is a relative reference, and
/// `JsonExportService`/`JsonDumpService` only ever dump DB tables, so a
/// photo is excluded from a backup by construction, not by a filter that
/// could later be forgotten (spec §3's "default to excluding them"). The
/// opt-in half of §3 — bundling photos into a backup on request — is not
/// built: the backup format is a single JSON file, and folding binary photo
/// data into it would mean base64-encoding into memory, which defeats
/// `F-DAT-001`'s own streaming acceptance criterion. A real archive format
/// is the honest way to do this and is deferred, not silently dropped.
///
/// Deleting a photo is the one deliberate exception to "nothing is ever
/// hard-deleted" (ADR-0008) alongside `F-DAT-010`'s wipe: the row is
/// tombstoned *and* the file is removed from disk, because a photo left on
/// disk after "deletion" is wrong for the most sensitive data the app holds.
class ProgressPhotoRepository {
  ProgressPhotoRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch;

  Stream<List<ProgressPhoto>> watchAll() =>
      (_db.select(_db.progressPhotos)
            ..where((p) => p.deletedAt.isNull())
            ..orderBy([
              (p) =>
                  OrderingTerm(expression: p.takenAt, mode: OrderingMode.desc),
            ]))
          .watch();

  /// Copies [source] into app-private storage and rows it. [takenAt]
  /// defaults to now — a past date is a legitimate backfill for an
  /// already-existing photo.
  Future<String> addPhoto(
    File source, {
    DateTime? takenAt,
    String? notes,
  }) async {
    final at = takenAt ?? _clock();
    final id = newUuidV4();
    final dir = await _photosDirectory();
    final extension = source.path.split('.').last;
    final relativePath = 'photos/$id.$extension';
    await source.copy('${dir.path}/$id.$extension');

    final timestamp = _now;
    await _db
        .into(_db.progressPhotos)
        .insert(
          ProgressPhotosCompanion.insert(
            id: id,
            takenAt: at.millisecondsSinceEpoch,
            takenAtTzOffsetMinutes: at.timeZoneOffset.inMinutes,
            filePath: relativePath,
            notes: Value(notes),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    return id;
  }

  /// The absolute path a stored [ProgressPhoto.filePath] resolves to, for
  /// actually rendering the file.
  Future<File> resolveFile(String relativePath) async {
    final support = await getApplicationSupportDirectory();
    return File('${support.path}/$relativePath');
  }

  /// Tombstones the row and deletes the underlying file (see class doc).
  Future<void> deletePhoto(String id) async {
    final row = await (_db.select(
      _db.progressPhotos,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (row == null) return;

    final timestamp = _now;
    await (_db.update(_db.progressPhotos)..where((p) => p.id.equals(id))).write(
      ProgressPhotosCompanion(
        deletedAt: Value(timestamp),
        updatedAt: Value(timestamp),
      ),
    );

    final file = await resolveFile(row.filePath);
    if (file.existsSync()) await file.delete();
  }

  Future<Directory> _photosDirectory() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/photos');
    return dir.create(recursive: true);
  }
}
