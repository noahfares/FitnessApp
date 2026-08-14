import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'json_export_service.dart';

/// The single-file backup a user keeps (`F-DAT-003`), built on
/// `JsonExportService`'s format so a backup is exactly what `F-DAT-004`
/// restores from.
///
/// Not built this batch: passphrase encryption (spec's "optional") and
/// bundling progress photos (`F-BOD-004` doesn't exist yet, so there is
/// nothing to gate on consent for) — both explicit deferrals, not silent
/// drops.
class BackupService {
  BackupService(this._exportService, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final JsonExportService _exportService;
  final DateTime Function() _clock;

  /// Writes a timestamped backup into the app's own documents directory and
  /// returns the file. Kept on-device (not just handed to the share sheet)
  /// because `RestoreService`'s automatic pre-restore backup needs a file it
  /// can point back to without user interaction.
  Future<File> createBackup() async {
    final dir = await _backupsDirectory();
    final timestamp = DateFormat('yyyyMMdd-HHmmss').format(_clock());
    final file = File('${dir.path}/fitnessapp-backup-$timestamp.json');
    final sink = file.openWrite();
    await _exportService.writeTo(sink);
    await sink.close();
    return file;
  }

  Future<Directory> _backupsDirectory() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/backups');
    return dir.create(recursive: true);
  }
}
