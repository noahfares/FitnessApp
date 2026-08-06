import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/routine_repository.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../domain/routines/rep_range.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../logging/presentation/exercise_picker_sheet.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/routine_providers.dart';
import 'routine_list_screen.dart' show promptRoutineName;

/// A routine day's exercises and targets (`F-ROU-003`) — the day's own
/// screen, reached from a multi-day routine's day list.
class RoutineDayEditorScreen extends ConsumerWidget {
  const RoutineDayEditorScreen({
    required this.routineId,
    required this.dayId,
    super.key,
  });

  final String routineId;
  final String dayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(routineDaysProvider(routineId));
    final exercises = ref.watch(routineDayExercisesProvider(dayId));

    return days.view(
      errorTitle: 'Day could not be read',
      (rows) {
        RoutineDay? day;
        for (final d in rows) {
          if (d.id == dayId) day = d;
        }
        if (day == null) {
          return const Scaffold(
            body: Center(child: Text('This day no longer exists.')),
          );
        }
        final loadedDay = day;

        return Scaffold(
          appBar: AppBar(
            title: Text(loadedDay.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Rename',
                onPressed: () => unawaited(_rename(context, ref, loadedDay)),
              ),
            ],
          ),
          body: exercises.view(
            errorTitle: 'Exercises could not be read',
            (exerciseRows) => DayExerciseList(
              routineId: routineId,
              day: loadedDay,
              rows: exerciseRows,
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: StartDayButton(dayId: dayId),
            ),
          ),
        );
      },
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    RoutineDay day,
  ) async {
    final name = await promptRoutineName(
      context,
      title: 'Rename day',
      initial: day.name,
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(routineRepositoryProvider).renameDay(day.id, name);
    }
  }
}

/// The exercise list body, shared by the full day screen and the inline
/// single-day routine scaffold.
class DayExerciseList extends ConsumerWidget {
  const DayExerciseList({
    required this.routineId,
    required this.day,
    required this.rows,
    super.key,
  });

  final String routineId;
  final RoutineDay day;
  final List<RoutineExerciseDetail> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        if (rows.isEmpty)
          EmptyState(
            icon: Icons.fitness_center,
            title: 'No exercises yet',
            message: 'Add exercises, then set targets for each.',
            actionLabel: 'Add exercises',
            onAction: () => unawaited(_addExercises(context, ref)),
          )
        else ...[
          for (final row in rows) _ExerciseTargetTile(row: row),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => unawaited(_addExercises(context, ref)),
            icon: const Icon(Icons.add),
            label: const Text('Add exercises'),
          ),
        ],
      ],
    );
  }

  Future<void> _addExercises(BuildContext context, WidgetRef ref) async {
    final chosen = await showExercisePicker(context, ref);
    if (chosen == null || chosen.isEmpty) return;
    await ref.read(routineRepositoryProvider).addExercises(day.id, chosen);
  }
}

class _ExerciseTargetTile extends ConsumerWidget {
  const _ExerciseTargetTile({required this.row});

  final RoutineExerciseDetail row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(quantityFormatterProvider);
    final repRange = formatRepRange(row.targetRepsMin, row.targetRepsMax);

    final displayRange = repRange.isEmpty ? '?' : repRange;
    final summary = <String>[
      if (row.targetSets != null) '${row.targetSets}×$displayRange',
      if (row.targetWeightGrams != null)
        formatter.setWeight(
          Mass.grams(row.targetWeightGrams!),
          showUnit: true,
        ),
      if (row.targetRpe != null) '@RPE ${row.targetRpe}',
      if (row.restSeconds != null) formatRestDuration(row.restSeconds!),
    ];

    return Card(
      child: ListTile(
        title: Text(row.exerciseName),
        subtitle: Text(
          summary.isEmpty ? 'No targets set' : summary.join(' · '),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Remove',
          onPressed: () => unawaited(
            ref
                .read(routineRepositoryProvider)
                .removeExercise(row.routineExerciseId),
          ),
        ),
        onTap: () => unawaited(_editTargets(context, ref)),
      ),
    );
  }

  Future<void> _editTargets(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TargetEditorSheet(row: row),
    );
  }
}

