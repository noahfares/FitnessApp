import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/platform/export_sharer.dart';

/// Settings › Data (`F-DAT-011`, `F-LOG-013` §5).
///
/// Only the minimal JSON dump exists in Phase 1 — import and a designed,
/// versioned backup format are `F-DAT-004`/`F-DAT-001`, Phase 5. This is
/// deliberately the rescue tool, not the real thing: dump, fix, reimport by
/// hand if a schema mistake ever needs it (docs/30-features/DAT/F-DAT-011.md
/// §Why). Also carries the "rebuild personal records" maintenance action —
/// unrelated to the dump, but there is no other settings page for
/// data-integrity actions yet.
class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  bool _exporting = false;
  bool _rebuildingPrs = false;

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
}
