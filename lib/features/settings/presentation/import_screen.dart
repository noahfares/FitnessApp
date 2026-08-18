import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/io/import_service.dart';
import '../../../domain/import/csv_import_adapter.dart';
import '../../../domain/import/import_mapping_state.dart';
import '../../logging/presentation/exercise_picker_sheet.dart';
import '../../../core/l10n/l10n.dart';

enum _Step { pickFile, chooseUnit, mapping, importing, done, error }

/// Import from Strong or Hevy (`F-DAT-005`, `F-DAT-006`, `F-DAT-007`).
///
/// One linear flow: pick a file, detect the format by trying each
/// `ColumnMapping` in turn, ask for a unit only if the file itself didn't
/// name one, resolve any unmatched exercise names once each
/// (`ImportMappingState`), then commit. Format detection tries Strong before
/// Hevy — `F-DAT-005` is P1, `F-DAT-006` P2, and a file recognised by
/// neither's required columns throws the same
/// `UnrecognisedCsvFormatException` either way.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  _Step _step = _Step.pickFile;
  String? _errorMessage;
  List<List<dynamic>>? _rows;
  ColumnMapping? _detectedMapping;
  ParsedImport? _parsed;
  ImportPreview? _preview;
  ImportMappingState _mappingState = const ImportMappingState();
  ImportResult? _result;

  static const _mappings = [strongColumnMapping, hevyColumnMapping];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsImport)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: switch (_step) {
          _Step.pickFile => _buildPickFile(),
          _Step.chooseUnit => _buildChooseUnit(),
          _Step.mapping => _buildMapping(),
          _Step.importing => const Center(child: CircularProgressIndicator()),
          _Step.done => _buildDone(),
          _Step.error => _buildError(),
        },
      ),
    );
  }

  Widget _buildPickFile() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.settingsImportScreenExplainer,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () => unawaited(_pickAndParse()),
          icon: const Icon(Icons.file_open_outlined),
          label: Text(context.l10n.settingsChooseACsvFile),
        ),
      ],
    );
  }

  Widget _buildChooseUnit() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "This file doesn't name a weight unit, and guessing wrong would "
          'silently corrupt every weight in it. Which unit was it logged in?',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _reparseWithUnit('kg'),
                child: Text(context.l10n.settingsKilograms),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _reparseWithUnit('lb'),
                child: Text(context.l10n.settingsPounds),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapping() {
    final theme = Theme.of(context);
    final preview = _preview!;
    final unresolved = _mappingState.unresolved(preview.unmatchedExerciseNames);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.settingsImportPreviewFound(
            preview.workoutCount,
            preview.setCount,
          ),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (unresolved.isNotEmpty)
          Text(
            "${unresolved.length} exercise name${unresolved.length == 1 ? '' : 's'} "
            "not in your catalogue. Resolve each once.",
            style: theme.textTheme.bodyMedium,
          ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: unresolved.isEmpty
              ? Center(child: Text(context.l10n.settingsAllExercisesResolved))
              : ListView.separated(
                  itemCount: unresolved.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => _UnmatchedNameTile(
                    name: unresolved[index],
                    onUseExisting: () =>
                        unawaited(_useExisting(unresolved[index])),
                    onCreateCustom: () => _resolve(
                      unresolved[index],
                      const ExerciseResolution.createCustom(),
                    ),
                    onSkip: () => _resolve(
                      unresolved[index],
                      const ExerciseResolution.skip(),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed:
              _mappingState.isFullyResolved(preview.unmatchedExerciseNames)
              ? () => unawaited(_commit())
              : null,
          child: Text(context.l10n.settingsImport),
        ),
      ],
    );
  }

  Widget _buildDone() {
    final result = _result!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.settingsImportComplete,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.settingsImportDone(
                result.workoutsImported,
                result.setsImported,
              ) +
              (result.workoutsSkippedAsDuplicate > 0
                  ? context.l10n.settingsImportSkippedDuplicates(
                      result.workoutsSkippedAsDuplicate,
                    )
                  : ''),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.historyDone),
        ),
      ],
    );
  }

  Widget _buildError() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _errorMessage ?? context.l10n.settingsImportFailed,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: () => setState(() => _step = _Step.pickFile),
          child: Text(context.l10n.settingsTryAgain),
        ),
      ],
    );
  }

  Future<void> _pickAndParse() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    final text = await File(path).readAsString();
    final normalised = text.replaceAll('\r\n', '\n');
    final rows = const CsvToListConverter(eol: '\n').convert(normalised);
    _rows = rows;

    _detectAndParse();
  }

  void _detectAndParse({String? explicitUnitSymbol}) {
    for (final mapping in _mappings) {
      try {
        final adapter = CsvImportAdapter(mapping);
        final parsed = adapter.parse(
          _rows!,
          explicitUnitSymbol: explicitUnitSymbol,
        );
        _detectedMapping = mapping;
        _onParsed(parsed);
        return;
      } on AmbiguousUnitException {
        _detectedMapping = mapping;
        setState(() => _step = _Step.chooseUnit);
        return;
      } on UnrecognisedCsvFormatException {
        continue;
      }
    }
    setState(() {
      _errorMessage =
          "This file doesn't match a Strong or Hevy export — check it's the "
          'right file and try again.';
      _step = _Step.error;
    });
  }

  void _reparseWithUnit(String unitSymbol) {
    final adapter = CsvImportAdapter(_detectedMapping!);
    final parsed = adapter.parse(_rows!, explicitUnitSymbol: unitSymbol);
    _onParsed(parsed);
  }

  Future<void> _onParsed(ParsedImport parsed) async {
    _parsed = parsed;
    final preview = await ref.read(importServiceProvider).preview(parsed);
    if (!mounted) return;
    setState(() {
      _preview = preview;
      _step = _Step.mapping;
    });
  }

  void _resolve(String name, ExerciseResolution resolution) {
    setState(() => _mappingState = _mappingState.resolve(name, resolution));
  }

  Future<void> _useExisting(String name) async {
    final picked = await showExercisePicker(context, ref);
    if (picked == null || picked.isEmpty) return;
    _resolve(name, ExerciseResolution.useExisting(picked.first));
  }

  Future<void> _commit() async {
    setState(() => _step = _Step.importing);
    try {
      final unitSymbol = _parsed!.sourceUnitSymbol;
      final sourceUnit = unitSymbol.startsWith('kg')
          ? MassUnit.kg
          : MassUnit.lb;
      final result = await ref
          .read(importServiceProvider)
          .commit(_parsed!, _mappingState.resolutions, sourceUnit: sourceUnit);
      if (!mounted) return;
      setState(() {
        _result = result;
        _step = _Step.done;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.settingsImportFailedNothingWasChanged;
        _step = _Step.error;
      });
    }
  }
}

class _UnmatchedNameTile extends StatelessWidget {
  const _UnmatchedNameTile({
    required this.name,
    required this.onUseExisting,
    required this.onCreateCustom,
    required this.onSkip,
  });

  final String name;
  final VoidCallback onUseExisting;
  final VoidCallback onCreateCustom;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                OutlinedButton(
                  onPressed: onUseExisting,
                  child: Text(context.l10n.settingsUseExisting),
                ),
                OutlinedButton(
                  onPressed: onCreateCustom,
                  child: Text(context.l10n.settingsCreateNew),
                ),
                OutlinedButton(
                  onPressed: onSkip,
                  child: Text(context.l10n.settingsSkip),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
