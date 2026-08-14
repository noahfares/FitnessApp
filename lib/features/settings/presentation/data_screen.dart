import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/io/restore_service.dart';
import '../../../data/platform/export_sharer.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../application/unit_preferences_provider.dart';

/// Settings › Data (`F-DAT-001`, `F-DAT-003`, `F-DAT-004`, `F-DAT-010`,
/// `F-DAT-011`, `F-LOG-013` §5).
///
/// The minimal JSON dump (`F-DAT-011`) is Phase 1's rescue tool — dump, fix,
/// reimport by hand if a schema mistake ever needs it
/// (docs/30-features/DAT/F-DAT-011.md §Why). Everything below it is Phase
/// 5's real, versioned, round-trip-guaranteed data layer built on top: a
/// backup a user keeps, restoring from one, and wiping the device back to
/// first run. Also carries the "rebuild personal records" maintenance
/// action — unrelated to any of these, but there is no other settings page
/// for data-integrity actions yet.
class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  bool _exporting = false;
  bool _exportingCsv = false;
  bool _backingUp = false;
  bool _restoring = false;
  bool _wiping = false;
  bool _rebuildingPrs = false;
  bool _seedingDemoData = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Data')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'Every table, every row, exactly as stored — a rescue copy, not '
            'a polished backup. Share it somewhere safe.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _exporting ? null : () => unawaited(_export(context)),
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            label: Text(_exporting ? 'Exporting…' : 'Export data (.json)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'For spreadsheets, not backup — one CSV each for sets, body '
            'measurements and routines, in your display units.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _exportingCsv
                ? null
                : () => unawaited(_exportCsv(context)),
            icon: _exportingCsv
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.table_chart_outlined),
            label: Text(_exportingCsv ? 'Exporting…' : 'Export data (.csv)'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Bring your history over from Strong or Hevy — nothing is '
            'written until you confirm what to do with each exercise.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.settingsDataImport),
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Import from Strong or Hevy'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'A backup is a full, versioned copy of everything on this '
            'device, saved here so restore can find it later.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _backingUp ? null : () => unawaited(_backup(context)),
            icon: _backingUp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_backingUp ? 'Backing up…' : 'Back up now'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _restoring ? null : () => unawaited(_restore(context)),
            icon: _restoring
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.restore),
            label: Text(_restoring ? 'Restoring…' : 'Restore from backup…'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Wiping deletes everything on this device and returns the app '
            'to its first-run state. A backup is taken first.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: _wiping ? null : () => unawaited(_wipe(context)),
            icon: _wiping
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : Icon(Icons.delete_forever, color: theme.colorScheme.error),
            label: Text(
              _wiping ? 'Wiping…' : 'Wipe all data',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Personal records are a cache rebuilt from your logged sets. If '
            'one ever looks wrong, rebuilding it from scratch is always safe.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: _rebuildingPrs
                ? null
                : () => unawaited(_rebuildPrs(context)),
            icon: _rebuildingPrs
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(
              _rebuildingPrs ? 'Rebuilding…' : 'Rebuild personal records',
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Debug build only — never reachable in a release. Adds 8 '
              'weeks of a Push/Pull/Legs split plus weekly bodyweight, so '
              'the analytics screens have something to show without '
              'hand-logging sessions.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: _seedingDemoData
                  ? null
                  : () => unawaited(_seedDemoData(context)),
              icon: _seedingDemoData
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Icon(Icons.science_outlined),
              label: Text(
                _seedingDemoData ? 'Loading…' : 'Load sample data (debug)',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    setState(() => _exporting = true);
    try {
      final dumpService = ref.read(jsonDumpServiceProvider);
      final timestamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
      final file = File(
        '${Directory.systemTemp.path}/fitnessapp-export-$timestamp.json',
      );
      final sink = file.openWrite();
      await dumpService.writeTo(sink);
      await sink.close();

      await ref
          .read(exportSharerProvider)
          .share(file, subject: 'FitnessApp export');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Export failed. Try again.')),
        );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    setState(() => _exportingCsv = true);
    try {
      final service = ref.read(csvExportServiceProvider);
      final prefs = ref.read(unitPreferencesProvider);
      final timestamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
      final dir = Directory.systemTemp;

      final files = <File>[
        await _writeCsv(
          dir,
          'sets-$timestamp.csv',
          await service.setsCsv(prefs),
        ),
        await _writeCsv(
          dir,
          'measurements-$timestamp.csv',
          await service.measurementsCsv(prefs),
        ),
        await _writeCsv(
          dir,
          'routines-$timestamp.csv',
          await service.routinesCsv(prefs),
        ),
      ];

      await ref
          .read(exportSharerProvider)
          .shareAll(files, subject: 'FitnessApp CSV export');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Export failed. Try again.')),
        );
    } finally {
      if (mounted) setState(() => _exportingCsv = false);
    }
  }

  Future<File> _writeCsv(Directory dir, String name, String content) async {
    final file = File('${dir.path}/fitnessapp-$name');
    await file.writeAsString(content);
    return file;
  }

  Future<void> _backup(BuildContext context) async {
    setState(() => _backingUp = true);
    try {
      await ref.read(backupServiceProvider).createBackup();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Backup saved.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Backup failed. Try again.')),
        );
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  Future<void> _restore(BuildContext context) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;
    if (!context.mounted) return;

    final confirmed = await showConfirmSheet(
      context,
      title: 'Restore from backup?',
      message:
          'This replaces every workout, routine and setting on this device '
          'with what is in the backup file. A safety copy of what is here '
          'now is saved first.',
      confirmLabel: 'Restore',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    setState(() => _restoring = true);
    try {
      final result = await ref
          .read(restoreServiceProvider)
          .restoreFrom(File(path));
      if (!context.mounted) return;
      final message = switch (result.outcome) {
        RestoreOutcome.success => 'Restore complete.',
        RestoreOutcome.invalidFile ||
        RestoreOutcome.versionMismatch => result.message ?? 'Restore failed.',
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Restore failed. Try again.')),
        );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _wipe(BuildContext context) async {
    final confirmed = await _confirmWipe(context);
    if (!confirmed) return;
    if (!context.mounted) return;

    setState(() => _wiping = true);
    try {
      await ref.read(backupServiceProvider).createBackup();
      await ref.read(tableSnapshotIoProvider).deleteAllRows();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('All data wiped.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Wipe failed. Try again.')),
        );
    } finally {
      if (mounted) setState(() => _wiping = false);
    }
  }

  /// Typed confirmation, not just a tap (spec: "requires typed
  /// confirmation") — a wipe destroys strictly more than any other
  /// destructive action in the app, so it earns a stronger gate than
  /// `ConfirmSheet` alone.
  Future<bool> _confirmWipe(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Wipe all data?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This permanently deletes every workout, routine and '
                'setting on this device. Type DELETE to confirm.',
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(hintText: 'DELETE'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: controller.text == 'DELETE'
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: const Text('Wipe'),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  /// The maintenance action `F-LOG-013` §5 requires: a full recompute from
  /// raw sets, for whenever the incremental cache is suspected wrong.
  Future<void> _rebuildPrs(BuildContext context) async {
    setState(() => _rebuildingPrs = true);
    try {
      await ref.read(personalRecordRepositoryProvider).rebuildAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Personal records rebuilt.')),
        );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Rebuild failed. Try again.')),
        );
    } finally {
      if (mounted) setState(() => _rebuildingPrs = false);
    }
  }

  Future<void> _seedDemoData(BuildContext context) async {
    setState(() => _seedingDemoData = true);
    try {
      await ref.read(demoDataSeederProvider).seed();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Sample data loaded.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not load sample data.')),
        );
    } finally {
      if (mounted) setState(() => _seedingDemoData = false);
    }
  }
}
