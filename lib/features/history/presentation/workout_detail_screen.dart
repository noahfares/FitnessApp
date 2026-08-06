import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/set_numbering.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../logging/application/active_workout_providers.dart';
import '../../logging/application/set_providers.dart';
import '../../logging/presentation/active_workout_screen.dart'
    show formatElapsed;
import '../../logging/presentation/set_value_format.dart';
import '../../routines/presentation/routine_list_screen.dart'
    show promptRoutineName;
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/history_providers.dart';

/// A finished session, in full (`F-LOG-012`).
///
/// Repeating a session (`F-LOG-016`) is still Phase 2 out of scope here.
/// Saving one as a routine (`F-ROU-001` §3) is offered — the logged working
/// sets become that routine's starting targets.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutByIdProvider(workoutId)).value;
    final exercises = ref.watch(sessionExercisesProvider(workoutId)).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () =>
                context.push(AppRoutes.historyWorkoutEdit(workoutId)),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add_outlined),
            tooltip: 'Save as routine',
            onPressed: () => unawaited(_saveAsRoutine(context, ref)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => unawaited(_delete(context, ref)),
          ),
        ],
      ),
      body: workout == null
          ? const LoadingView()
          : _Detail(workout: workout, exercises: exercises),
    );
  }

  Future<void> _saveAsRoutine(BuildContext context, WidgetRef ref) async {
    final name = await promptRoutineName(
      context,
      title: 'Save as routine',
      initial: ref.read(workoutByIdProvider(workoutId)).value?.name ?? '',
    );
    if (name == null || name.trim().isEmpty) return;
    final routine = await ref
        .read(routineRepositoryProvider)
        .createFromWorkout(workoutId, name: name);
    if (!context.mounted) return;
    context.push(AppRoutes.routine(routine.id));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete this workout?',
      message:
          'This session and all its sets will be removed from your '
          'history.',
    );
    if (!confirmed) return;

    await ref.read(workoutRepositoryProvider).deleteWorkout(workoutId);
    if (!context.mounted) return;
    context.go(AppRoutes.history);
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.workout, required this.exercises});

  final Workout workout;
  final List<SessionExercise>? exercises;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercises = this.exercises;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        Text(workout.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          DateFormat.yMMMd().add_jm().format(
            DateTime.fromMillisecondsSinceEpoch(workout.startedAt),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            _Stat(
              label: 'Duration',
              value: workout.endedAt == null
                  ? '—'
                  : formatElapsed(
                      Duration(
                        milliseconds: workout.endedAt! - workout.startedAt,
                      ),
                    ),
            ),
            _Stat(label: 'Exercises', value: '${exercises?.length ?? 0}'),
          ],
        ),
        if (workout.notes != null && workout.notes!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _NoteCard(text: workout.notes!),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (exercises == null)
          const LoadingView()
        else if (exercises.isEmpty)
          const EmptyState(
            icon: Icons.fitness_center,
            title: 'No exercises in this session',
          )
        else
          for (final exercise in exercises)
            _ExerciseSection(exercise: exercise),
      ],
    );
  }
}

class _ExerciseSection extends ConsumerWidget {
  const _ExerciseSection({required this.exercise});

  final SessionExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(unitPreferencesProvider);
    final formatter = ref.watch(quantityFormatterProvider);
    final sets = ref.watch(setsProvider(exercise.workoutExerciseId)).value;
    final fields = setFieldsFor(exercise.trackingType.name);
    final labels = labelSets([
      for (final set in sets ?? const <WorkoutSet>[]) set.setType.name,
    ]);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.name, style: theme.textTheme.titleMedium),
          Text(
            '${exercise.primaryMuscle.label} · ${exercise.equipment.label}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _NoteCard(text: exercise.notes!),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (sets != null)
            for (var i = 0; i < sets.length; i++)
              if (sets[i].isCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs / 2,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: AppSpacing.setNumberColumn,
                        child: Text(labels[i].toString()),
                      ),
                      Expanded(
                        child: Text(
                          [
                            for (final field in fields)
                              formatSetField(sets[i], field, formatter, prefs),
                          ].whereType<String>().join(' × '),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
  }
}
