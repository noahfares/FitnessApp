import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/plates/plate_calculator.dart';
import '../../settings/application/unit_preferences_provider.dart';

/// The plate calculator, one tap from any weight field (`F-PLT-001` §4).
///
/// Non-barbell exercises — fixed dumbbells, machine stacks — are out of
/// scope here; that per-exercise weight-source distinction is `F-PLT-005`,
/// not yet built.
Future<void> showPlateCalculatorSheet(
  BuildContext context, {
  required String exerciseId,
  required int targetGrams,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => PlateCalculatorSheet(
      exerciseId: exerciseId,
      targetGrams: targetGrams,
    ),
  );
}

class PlateCalculatorSheet extends ConsumerWidget {
  const PlateCalculatorSheet({
    super.key,
    required this.exerciseId,
    required this.targetGrams,
  });

  final String exerciseId;
  final int targetGrams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitPreferencesProvider).load;
    final formatter = ref.watch(quantityFormatterProvider);
    final plateRepository = ref.watch(plateRepositoryProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: FutureBuilder(
          future: () async {
            final exercise = await ref
                .read(exerciseRepositoryProvider)
                .findById(exerciseId);
            final bar = await plateRepository.resolveBar(
              exercise?.defaultBarId,
            );
            final inventory = await plateRepository.getUsablePlates();
            return (bar: bar, inventory: inventory);
          }(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            final bar = data.bar;
            if (bar == null) {
              return const _Message(
                'No bar configured yet — add one in Settings › Bars & '
                'plates.',
              );
            }
            final specs = [
              for (final p in data.inventory)
                PlateSpec(weightGrams: p.weightGrams, pairsAvailable: p.countAvailable),
            ];
            final result = solvePlateLoad(
              targetGrams: targetGrams,
              barWeightGrams: bar.weightGrams,
              inventory: specs,
            );
            return _ResultView(
              bar: bar,
              result: result,
              unit: unit,
              formatter: formatter,
            );
          },
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodyMedium);
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.bar,
    required this.result,
    required this.unit,
    required this.formatter,
  });

  final Bar bar;
  final PlateSolveResult result;
  final MassUnit unit;
  final QuantityFormatter formatter;

  String _weight(int grams) =>
      formatter.massValueOnly(Mass.grams(grams), unit);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plate calculator', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('${bar.name} · ${_weight(bar.weightGrams)} ${unit.symbol}'),
        const SizedBox(height: AppSpacing.md),
        switch (result.status) {
          PlateSolveStatus.exact => _PlateList(
            plates: result.plates,
            weight: _weight,
            unit: unit,
          ),
          PlateSolveStatus.belowBar => const Text(
            'Target is below the bar itself — nothing to load.',
          ),
          PlateSolveStatus.oddLoad => const Text(
            "This target can't be split evenly across both sides.",
          ),
          PlateSolveStatus.closest => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Not exactly assemblable from what's configured.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (result.closestBelowGrams case final below?)
                Text('Closest below: ${_weight(below)} ${unit.symbol}'),
              if (result.closestAboveGrams case final above?)
                Text('Closest above: ${_weight(above)} ${unit.symbol}'),
              const SizedBox(height: AppSpacing.sm),
              _PlateList(plates: result.plates, weight: _weight, unit: unit),
            ],
          ),
        },
      ],
    );
  }
}

class _PlateList extends StatelessWidget {
  const _PlateList({
    required this.plates,
    required this.weight,
    required this.unit,
  });

  final List<PlateUsage> plates;
  final String Function(int) weight;
  final MassUnit unit;

  @override
  Widget build(BuildContext context) {
    if (plates.isEmpty) {
      return const Text('Bar only — no plates needed.');
    }
    return Text(
      'Per side: '
      '${plates.map((p) => '${p.pairs} × ${weight(p.weightGrams)} ${unit.symbol}').join(', ')}',
    );
  }
}
