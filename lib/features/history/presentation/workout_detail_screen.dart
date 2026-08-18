import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart' show WeightEntryMode;
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
import '../../../core/l10n/l10n.dart';
import '../../../data/platform/health_service.dart';
import '../../health/application/health_providers.dart';

/// A finished session, in full (`F-LOG-012`).
///
/// Repeating a session (`F-LOG-016`) and saving one as a routine
/// (`F-ROU-001` §3) are both offered — the logged working sets become the
/// new session's targets or the routine's starting targets, respectively.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutByIdProvider(workoutId)).value;
    final exercises = ref.watch(sessionExercisesProvider(workoutId)).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.historyWorkout),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: context.l10n.historyEdit,
            onPressed: () =>
                context.push(AppRoutes.historyWorkoutEdit(workoutId)),
          ),
          IconButton(
            icon: const Icon(Icons.replay_outlined),
            tooltip: context.l10n.historyRepeatThisWorkout,
            onPressed: () => unawaited(_repeat(context, ref)),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add_outlined),
            tooltip: context.l10n.historySaveAsRoutine,
            onPressed: () => unawaited(_saveAsRoutine(context, ref)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.l10n.catalogDelete,
            onPressed: () => unawaited(_delete(context, ref)),
          ),
        ],
      ),
      body: workout == null
          ? const LoadingView()
          : _Detail(workout: workout, exercises: exercises),
    );
  }

  /// Starts a new session pre-populated from this one (`F-LOG-016`) — for
  /// people who train without formal routines, the fastest path to a second
  /// session of the same thing.
  Future<void> _repeat(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(workoutRepositoryProvider);
    try {
      await repo.startFromWorkout(workoutId);
    } on ActiveWorkoutExistsException {
      if (!context.mounted) return;
      final resume = await showConfirmSheet(
        context,
        title: context.l10n.historyAlreadyTraining,
        message: context.l10n.historyAlreadyTrainingExplainer,
        confirmLabel: context.l10n.historyResumeIt,
        cancelLabel: 'Cancel',
        isDestructive: false,
      );
      if (resume && context.mounted) context.go(AppRoutes.activeWorkout);
      return;
    }
    if (!context.mounted) return;
    context.go(AppRoutes.activeWorkout);
  }

  Future<void> _saveAsRoutine(BuildContext context, WidgetRef ref) async {
    final name = await promptRoutineName(
      context,
      title: context.l10n.historySaveAsRoutine,
      initial: ref.read(workoutByIdProvider(workoutId)).value?.name ?? '',
    );
    if (name == null || name.trim().isEmpty) return;
    final routine = await ref
        .read(routineRepositoryProvider)
        .createFromWorkout(workoutId, name: name);
    if (!context.mounted) return;
    unawaited(context.push(AppRoutes.routine(routine.id)));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    // Whether a copy of this session exists in Health Connect decides what the
    // confirmation says: offering to remove a record that was never written
    // would be noise, and deleting one silently would be worse
    // (`F-HLT-001` acceptance).
    final sharesWithHealth = ref.read(healthWriteEnabledProvider);
    final confirmed = await showConfirmSheet(
      context,
      title: context.l10n.historyDeleteThisWorkout,
      message: sharesWithHealth
          ? context.l10n.historyDeleteWorkoutHealthExplainer
          : context.l10n.historyDeleteWorkoutExplainer,
    );
    if (!confirmed) return;

    final repo = ref.read(workoutRepositoryProvider);
    if (sharesWithHealth) {
      final workout = await repo.findById(workoutId);
      if (workout?.endedAt case final endedAt?) {
        // Unawaited for the same reason the write is: the local delete is what
        // actually happened, and a health store that refuses must not leave a
        // workout undeleted here.
        unawaited(
          ref
              .read(healthServiceProvider)
              .deleteWorkout(
                start: DateTime.fromMillisecondsSinceEpoch(workout!.startedAt),
                end: DateTime.fromMillisecondsSinceEpoch(endedAt),
              ),
        );
      }
    }

    await repo.deleteWorkout(workoutId);
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
              label: context.l10n.historyDuration,
              value: workout.endedAt == null
                  ? '—'
                  : formatElapsed(
                      Duration(
                        milliseconds: workout.endedAt! - workout.startedAt,
                      ),
                    ),
            ),
            _Stat(
              label: context.l10n.historyExercises,
              value: '${exercises?.length ?? 0}',
            ),
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
          EmptyState(
            icon: Icons.fitness_center,
            title: context.l10n.historyNoExercisesInThisSession,
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
                              formatSetField(
                                sets[i],
                                field,
                                formatter,
                                prefs,
                                perSide:
                                    exercise.weightEntryMode ==
                                    WeightEntryMode.perSide,
                              ),
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
