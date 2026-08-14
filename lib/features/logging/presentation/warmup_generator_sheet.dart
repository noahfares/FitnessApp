import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/logging/warmup_generator.dart';
import '../../../domain/plates/plate_calculator.dart';
import '../../../domain/plates/weight_source_calculator.dart';
import '../../settings/application/unit_preferences_provider.dart';

/// Generate a warm-up ramp into a working weight, in one tap (`F-LOG-020`).
///
/// The ruleset shown is the exercise's own saved override if it has one,
/// the app-wide default otherwise — editing it here and generating saves it
/// back to the exercise, which is what makes it "user-editable and
/// per-exercise" without a separate settings screen for two dozen steps
/// nobody visits ahead of time.
Future<void> showWarmupGeneratorSheet(
  BuildContext context, {
  required String exerciseId,
  required String workoutExerciseId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => WarmupGeneratorSheet(
      exerciseId: exerciseId,
      workoutExerciseId: workoutExerciseId,
    ),
  );
}

class WarmupGeneratorSheet extends ConsumerStatefulWidget {
  const WarmupGeneratorSheet({
    required this.exerciseId,
    required this.workoutExerciseId,
    super.key,
  });

  final String exerciseId;
  final String workoutExerciseId;

  @override
  ConsumerState<WarmupGeneratorSheet> createState() =>
      _WarmupGeneratorSheetState();
}

class _WarmupGeneratorSheetState extends ConsumerState<WarmupGeneratorSheet> {
  final TextEditingController _weight = TextEditingController();
  List<WarmupStep> _ruleset = [...defaultWarmupRuleset];
  Exercise? _exercise;
  bool _loading = true;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final exercise = await ref
        .read(exerciseRepositoryProvider)
        .findById(widget.exerciseId);
    if (!mounted) return;
    setState(() {
      _exercise = exercise;
      _ruleset = [...decodeWarmupRuleset(exercise?.warmupRuleset)];
      _loading = false;
    });
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = ref.watch(unitPreferencesProvider).load;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screen,
          right: AppSpacing.screen,
          top: AppSpacing.screen,
          bottom: AppSpacing.screen + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Generate warm-ups',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      key: const Key('warmupWorkingWeightField'),
                      controller: _weight,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Working weight',
                        suffixText: unit.symbol,
                        border: const OutlineInputBorder(),
                        errorText: _error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ramp', style: theme.textTheme.titleSmall),
                        TextButton(
                          onPressed: () => setState(
                            () => _ruleset = [...defaultWarmupRuleset],
                          ),
                          child: const Text('Reset to default'),
                        ),
                      ],
                    ),
                    for (var i = 0; i < _ruleset.length; i++)
                      _StepRow(
                        step: _ruleset[i],
                        onChanged: (step) => setState(() => _ruleset[i] = step),
                        onRemove: () => setState(() => _ruleset.removeAt(i)),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(
                          () => _ruleset = [
                            ..._ruleset,
                            const WarmupStep(percent: 0.5, reps: 5),
                          ],
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add step'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _generating ? null : _generate,
                      child: Text(_generating ? 'Generating…' : 'Generate'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _generate() async {
    if (_ruleset.isEmpty) {
      setState(() => _error = 'Add at least one step');
      return;
    }
    final unit = ref.read(unitPreferencesProvider).load;
    final workingWeight = ref
        .read(quantityParserProvider)
        .parseMass(_weight.text, unit);
    if (workingWeight == null || workingWeight.grams <= 0) {
      setState(() => _error = 'Enter the working weight');
      return;
    }

    setState(() {
      _generating = true;
      _error = null;
    });

    final exercise = _exercise;
    final (minGrams, round) = await _resolveRounding(exercise);

    final steps = generateWarmupSets(
      workingWeightGrams: workingWeight.grams,
      minWeightGrams: minGrams,
      roundToAchievable: round,
      ruleset: _ruleset,
    );

    await ref
        .read(setRepositoryProvider)
        .insertWarmupSets(widget.workoutExerciseId, steps);
    if (exercise != null) {
      await ref
          .read(exerciseRepositoryProvider)
          .setWarmupRuleset(exercise.id, encodeWarmupRuleset(_ruleset));
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// The exercise's own weight source decides both the floor (a stack's
  /// base, a bar's own weight, or zero) and how each step rounds
  /// (`F-PLT-005`) — the same dispatch `PlateCalculatorSheet` already does.
  Future<(int, int Function(int))> _resolveRounding(Exercise? exercise) async {
    if (exercise == null) return (0, (int g) => g);

    switch (exercise.weightSource) {
      case WeightSource.plateLoaded:
        final plateRepository = ref.read(plateRepositoryProvider);
        final bar = await plateRepository.resolveBar(exercise.defaultBarId);
        if (bar == null) return (0, (int g) => g);
        final inventory = await plateRepository.getUsablePlates();
        final specs = [
          for (final p in inventory)
            PlateSpec(
              weightGrams: p.weightGrams,
              pairsAvailable: p.countAvailable,
            ),
        ];
        return (
          bar.weightGrams,
          (int g) =>
              closestAchievableGrams(
                targetGrams: g,
                barWeightGrams: bar.weightGrams,
                inventory: specs,
              ) ??
              bar.weightGrams,
        );
      case WeightSource.fixedIncrement:
        final available = exercise.fixedIncrementsGrams;
        if (available.isEmpty) return (0, (int g) => g);
        final min = available.reduce((a, b) => a < b ? a : b);
        return (
          min,
          (int g) =>
              closestAchievableFixedIncrement(
                targetGrams: g,
                availableGrams: available,
              ) ??
              min,
        );
      case WeightSource.stack:
        final base = exercise.stackBaseGrams;
        final step = exercise.stackStepGrams;
        if (base == null || step == null) return (0, (int g) => g);
        return (
          base,
          (int g) =>
              closestAchievableStack(
                targetGrams: g,
                baseGrams: base,
                stepGrams: step,
                halfStepGrams: exercise.stackHalfStepGrams,
              ) ??
              base,
        );
    }
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.onChanged,
    required this.onRemove,
  });

  final WarmupStep step;
  final ValueChanged<WarmupStep> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: (step.percent * 100).round().toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '% of working weight',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final percent = int.tryParse(value);
                if (percent != null) {
                  onChanged(
                    WarmupStep(percent: percent / 100, reps: step.reps),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextFormField(
              initialValue: step.reps.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final reps = int.tryParse(value);
                if (reps != null) {
                  onChanged(WarmupStep(percent: step.percent, reps: reps));
                }
              },
            ),
          ),
          IconButton(
            tooltip: 'Remove step',
            icon: const Icon(Icons.close),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
