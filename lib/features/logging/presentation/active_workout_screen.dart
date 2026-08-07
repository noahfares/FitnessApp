import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../core/units/unit_preferences.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/set_numbering.dart';
import '../../../domain/routines/rep_range.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../settings/application/rest_timer_settings_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../../timing/presentation/rest_timer_bar.dart';
import '../application/active_workout_providers.dart';
import '../application/set_providers.dart';
import 'exercise_picker_sheet.dart';
import 'set_row.dart';
import 'set_value_format.dart';

/// The session in progress (`F-LOG-001`, `F-LOG-002`, `F-LOG-007`).
///
/// Holds no session state of its own. Everything it shows is read from the
/// database through [activeWorkoutProvider] and [sessionExercisesProvider],
/// which is what makes force-killing the app cost nothing: there is nothing in
/// memory to lose (docs/21-DATA-MODEL.md §persistence-behaviour).
class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeWorkoutProvider);

    return active.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const ErrorView(title: 'This workout could not be read'),
      ),
      data: (workout) => workout == null
          ? const _NoActiveWorkout()
          : _ActiveWorkout(workout: workout),
    );
  }
}

/// `/workout/active` resolves the in-progress session or sends you to `/start`
/// (docs/23-NAVIGATION.md). Reached by a stale deep link, or by the frame after
/// a discard.
class _NoActiveWorkout extends StatelessWidget {
  const _NoActiveWorkout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No workout in progress.'),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => context.go(AppRoutes.start),
                child: const Text('Start one'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveWorkout extends ConsumerWidget {
  const _ActiveWorkout({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exercises = ref.watch(sessionExercisesProvider(workout.id)).value;
    final elapsed = ref.watch(elapsedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'discard') unawaited(_discard(context, ref));
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'discard', child: Text('Discard workout')),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ref.watch(activeWorkoutIsStaleProvider))
            const _StaleSessionNotice(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  formatElapsed(elapsed),
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  exercises == null
                      ? ''
                      : '${exercises.length} '
                            '${exercises.length == 1 ? 'exercise' : 'exercises'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: exercises == null
                ? const LoadingView()
                : exercises.isEmpty
                ? const EmptyState(
                    icon: Icons.fitness_center,
                    title: 'No exercises yet',
                    message: 'Add the first one to start logging.',
                  )
                : ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, i) {
                      final exercise = exercises[i];
                      final groupId = exercise.groupId;
                      final isLastInGroup =
                          groupId == null ||
                          i == exercises.length - 1 ||
                          exercises[i + 1].groupId != groupId;
                      final isFirstInGroup =
                          groupId != null &&
                          (i == 0 || exercises[i - 1].groupId != groupId);
                      return _SessionExerciseTile(
                        exercise: exercise,
                        isFirstInGroup: isFirstInGroup,
                        isLastInGroup: isLastInGroup,
                        nextExercise: i < exercises.length - 1
                            ? exercises[i + 1]
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      // Both primary actions in the thumb zone: the app is used one-handed,
      // standing, mid-set (docs/23-NAVIGATION.md).
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Above the actions rather than pinned to the top of the screen:
              // the countdown is glanced at between sets from the same thumb
              // position the buttons are pressed from.
              const RestTimerBar(),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => unawaited(_addExercises(context, ref)),
                      icon: const Icon(Icons.add),
                      label: const Text('Add exercises'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => unawaited(_finish(context, ref)),
                      child: const Text('Finish'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addExercises(BuildContext context, WidgetRef ref) async {
    final chosen = await showExercisePicker(context, ref);
    if (chosen == null || chosen.isEmpty) return;
    await ref.read(workoutRepositoryProvider).addExercises(workout.id, chosen);
  }

  /// Finishing an empty session would leave a junk history entry, so it asks
  /// first (`F-LOG-001` §6).
  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(workoutRepositoryProvider);
    final tally = await repo.tally(workout.id);

    if (tally.isEmpty) {
      if (!context.mounted) return;
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nothing logged yet'),
          content: const Text(
            'No sets were completed, so this would be an empty entry in your '
            'history. Discard it instead?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text('Keep training'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('finish'),
              child: const Text('Finish anyway'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('discard'),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (choice == 'cancel' || choice == null) return;
      if (choice == 'discard') {
        await repo.discard(workout.id);
        if (!context.mounted) return;
        context.go(AppRoutes.home);
        return;
      }
    }

    await repo.finish(workout.id);
    if (!context.mounted) return;
    // Replaces the stack rather than popping, so back does not walk into a
    // finished session (docs/23-NAVIGATION.md §navigation-invariants).
    context.go(AppRoutes.activeWorkoutSummary, extra: workout.id);
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(workoutRepositoryProvider);
    final tally = await repo.tally(workout.id);
    if (!context.mounted) return;

    // Names what is being lost, per the navigation invariants.
    final confirmed = await showConfirmSheet(
      context,
      title: 'Discard this workout?',
      message: tally.exercises == 0
          ? 'Nothing has been added to it yet.'
          : '${tally.exercises} '
                '${tally.exercises == 1 ? 'exercise' : 'exercises'} and '
                '${tally.completedSets} completed '
                '${tally.completedSets == 1 ? 'set' : 'sets'} will be '
                'removed from this session.',
      confirmLabel: 'Discard',
    );
    if (!confirmed) return;

    await repo.discard(workout.id);
    if (!context.mounted) return;
    context.go(AppRoutes.home);
  }
}

/// A session left running overnight is one someone forgot to finish.
class _StaleSessionNotice extends StatelessWidget {
  const _StaleSessionNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.tertiaryContainer,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        'This workout has been open for more than 12 hours. Finish or discard '
        'it if you are done.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

/// One exercise and its sets (`F-LOG-003`).
class _SessionExerciseTile extends ConsumerWidget {
  const _SessionExerciseTile({
    required this.exercise,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.nextExercise,
  });

  final SessionExercise exercise;

  /// Grouping is visually explicit in the logger too (`F-LOG-015` §1).
  final bool isFirstInGroup;
  final bool isLastInGroup;

  /// The next exercise in list order, or null at the end — the pairing a tap
  /// on the group/ungroup connector toggles (`F-LOG-015` §4).
  final SessionExercise? nextExercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(unitPreferencesProvider);
    final sets = ref.watch(setsProvider(exercise.workoutExerciseId)).value;
    final ghosts = ref.watch(
      ghostsForExerciseProvider(
        GhostQuery(
          workoutExerciseId: exercise.workoutExerciseId,
          exerciseId: exercise.exerciseId,
        ),
      ),
    );

    // Which columns exist is a property of the exercise, not of each row
    // (`F-CAT-002`), so it is resolved once here.
    final fields = setFieldsFor(exercise.trackingType.name);

    // Same reasoning: the rest duration is a property of the exercise, and
    // resolving it once per tile keeps the rule out of the completion handler
    // (`F-TIM-005`). Within a superset the timer runs after the *last*
    // member, not between them — there is no configured within-group rest,
    // so non-last members rest zero (`F-LOG-015` §3, `F-ROU-005` §3).
    final restSeconds = exercise.groupId != null && !isLastInGroup
        ? 0
        : resolveRestSeconds(
            equipment: exercise.equipment.name,
            primaryMuscle: exercise.primaryMuscle.name,
            routineSeconds: exercise.target?.restSeconds,
            exerciseSeconds: exercise.defaultRestSeconds,
            globalSeconds: ref.watch(restTimerSettingsProvider).defaultSeconds,
          );
    final labels = labelSets([
      for (final set in sets ?? const <WorkoutSet>[]) set.setType.name,
    ]);

    final tile = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: CircleAvatar(child: Text('${exercise.position + 1}')),
          title: Text(exercise.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${exercise.primaryMuscle.label} · ${exercise.equipment.label}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${exercise.completedSetCount} of ${exercise.setCount} '
                '${exercise.setCount == 1 ? 'set' : 'sets'} done',
                style: theme.textTheme.bodySmall,
              ),
              if (_targetSummary(exercise.target, ref) case final summary?)
                Text(
                  'Target: $summary',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          isThreeLine: true,
        ),
        // The unit lives in the column header so the values themselves do not
        // have to carry it (docs/22-UNITS.md §display-rules).
        _ColumnHeaders(fields: fields, prefs: prefs),
        if (sets != null)
          for (var i = 0; i < sets.length; i++)
            SetRow(
              set: sets[i],
              label: labels[i],
              ghost: i < ghosts.length ? ghosts[i] : null,
              fields: fields,
              equipment: exercise.equipment.name,
              incrementGrams: exercise.incrementGrams,
              restSeconds: restSeconds,
            ),
        AddSetButton(workoutExerciseId: exercise.workoutExerciseId),
        if (nextExercise != null)
          Center(
            child: TextButton.icon(
              onPressed: () => unawaited(_toggleGroupWithNext(ref)),
              icon: Icon(
                exercise.groupId != null &&
                        exercise.groupId == nextExercise!.groupId
                    ? Icons.link_off
                    : Icons.link,
                size: 16,
              ),
              label: Text(
                exercise.groupId != null &&
                        exercise.groupId == nextExercise!.groupId
                    ? 'Ungroup'
                    : 'Group with next',
              ),
            ),
          ),
        const Divider(height: 1),
      ],
    );

    if (exercise.groupId == null) return tile;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 3),
        ),
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isFirstInGroup)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                top: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Superset',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          tile,
        ],
      ),
    );
  }

  Future<void> _toggleGroupWithNext(WidgetRef ref) {
    return ref
        .read(workoutRepositoryProvider)
        .toggleGroupWithNext(
          exercise.workoutExerciseId,
          nextExercise!.workoutExerciseId,
        );
  }

  /// What the routine day proposed, rendered beside the ghost values it sits
  /// above rather than folded into the set rows themselves — the target and
  /// what was actually done are two different things (`F-ROU-010` §5).
  String? _targetSummary(SessionExerciseTarget? target, WidgetRef ref) {
    if (target == null || target.isEmpty) return null;
    final formatter = ref.watch(quantityFormatterProvider);
    final repRange = formatRepRange(target.repsMin, target.repsMax);
    final displayRange = repRange.isEmpty ? '?' : repRange;
    final parts = <String>[
      if (target.sets != null) '${target.sets}×$displayRange',
      if (target.weightGrams != null)
        formatter.setWeight(Mass.grams(target.weightGrams!), showUnit: true),
      if (target.rpe != null) '@RPE ${target.rpe}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders({required this.fields, required this.prefs});

  final List<SetField> fields;
  final UnitPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    Widget cell(String text, {TextAlign align = TextAlign.center}) =>
        Text(text, textAlign: align, style: style);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: AppSpacing.setNumberColumn + AppSpacing.setNoteColumn,
          ),
          Expanded(flex: 3, child: cell('Last time')),
          for (final field in fields)
            Expanded(flex: 2, child: cell(fieldHeader(field, prefs))),
          const SizedBox(width: AppSpacing.setRowTouchTarget),
        ],
      ),
    );
  }
}

/// `h:mm:ss` past an hour, `mm:ss` below it.
String formatElapsed(Duration elapsed) {
  final hours = elapsed.inHours;
  final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}
