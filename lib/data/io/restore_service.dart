import 'dart:convert';
import 'dart:io';

import '../db/app_database.dart';
import '../db/table_snapshot_io.dart';
import 'backup_service.dart';

enum RestoreOutcome { success, invalidFile, versionMismatch }

class RestoreResult {
  const RestoreResult(this.outcome, {this.message});

  final RestoreOutcome outcome;
  final String? message;
}

/// Restores a backup written by `BackupService`/`JsonExportService`
/// (`F-DAT-004`).
///
/// Version-checked and transactional (spec §2–3): a backup from a schema
/// version other than the one currently open is refused before anything is
/// touched, rather than partially applied — this app never migrates a
/// restore's rows, only the database it opens on launch, so an exact match is
/// the only version this can safely accept.
class RestoreService {
  RestoreService(this._db, this._backupService, this._snapshotIo);

  final AppDatabase _db;
  final BackupService _backupService;
  final TableSnapshotIo _snapshotIo;

  /// A pre-restore safety backup is always taken first (spec §4) — even a
  /// refused restore never risks the existing database, but a *successful*
  /// one that turns out to be the wrong file should still be undoable.
  Future<RestoreResult> restoreFrom(File backupFile) async {
    final Map<String, dynamic> json;
    try {
      json =
          jsonDecode(await backupFile.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return const RestoreResult(
        RestoreOutcome.invalidFile,
        message: 'Not a valid backup file.',
      );
    }

    final schemaVersion = json['schemaVersion'];
    final tables = json['tables'];
    if (schemaVersion is! int || tables is! Map) {
      return const RestoreResult(
        RestoreOutcome.invalidFile,
        message: 'Not a valid backup file.',
      );
    }
    if (schemaVersion != _db.schemaVersion) {
      final direction = schemaVersion > _db.schemaVersion ? 'newer' : 'older';
      return RestoreResult(
        RestoreOutcome.versionMismatch,
        message:
            'This backup is from a $direction version of the app and '
            "can't be restored here.",
      );
    }

    await _backupService.createBackup();
    await _snapshotIo.restoreFrom(Map<String, dynamic>.from(tables));
    return const RestoreResult(RestoreOutcome.success);
  }
}
