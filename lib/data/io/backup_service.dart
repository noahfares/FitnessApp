import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'json_export_service.dart';

/// The single-file backup a user keeps (`F-DAT-003`), built on
/// `JsonExportService`'s format so a backup is exactly what `F-DAT-004`
/// restores from. Also owns the periodic automatic backup (`F-DAT-008`).
///
/// Not built this batch: passphrase encryption (spec's "optional") and
/// bundling progress photos (`F-BOD-004` doesn't exist yet, so there is
/// nothing to gate on consent for) — both explicit deferrals, not silent
/// drops. `F-DAT-008`'s automatic backup runs on app launch, not a true
/// OS-level background job — the same scope this codebase already drew for
/// `F-TIM-003`'s background timer, and for the same reason: a scheduled
/// background task needs platform channel and manifest work this session's
/// toolchain (no Android SDK, `flutter build apk` is CI-only) can't verify.
class BackupService {
  BackupService(this._exportService, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final JsonExportService _exportService;
  final DateTime Function() _clock;

  static const _manualPrefix = 'fitnessapp-backup-';
  static const _autoPrefix = 'fitnessapp-autobackup-';

  /// Writes a timestamped backup into the app's own documents directory and
  /// returns the file. Kept on-device (not just handed to the share sheet)
  /// because `RestoreService`'s automatic pre-restore backup needs a file it
  /// can point back to without user interaction.
  Future<File> createBackup() => _writeBackup(_manualPrefix);

  /// Called once per app launch (`F-DAT-008`). Writes a new automatic backup
  /// only if the newest one is older than [minInterval], then prunes down to
  /// [retentionCount] — the "rotating retention window" the spec names.
  /// Kept in a separate `fitnessapp-autobackup-*` namespace so rotation never
  /// touches a manual backup or a restore's pre-restore safety copy.
  Future<File?> maybeCreateAutomaticBackup({
    Duration minInterval = const Duration(hours: 24),
    int retentionCount = 7,
  }) async {
    final dir = await _backupsDirectory();
    final existing = await _listBackups(dir, _autoPrefix);
    if (existing.isNotEmpty) {
      final newestTimestamp = _timestampOf(existing.first, _autoPrefix);
      if (newestTimestamp != null &&
          _clock().difference(newestTimestamp) < minInterval) {
        return null;
      }
    }

    final file = await _writeBackup(_autoPrefix);

    final rotated = await _listBackups(dir, _autoPrefix);
    for (final old in rotated.skip(retentionCount)) {
      await old.delete();
    }
    return file;
  }

  Future<File> _writeBackup(String prefix) async {
    final dir = await _backupsDirectory();
    final timestamp = DateFormat('yyyyMMdd-HHmmss').format(_clock());
    final file = File('${dir.path}/$prefix$timestamp.json');
    final sink = file.openWrite();
    await _exportService.writeTo(sink);
    await sink.close();
    return file;
  }

  /// Newest first — filenames are `yyyyMMdd-HHmmss`-suffixed, so a
  /// descending path sort is a descending time sort with no extra parsing.
  Future<List<File>> _listBackups(Directory dir, String prefix) async {
    final files = await dir
        .list()
        .where((e) => e is File && e.uri.pathSegments.last.startsWith(prefix))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  DateTime? _timestampOf(File file, String prefix) {
    final name = file.uri.pathSegments.last;
    final stamp = name
        .substring(prefix.length, name.length - '.json'.length)
        .replaceFirst('-', '');
    if (stamp.length != 14) return null;
    return DateTime(
      int.parse(stamp.substring(0, 4)),
      int.parse(stamp.substring(4, 6)),
      int.parse(stamp.substring(6, 8)),
      int.parse(stamp.substring(8, 10)),
      int.parse(stamp.substring(10, 12)),
      int.parse(stamp.substring(12, 14)),
    );
  }

  Future<Directory> _backupsDirectory() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/backups');
    return dir.create(recursive: true);
  }
}
