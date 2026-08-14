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
import '../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(l10n.dataJsonDescription, style: theme.textTheme.bodyMedium),
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
              _exporting ? l10n.dataExportingAction : l10n.dataExportJsonAction,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.dataCsvDescription, style: theme.textTheme.bodySmall),
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
              _exportingCsv
                  ? l10n.dataExportingAction
                  : l10n.dataExportCsvAction,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.dataImportDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.settingsDataImport),
            icon: const Icon(Icons.file_download_outlined),
            label: Text(l10n.dataImportAction),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.dataBackupDescription, style: theme.textTheme.bodyMedium),
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
              _backingUp ? l10n.dataBackingUpAction : l10n.dataBackUpNowAction,
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
              _restoring ? l10n.dataRestoringAction : l10n.dataRestoreAction,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.dataWipeDescription, style: theme.textTheme.bodyMedium),
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
              _wiping ? l10n.dataWipingAction : l10n.dataWipeAction,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.dataPrDescription, style: theme.textTheme.bodyMedium),
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
                  ? l10n.dataRebuildingAction
                  : l10n.dataRebuildPrsAction,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.dataDebugSeedDescription,
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
                    ? l10n.dataLoadingAction
                    : l10n.dataLoadSampleDataAction,
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.dataExportFailedMessage)));
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.dataExportFailedMessage)));
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.dataBackupSavedMessage)));
    } catch (_) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.dataBackupFailedMessage)));
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

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.dataRestoreConfirmTitle,
      message: l10n.dataRestoreConfirmMessage,
      confirmLabel: l10n.dataRestoreConfirmAction,
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
        RestoreOutcome.success => l10n.dataRestoreCompleteMessage,
        RestoreOutcome.invalidFile || RestoreOutcome.versionMismatch =>
          result.message ?? l10n.dataRestoreFailedDefaultMessage,
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.dataRestoreExceptionMessage)),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.dataAllDataWipedMessage)));
    } catch (_) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.dataWipeFailedMessage)));
    } finally {
      if (mounted) setState(() => _wiping = false);
    }
  }

  /// Typed confirmation, not just a tap (spec: "requires typed
  /// confirmation") — a wipe destroys strictly more than any other
  /// destructive action in the app, so it earns a stronger gate than
  /// `ConfirmSheet` alone.
  Future<bool> _confirmWipe(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final keyword = l10n.dataWipeConfirmKeyword;
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.dataWipeConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dataWipeConfirmBody(keyword)),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (_) => setDialogState(() {}),
                decoration: InputDecoration(hintText: keyword),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.routineNameDialogCancel),
            ),
            FilledButton(
              onPressed: controller.text == keyword
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: Text(l10n.dataWipeConfirmButton),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.dataRebuildPrsSuccessMessage)),
        );
    } catch (_) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.dataRebuildFailedMessage)));
    } finally {
      if (mounted) setState(() => _rebuildingPrs = false);
    }
  }

  Future<void> _seedDemoData(BuildContext context) async {
    setState(() => _seedingDemoData = true);
    try {
      await ref.read(demoDataSeederProvider).seed();
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.dataSampleDataLoadedMessage)),
        );
    } catch (_) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.dataSampleDataFailedMessage)),
        );
    } finally {
      if (mounted) setState(() => _seedingDemoData = false);
    }
  }
}
