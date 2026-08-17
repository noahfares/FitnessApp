import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/plates/plate_calculator.dart';
import '../../../domain/plates/weight_source_calculator.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/plate_stack_visualization.dart';

/// The load calculator, one tap from any weight field (`F-PLT-001` §4).
///
/// Which exercise this is for decides everything shown: plate-loaded exercises
/// get the full plate solve and to-scale drawing (`F-PLT-003`); fixed
/// dumbbells and weight stacks get the closest-achievable weight from their
/// own configured stock (`F-PLT-005`).
Future<void> showPlateCalculatorSheet(
  BuildContext context, {
  required String exerciseId,
  required int targetGrams,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) =>
        PlateCalculatorSheet(exerciseId: exerciseId, targetGrams: targetGrams),
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
            if (exercise == null ||
                exercise.weightSource != WeightSource.plateLoaded) {
              return (exercise: exercise, bar: null, inventory: null);
            }
            final bar = await plateRepository.resolveBar(exercise.defaultBarId);
            final inventory = await plateRepository.getUsablePlates();
            return (exercise: exercise, bar: bar, inventory: inventory);
          }(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            final exercise = data.exercise;
            if (exercise == null) {
              return const _Message('This exercise no longer exists.');
            }
            return switch (exercise.weightSource) {
              WeightSource.plateLoaded => _PlateLoadedView(
                bar: data.bar,
                inventory: data.inventory,
                targetGrams: targetGrams,
                unit: unit,
                formatter: formatter,
              ),
              WeightSource.fixedIncrement => _FixedIncrementView(
                exercise: exercise,
                targetGrams: targetGrams,
                unit: unit,
                formatter: formatter,
              ),
              WeightSource.stack => _StackView(
                exercise: exercise,
                targetGrams: targetGrams,
                unit: unit,
                formatter: formatter,
              ),
            };
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

class _PlateLoadedView extends StatelessWidget {
  const _PlateLoadedView({
    required this.bar,
    required this.inventory,
    required this.targetGrams,
    required this.unit,
    required this.formatter,
  });

  final Bar? bar;
  final List<Plate>? inventory;
  final int targetGrams;
  final MassUnit unit;
  final QuantityFormatter formatter;

  String _weight(int grams) => formatter.massValueOnly(Mass.grams(grams), unit);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bar = this.bar;
    if (bar == null) {
      return const _Message(
        'No bar configured yet — add one in Settings › Bars & plates.',
      );
    }
    final specs = [
      for (final p in inventory ?? const <Plate>[])
        PlateSpec(weightGrams: p.weightGrams, pairsAvailable: p.countAvailable),
    ];
    final result = solvePlateLoad(
      targetGrams: targetGrams,
      barWeightGrams: bar.weightGrams,
      inventory: specs,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plate calculator', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('${bar.name} · ${_weight(bar.weightGrams)} ${unit.symbol}'),
        const SizedBox(height: AppSpacing.md),
        switch (result.status) {
          PlateSolveStatus.exact => _PlateResult(
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
              _PlateResult(plates: result.plates, weight: _weight, unit: unit),
            ],
          ),
        },
      ],
    );
  }
}

/// The per-side plate list plus its to-scale drawing (`F-PLT-003`).
class _PlateResult extends StatelessWidget {
  const _PlateResult({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlateStackVisualization(
          plates: plates,
          // The same sentence the row below shows, in the user's own unit —
          // the drawing is a picture of it, not extra information.
          semanticsLabel:
              'Plates per side: '
              '${plates.map((p) => '${p.pairs} × ${weight(p.weightGrams)} ${unit.symbol}').join(', ')}',
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Per side: '
          '${plates.map((p) => '${p.pairs} × ${weight(p.weightGrams)} ${unit.symbol}').join(', ')}',
        ),
      ],
    );
  }
}

class _FixedIncrementView extends StatelessWidget {
  const _FixedIncrementView({
    required this.exercise,
    required this.targetGrams,
    required this.unit,
    required this.formatter,
  });

  final Exercise exercise;
  final int targetGrams;
  final MassUnit unit;
  final QuantityFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = exercise.fixedIncrementsGrams;
    if (available.isEmpty) {
      return const _Message(
        'No available weights configured yet — add them on this exercise\'s '
        'editor.',
      );
    }
    final below = closestAchievableFixedIncrement(
      targetGrams: targetGrams,
      availableGrams: available,
    );
    final above = closestAchievableFixedIncrement(
      targetGrams: targetGrams,
      availableGrams: available,
      direction: RoundingDirection.up,
    );
    String w(int g) =>
        '${formatter.massValueOnly(Mass.grams(g), unit)} ${unit.symbol}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available weights', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(available.map(w).join(', ')),
        const SizedBox(height: AppSpacing.md),
        if (below == targetGrams)
          Text('Exact match: ${w(targetGrams)}')
        else ...[
          if (below != null) Text('Closest below: ${w(below)}'),
          if (above != null && above != below)
            Text('Closest above: ${w(above)}'),
        ],
      ],
    );
  }
}

class _StackView extends StatelessWidget {
  const _StackView({
    required this.exercise,
    required this.targetGrams,
    required this.unit,
    required this.formatter,
  });

  final Exercise exercise;
  final int targetGrams;
  final MassUnit unit;
  final QuantityFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = exercise.stackBaseGrams;
    final step = exercise.stackStepGrams;
    if (base == null || step == null) {
      return const _Message(
        'No stack configured yet — add its base and step weight on this '
        "exercise's editor.",
      );
    }
    final halfStep = exercise.stackHalfStepGrams;
    final below = closestAchievableStack(
      targetGrams: targetGrams,
      baseGrams: base,
      stepGrams: step,
      halfStepGrams: halfStep,
    );
    final above = closestAchievableStack(
      targetGrams: targetGrams,
      baseGrams: base,
      stepGrams: step,
      halfStepGrams: halfStep,
      direction: RoundingDirection.up,
    );
    String w(int g) =>
        '${formatter.massValueOnly(Mass.grams(g), unit)} ${unit.symbol}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weight stack', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Base ${w(base)}, step ${w(step)}'
          '${halfStep != null ? ', half step ${w(halfStep)}' : ''}',
        ),
        const SizedBox(height: AppSpacing.md),
        if (below == targetGrams)
          Text('Exact match: ${w(targetGrams)}')
        else if (below == null && above == null)
          const Text('Target is below the stack\'s own minimum.')
        else ...[
          if (below != null) Text('Closest below: ${w(below)}'),
          if (above != null && above != below)
            Text('Closest above: ${w(above)}'),
        ],
      ],
    );
  }
}
