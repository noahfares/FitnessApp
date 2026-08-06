import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/unit_preferences.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/set_numbering.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../settings/application/unit_preferences_provider.dart';
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: Center(child: Text('$error')),
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
                ? const Center(child: CircularProgressIndicator.adaptive())
                : exercises.isEmpty
                ? const _NothingAddedYet()
                : ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, i) =>
                        _SessionExerciseTile(exercise: exercises[i]),
                  ),
          ),
        ],
      ),
      // Both primary actions in the thumb zone: the app is used one-handed,
      // standing, mid-set (docs/23-NAVIGATION.md).
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Row(
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
    // finished session. Lands on the summary once `F-LOG-018` exists.
    context.go(AppRoutes.home);
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(workoutRepositoryProvider);
    final tally = await repo.tally(workout.id);
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this workout?'),
        // Names what is being lost, per the navigation invariants.
        content: Text(
          tally.exercises == 0
              ? 'Nothing has been added to it yet.'
              : '${tally.exercises} '
                    '${tally.exercises == 1 ? 'exercise' : 'exercises'} and '
                    '${tally.completedSets} completed '
                    '${tally.completedSets == 1 ? 'set' : 'sets'} will be '
                    'removed from this session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

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

class _NothingAddedYet extends StatelessWidget {
  const _NothingAddedYet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No exercises yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add the first one to start logging.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One exercise and its sets (`F-LOG-003`).
class _SessionExerciseTile extends ConsumerWidget {
  const _SessionExerciseTile({required this.exercise});

  final SessionExercise exercise;

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
    final labels = labelSets([
      for (final set in sets ?? const <WorkoutSet>[]) set.setType.name,
    ]);

    return Column(
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
            ),
        AddSetButton(workoutExerciseId: exercise.workoutExerciseId),
        const Divider(height: 1),
      ],
    );
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
          const SizedBox(width: 44 + 32),
          Expanded(flex: 3, child: cell('Last time')),
          for (final field in fields)
            Expanded(flex: 2, child: cell(fieldHeader(field, prefs))),
          const SizedBox(width: 56),
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
