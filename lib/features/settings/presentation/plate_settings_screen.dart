import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/ids/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../shell/widgets/apple_list.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/section_header.dart';
import '../application/plate_providers.dart';
import '../application/unit_preferences_provider.dart';
import '../../../core/l10n/l10n.dart';

/// Settings › Bars & plates (`F-PLT-002`).
///
/// Configures what `F-PLT-001`'s calculator and `F-PRG-012`'s plate-aware
/// rounding are allowed to propose — never anything the user hasn't told the
/// app they actually own.
class PlateSettingsScreen extends ConsumerWidget {
  const PlateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final bars = ref.watch(barsProvider);
    final plates = ref.watch(platesProvider);
    final unit = ref.watch(unitPreferencesProvider).load;
    final formatter = ref.watch(quantityFormatterProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(context.l10n.settingsBarsPlates)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          _SectionHeading(
            'Bars',
            addLabel: context.l10n.settingsAddABar,
            onAdd: () => _showBarSheet(context, ref, unit: unit),
          ),
          const SizedBox(height: AppSpacing.sm),
          bars.view(
            (rows) => rows.isEmpty
                ? _EmptyRow(context.l10n.settingsNoBarsConfiguredYet)
                : AppleListSection(
                    children: [
                      for (final bar in rows)
                        AppleListRow(
                          icon: bar.isDefault ? Icons.star : Icons.star_border,
                          title: bar.name,
                          subtitle: formatter.massValueOnly(
                            Mass.grams(bar.weightGrams),
                            unit,
                          ),
                          onTap: () =>
                              _showBarSheet(context, ref, unit: unit, bar: bar),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeading(
            'Plates',
            addLabel: context.l10n.settingsAddAPlate,
            onAdd: () => _showPlateSheet(context, ref, unit: unit),
          ),
          const SizedBox(height: AppSpacing.sm),
          plates.view(
            (rows) => rows.isEmpty
                ? _EmptyRow(context.l10n.settingsNoPlatesConfiguredYet)
                : AppleListSection(
                    children: [
                      for (final plate in rows)
                        _PlateRow(
                          plate: plate,
                          unit: unit,
                          formatter: formatter,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showBarSheet(
  BuildContext context,
  WidgetRef ref, {
  required MassUnit unit,
  Bar? bar,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BarEditSheet(unit: unit, bar: bar),
  );
}

Future<void> _showPlateSheet(
  BuildContext context,
  WidgetRef ref, {
  required MassUnit unit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _PlateAddSheet(unit: unit),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(
    this.text, {
    required this.onAdd,
    required this.addLabel,
  });

  final String text;
  final VoidCallback onAdd;

  /// What the add button announces. "Add" alone is ambiguous on a screen with
  /// two of them (`F-A11Y-001`).
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SectionHeader(text)),
        _RoundIconButton(icon: Icons.add, tooltip: addLabel, onPressed: onAdd),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 22,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: colors.tint),
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 13, color: context.appColors.labelSecondary),
  );
}

class _PlateRow extends ConsumerWidget {
  const _PlateRow({
    required this.plate,
    required this.unit,
    required this.formatter,
  });

  final Plate plate;
  final MassUnit unit;
  final QuantityFormatter formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final repo = ref.read(plateRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Switch(
            value: plate.isEnabled,
            onChanged: (value) =>
                unawaited(repo.setPlateEnabled(plate.id, isEnabled: value)),
            activeThumbColor: Colors.white,
            activeTrackColor: colors.tint,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatter.massValueOnly(Mass.grams(plate.weightGrams), unit),
                  style: TextStyle(fontSize: 17, color: colors.label),
                ),
                Text(
                  context.l10n.settingsPairsAvailable(plate.countAvailable),
                  style: TextStyle(fontSize: 13, color: colors.labelSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.settingsFewerPairs,
            icon: Icon(Icons.remove, color: colors.tint),
            onPressed: plate.countAvailable <= 0
                ? null
                : () => unawaited(
                    repo.setPlateCount(plate.id, plate.countAvailable - 1),
                  ),
          ),
          Text(
            '${plate.countAvailable}',
            style: TextStyle(
              fontSize: 15,
              color: colors.label,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          IconButton(
            tooltip: context.l10n.settingsMorePairs,
            icon: Icon(Icons.add, color: colors.tint),
            onPressed: () => unawaited(
              repo.setPlateCount(plate.id, plate.countAvailable + 1),
            ),
          ),
          IconButton(
            tooltip: context.l10n.historyRemove,
            icon: Icon(Icons.delete_outline, color: colors.danger),
            onPressed: () async {
              final confirmed = await showConfirmSheet(
                context,
                title: context.l10n.settingsRemoveThisPlate,
                message: context.l10n.settingsRemovePlateNote,
              );
              if (confirmed) await repo.deletePlate(plate.id);
            },
          ),
        ],
      ),
    );
  }
}

class _BarEditSheet extends ConsumerStatefulWidget {
  const _BarEditSheet({required this.unit, this.bar});

  final MassUnit unit;
  final Bar? bar;

  @override
  ConsumerState<_BarEditSheet> createState() => _BarEditSheetState();
}

class _BarEditSheetState extends ConsumerState<_BarEditSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.bar?.name ?? '',
  );
  late final TextEditingController _weight = TextEditingController(
    text: widget.bar == null
        ? ''
        : Mass.grams(widget.bar!.weightGrams).toUnit(widget.unit).toString(),
  );
  late bool _isDefault = widget.bar?.isDefault ?? false;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final repo = ref.read(plateRepositoryProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.screen + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.bar == null
                  ? context.l10n.settingsNewBar
                  : context.l10n.settingsEditBar,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.22,
                color: colors.label,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: context.l10n.catalogName),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.l10n.settingsWeightWithUnit(
                  widget.unit.symbol,
                ),
              ),
            ),
            AppleSwitchRow(
              title: context.l10n.settingsDefaultBar,
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  final name = _name.text.trim();
                  final value = double.tryParse(_weight.text.trim());
                  if (name.isEmpty || value == null) return;
                  final weightGrams = Mass.inUnit(value, widget.unit).grams;
                  if (widget.bar == null) {
                    await repo.createBar(
                      id: newUuidV4(),
                      name: name,
                      weightGrams: weightGrams,
                      isDefault: _isDefault,
                    );
                  } else {
                    await repo.updateBar(
                      widget.bar!.id,
                      name: name,
                      weightGrams: weightGrams,
                      isDefault: _isDefault,
                    );
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(context.l10n.catalogSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlateAddSheet extends ConsumerStatefulWidget {
  const _PlateAddSheet({required this.unit});

  final MassUnit unit;

  @override
  ConsumerState<_PlateAddSheet> createState() => _PlateAddSheetState();
}

class _PlateAddSheetState extends ConsumerState<_PlateAddSheet> {
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _pairs = TextEditingController(text: '1');

  @override
  void dispose() {
    _weight.dispose();
    _pairs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final repo = ref.read(plateRepositoryProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.screen + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.settingsNewPlate,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.22,
                color: colors.label,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.l10n.settingsWeightWithUnit(
                  widget.unit.symbol,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _pairs,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.settingsPairsAvailableLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  final value = double.tryParse(_weight.text.trim());
                  final pairs = int.tryParse(_pairs.text.trim());
                  if (value == null || pairs == null) return;
                  await repo.createPlate(
                    id: newUuidV4(),
                    weightGrams: Mass.inUnit(value, widget.unit).grams,
                    countAvailable: pairs,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(context.l10n.catalogSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
