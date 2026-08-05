import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/distance.dart';
import '../../../core/units/length.dart';
import '../../../core/units/mass.dart';
import '../application/unit_preferences_provider.dart';

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
      appBar: AppBar(title: const Text('Units')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          _UnitChoice<MassUnit>(
            title: 'Weights',
            subtitle: 'Sets, targets, plates and bars',
            values: MassUnit.values,
            selected: units.load,
            labelOf: (unit) => unit.symbol,
            onChanged: notifier.setLoad,
          ),
          _UnitChoice<MassUnit>(
            title: 'Bodyweight',
            subtitle: 'Separate from weights on purpose',
            values: MassUnit.values,
            selected: units.body,
            labelOf: (unit) => unit.symbol,
            onChanged: notifier.setBody,
          ),
          _UnitChoice<LengthUnit>(
            title: 'Measurements',
            subtitle: 'Circumferences',
            values: LengthUnit.values,
            selected: units.length,
            labelOf: (unit) => unit.symbol,
            onChanged: notifier.setLength,
          ),
          _UnitChoice<DistanceUnit>(
            title: 'Distance',
            subtitle: 'Cardio',
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
                Text('Preview', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Changing a unit only changes how numbers are shown. Nothing '
                  'stored is rewritten, so switching back is lossless.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                _PreviewRow(
                  'Top set',
                  formatter.setWeight(const Mass.grams(102500), showUnit: true),
                ),
                _PreviewRow(
                  'Session volume',
                  formatter.volume(const Mass.grams(12480000)),
                ),
                _PreviewRow(
                  'Bodyweight',
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