class _TargetEditorSheet extends ConsumerStatefulWidget {
  const _TargetEditorSheet({required this.row});

  final RoutineExerciseDetail row;

  @override
  ConsumerState<_TargetEditorSheet> createState() =>
      _TargetEditorSheetState();
}

class _TargetEditorSheetState extends ConsumerState<_TargetEditorSheet> {
  late final TextEditingController _sets;
  late final TextEditingController _repsMin;
  late final TextEditingController _repsMax;
  late final TextEditingController _weight;
  int? _restSeconds;

  @override
  void initState() {
    super.initState();
    final row = widget.row;
    _sets = TextEditingController(text: row.targetSets?.toString() ?? '');
    _repsMin = TextEditingController(
      text: row.targetRepsMin?.toString() ?? '',
    );
    _repsMax = TextEditingController(
      text: row.targetRepsMax?.toString() ?? '',
    );
    final prefs = ref.read(unitPreferencesProvider);
    _weight = TextEditingController(
      text: row.targetWeightGrams == null
          ? ''
          : ref
              .read(quantityFormatterProvider)
              .massValueOnly(Mass.grams(row.targetWeightGrams!), prefs.load),
    );
    _restSeconds = row.restSeconds;
  }

  @override
  void dispose() {
    _sets.dispose();
    _repsMin.dispose();
    _repsMax.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(unitPreferencesProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screen,
          right: AppSpacing.screen,
          top: AppSpacing.lg,
          bottom: AppSpacing.screen + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.row.exerciseName, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sets,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _repsMin,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps min',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _repsMax,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps max',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Target weight (${prefs.load.symbol})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<int>(
              initialValue: _restSeconds ?? 0,
              decoration: const InputDecoration(
                labelText: 'Rest',
                border: OutlineInputBorder(),
                helperText: 'Overrides the exercise and global defaults.',
              ),
              items: [
                const DropdownMenuItem(value: 0, child: Text('Default')),
                for (final seconds in restDurationChoices)
                  DropdownMenuItem(
                    value: seconds,
                    child: Text(formatRestDuration(seconds)),
                  ),
              ],
              onChanged: (seconds) => setState(
                () => _restSeconds = (seconds ?? 0) == 0 ? null : seconds,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => unawaited(_save(context)),
              child: const Text('Save targets'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final parser = ref.read(quantityParserProvider);
    final prefs = ref.read(unitPreferencesProvider);

    final sets = int.tryParse(_sets.text.trim());
    final repsMin = int.tryParse(_repsMin.text.trim());
    final repsMax = int.tryParse(_repsMax.text.trim());
    final weight = parser.parseMass(_weight.text, prefs.load);

    await ref
        .read(routineRepositoryProvider)
        .setTargets(
          widget.row.routineExerciseId,
          targetSets: Value(sets),
          targetRepsMin: Value(repsMin),
          targetRepsMax: Value(repsMax),
          targetWeightGrams: Value(weight?.grams),
          restSeconds: Value(_restSeconds),
        );

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

/// Starts a workout from this day (`F-ROU-010`) — the join between planning
/// and logging.
class StartDayButton extends ConsumerWidget {
  const StartDayButton({required this.dayId, super.key});

  final String dayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () => unawaited(_start(context, ref)),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start workout'),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(workoutRepositoryProvider);
    try {
      await repo.startFromRoutineDay(dayId);
    } on ActiveWorkoutExistsException {
      if (!context.mounted) return;
      final resume = await showConfirmSheet(
        context,
        title: 'Already training',
        message:
            'A workout is already in progress. Finish or discard it '
            'before starting another.',
        confirmLabel: 'Resume it',
        cancelLabel: 'Cancel',
        isDestructive: false,
      );
      if (resume && context.mounted) context.go(AppRoutes.activeWorkout);
      return;
    }
    if (!context.mounted) return;
    context.go(AppRoutes.activeWorkout);
  }
}
