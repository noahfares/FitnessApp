import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/distance.dart';
import '../../../core/units/length.dart';
import '../../../core/units/mass.dart';
import '../application/unit_preferences_provider.dart';
import '../../../core/l10n/l10n.dart';

/// Settings › Units (F-SET-001).
///
/// Four independent settings, because real users mix them — lifting in
/// kilograms while weighing in pounds is entirely normal.
///
/// Every change here is **display-only**: one preference key is written, no
/// stored quantity is touched, and it is instantly reversible. The live preview
/// at the bottom makes that visible rather than asking anyone to take it on
/// trust.
class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitPreferencesProvider);
    final notifier = ref.read(unitPreferencesProvider.notifier);
    final formatter = ref.watch(quantityFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsUnits)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          _UnitChoice<MassUnit>(
            title: context.l10n.settingsWeights,
            subtitle: context.l10n.settingsSetsTargetsPlatesAndBars,
            values: MassUnit.values,
            selected: units.load,
            labelOf: (unit) => unit.symbol,
            onChanged: notifier.setLoad,
          ),
          _UnitChoice<MassUnit>(
            title: context.l10n.settingsBodyweight,
            subtitle: context.l10n.settingsDistanceUnitNote,
            values: MassUnit.values,
            selected: units.body,
            labelOf: (unit) => unit.symbol,
            onChanged: notifier.setBody,
          ),
          _UnitChoice<LengthUnit>(
            title: context.l10n.settingsMeasurements,
            subtitle: context.l10n.settingsCircumferences,
            values: LengthUnit.values,
            selected: units.length,
            labelOf: (unit) => unit.symbol,
            onChanged: notifier.setLength,
          ),
          _UnitChoice<DistanceUnit>(
            title: context.l10n.settingsDistance,
            subtitle: context.l10n.settingsCardio,
            values: DistanceUnit.values,
            selected: units.distance,
            labelOf: (unit) => unit.symbol,
            onChanged: notifier.setDistance,
          ),
          const Divider(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settingsPreview,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.settingsUnitsExplainer,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                _PreviewRow(
                  context.l10n.settingsTopSet,
                  formatter.setWeight(const Mass.grams(102500), showUnit: true),
                ),
                _PreviewRow(
                  context.l10n.settingsSessionVolume,
                  formatter.volume(const Mass.grams(12480000)),
                ),
                _PreviewRow(
                  context.l10n.measurementBodyweight,
                  formatter.bodyweight(const Mass.grams(80000)),
                ),
                _PreviewRow(
                  'Waist',
                  formatter.circumference(const Length.millimetres(820)),
                ),
                _PreviewRow(
                  'Run',
                  formatter.distance(const Distance.metres(5000)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _UnitChoice<T> extends StatelessWidget {
  const _UnitChoice({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screen,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SegmentedButton<T>(
            segments: [
              for (final value in values)
                ButtonSegment(value: value, label: Text(labelOf(value))),
            ],
            selected: {selected},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
