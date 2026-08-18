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
import '../../../core/l10n/l10n.dart';

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
      appBar: AppBar(title: Text(context.l10n.settingsData)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            context.l10n.settingsJsonDumpExplainer,
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
            label: Text(
              _exporting ? 'Exporting…' : context.l10n.settingsExportDataJson,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.settingsCsvExportExplainer,
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
            label: Text(
              _exportingCsv ? 'Exporting…' : context.l10n.settingsExportDataCsv,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.settingsImportExplainer,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.settingsDataImport),
            icon: const Icon(Icons.file_download_outlined),
            label: Text(context.l10n.settingsImportFromStrongOrHevy),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.settingsBackupExplainer,
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
            label: Text(
              _backingUp
                  ? context.l10n.settingsBackingUp
                  : context.l10n.settingsBackUpNow,
            ),
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
            label: Text(
              _restoring
                  ? 'Restoring…'
                  : context.l10n.settingsRestoreFromBackup2,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.settingsWipeExplainer,
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
              _wiping ? 'Wiping…' : context.l10n.settingsWipeAllData2,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.settingsRebuildPrsExplainer,
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
              _rebuildingPrs
                  ? 'Rebuilding…'
                  : context.l10n.settingsRebuildPersonalRecords,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.l10n.settingsDemoDataExplainer,
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
                _seedingDemoData
                    ? 'Loading…'
                    : context.l10n.settingsLoadSampleDataDebug,
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
      final subject = context.l10n.settingsFitnessappExport;
      final file = File(
        '${Directory.systemTemp.path}/fitnessapp-export-$timestamp.json',
      );
      final sink = file.openWrite();
      await dumpService.writeTo(sink);
      await sink.close();

      await ref.read(exportSharerProvider).share(file, subject: subject);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsExportFailedTryAgain)),
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
      // Read before the awaits below, not after: the context is only
      // guaranteed live on this side of the gap.
      final subject = context.l10n.settingsFitnessappCsvExport;
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

      await ref.read(exportSharerProvider).shareAll(files, subject: subject);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsExportFailedTryAgain)),
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
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsBackupSaved)),
        );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsBackupFailedTryAgain)),
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
      title: context.l10n.settingsRestoreFromBackup,
      message: context.l10n.settingsRestoreConfirmExplainer,
      confirmLabel: context.l10n.catalogRestore,
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
        RestoreOutcome.success => context.l10n.settingsRestoreComplete,
        RestoreOutcome.invalidFile || RestoreOutcome.versionMismatch =>
          result.message ?? context.l10n.settingsRestoreFailed,
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsRestoreFailedTryAgain)),
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
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsAllDataWiped)),
        );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsWipeFailedTryAgain)),
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
          title: Text(context.l10n.settingsWipeAllData),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.settingsWipeConfirmExplainer),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (_) => setDialogState(() {}),
                decoration: InputDecoration(
                  hintText: context.l10n.settingsDelete,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.catalogCancel),
            ),
            FilledButton(
              onPressed: controller.text == 'DELETE'
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: Text(context.l10n.settingsWipe),
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
          SnackBar(content: Text(context.l10n.settingsPersonalRecordsRebuilt)),
        );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsRebuildFailedTryAgain)),
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
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsSampleDataLoaded)),
        );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.settingsCouldNotLoadSampleData)),
        );
    } finally {
      if (mounted) setState(() => _seedingDemoData = false);
    }
  }
}
