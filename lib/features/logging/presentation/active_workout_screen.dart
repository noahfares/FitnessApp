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
import '../../../data/db/tables/enums.dart' show WeightEntryMode;
import '../../../data/repositories/workout_repository.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/set_numbering.dart';
import '../../../domain/routines/rep_range.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../catalog/presentation/exercise_note_sheet.dart';
import '../../settings/application/rest_timer_settings_provider.dart';
import '../../settings/application/rpe_settings_provider.dart';
import '../../shell/widgets/hold_to_confirm_button.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../../timing/presentation/rest_timer_bar.dart';
import '../application/active_workout_providers.dart';
import '../application/set_providers.dart';
import 'exercise_picker_sheet.dart';
import 'progression_rationale_text.dart';
import 'set_row.dart';
import 'set_value_format.dart';
import 'warmup_generator_sheet.dart';

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
    // Watched unconditionally, not inside the null branch below: a provider
    // nothing is listening to is disposed and rebuilt at its initial value,
    // so a flag only read once the workout has already gone would always
    // read false.
    final ending = ref.watch(sessionEndingProvider);

    return active.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const ErrorView(title: 'This workout could not be read'),
      ),
      data: (workout) => switch (workout) {
        // Finishing or discarding removes the session from the stream a
        // moment before the screen navigates away. That null is expected, not
        // a stale deep link, so it must not render the empty state.
        null when ending => const Scaffold(body: LoadingView()),
        null => const _NoActiveWorkout(),
        final workout => _ActiveWorkout(workout: workout),
      },
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
                : ReorderableListView.builder(
                    // Handles rather than long-press-anywhere: every tile is
                    // full of its own interactive targets — set rows, the
                    // note button, the completion toggle — and long-pressing
                    // a set row's number cell already opens the set-type
                    // sheet (`set_row.dart`). A default drag handle would
                    // fight both (`F-LOG-010` §1).
                    buildDefaultDragHandles: false,
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
                        key: ValueKey(exercise.workoutExerciseId),
                        index: i,
                        exercise: exercise,
                        isFirstInGroup: isFirstInGroup,
                        isLastInGroup: isLastInGroup,
                        nextExercise: i < exercises.length - 1
                            ? exercises[i + 1]
                            : null,
                      );
                    },
                    onReorderItem: (oldIndex, newIndex) =>
                        unawaited(_reorder(ref, exercises, oldIndex, newIndex)),
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

  Future<void> _reorder(
    WidgetRef ref,
    List<SessionExercise> exercises,
    int oldIndex,
    int newIndex,
  ) {
    // onReorderItem, unlike the deprecated onReorder, already adjusts
    // newIndex for the removed item — no manual off-by-one correction here.
    final ids = [for (final e in exercises) e.workoutExerciseId];
    ids.insert(newIndex, ids.removeAt(oldIndex));
    return ref.read(workoutRepositoryProvider).reorderExercises(ids);
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
        await _end(ref, () async {
          await repo.discard(workout.id);
          if (context.mounted) context.go(AppRoutes.home);
        });
        return;
      }
    }

    await _end(ref, () async {
      await repo.finish(workout.id);
      // maxSessionVolume only means something once the session's total is
      // final (`F-LOG-013`, `docs/40-ANALYTICS-SPEC.md` §4) — unlike the other
      // three kinds, it is never evaluated mid-session.
      await ref
          .read(personalRecordRepositoryProvider)
          .evaluateSessionVolume(workout.id);
      if (!context.mounted) return;
      // Replaces the stack rather than popping, so back does not walk into a
      // finished session (docs/23-NAVIGATION.md §navigation-invariants).
      context.go(AppRoutes.activeWorkoutSummary, extra: workout.id);
    });
  }

  /// Runs [end] with [sessionEndingProvider] held true.
  ///
  /// The session disappears from [activeWorkoutProvider] on the first write
  /// [end] makes, well before it navigates away; the flag is what stops this
  /// screen rendering "No workout in progress" in that gap. Reset in a
  /// `finally` so a failed write leaves a resumable session showing itself,
  /// not a spinner.
  Future<void> _end(WidgetRef ref, Future<void> Function() end) async {
    ref.read(sessionEndingProvider.notifier).ending = true;
    try {
      await end();
    } finally {
      ref.read(sessionEndingProvider.notifier).ending = false;
    }
  }

  /// A held press rather than a tap-to-confirm sheet (`F-LOG-022` §2):
  /// discarding destroys a whole in-progress session, and a mis-tap on a
  /// single-tap confirm button is exactly the failure mode a confirm sheet
  /// only half-guards against.
  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(workoutRepositoryProvider);
    final tally = await repo.tally(workout.id);
    if (!context.mounted) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.lg,
            AppSpacing.screen,
            AppSpacing.screen,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Discard this workout?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                tally.exercises == 0
                    ? 'Nothing has been added to it yet.'
                    : '${tally.exercises} '
                          '${tally.exercises == 1 ? 'exercise' : 'exercises'} '
                          'and ${tally.completedSets} completed '
                          '${tally.completedSets == 1 ? 'set' : 'sets'} will '
                          'be removed from this session.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Keep training'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: HoldToConfirmButton(
                      label: 'Discard',
                      onConfirmed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    await _end(ref, () async {
      await repo.discard(workout.id);
      if (context.mounted) context.go(AppRoutes.home);
    });
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
    required this.index,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.nextExercise,
    super.key,
  });

  final SessionExercise exercise;

  /// This tile's position in the list, for the drag handle
  /// (`ReorderableDragStartListener`, `F-LOG-010` §1).
  final int index;

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
    final perSide = exercise.weightEntryMode == WeightEntryMode.perSide;
    final rpeSettings = ref.watch(rpeSettingsProvider);

    // Same reasoning: the rest duration is a property of the exercise, and
    // resolving it once per tile keeps the rule out of the completion handler
    // (`F-TIM-005`). Within a superset the timer runs after the *last*
    // member, not between them (`F-LOG-015` §3, `F-ROU-005` §3).
    final restSeconds = restSecondsForGroupMember(
      isGrouped: exercise.groupId != null,
      isLastInGroup: isLastInGroup,
      resolvedSeconds: resolveRestSeconds(
        equipment: exercise.equipment.name,
        primaryMuscle: exercise.primaryMuscle.name,
        routineSeconds: exercise.target?.restSeconds,
        exerciseSeconds: exercise.defaultRestSeconds,
        globalSeconds: ref.watch(restTimerSettingsProvider).defaultSeconds,
      ),
    );
    final labels = labelSets([
      for (final set in sets ?? const <WorkoutSet>[]) set.setType.name,
    ]);

    final tile = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: ReorderableDragStartListener(
            index: index,
            child: CircleAvatar(child: Text('${exercise.position + 1}')),
          ),
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
              if (_targetSummary(exercise.target, perSide, ref)
                  case final summary?)
                Text(
                  'Target: $summary',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              if (exercise.target case final target?
                  when !target.isEmpty && target.rationale != null)
                ProgressionRationaleText(
                  text: progressionRationaleText(
                    target.rationale!,
                    ref.watch(quantityFormatterProvider),
                    prefs.load,
                  ),
                ),
              // The exercise's own persistent note, distinct from anything
              // logged this session (`F-CAT-007` §2).
              if (exercise.exerciseNotes case final note? when note.isNotEmpty)
                _StickyNoteText(note: note),
            ],
          ),
          isThreeLine: true,
          // Swap, remove, and the sticky note — the session rarely matches
          // the plan exactly (`F-LOG-010` §1–§2), and the note is reachable
          // from here so it never requires leaving the workout (`F-CAT-007`
          // §3).
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              switch (value) {
                case 'swap':
                  unawaited(_swap(context, ref));
                case 'remove':
                  unawaited(_remove(context, ref));
                case 'note':
                  unawaited(_editNote(context, ref));
                case 'warmups':
                  unawaited(
                    showWarmupGeneratorSheet(
                      context,
                      exerciseId: exercise.exerciseId,
                      workoutExerciseId: exercise.workoutExerciseId,
                    ),
                  );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'note',
                child: Text(
                  exercise.exerciseNotes == null ? 'Add note' : 'Edit note',
                ),
              ),
              // Only exercises with a weight field have a working weight to
              // ramp into (`F-LOG-020`).
              if (setFieldsFor(
                exercise.trackingType.name,
              ).contains(SetField.weight))
                const PopupMenuItem(
                  value: 'warmups',
                  child: Text('Generate warm-ups'),
                ),
              const PopupMenuItem(value: 'swap', child: Text('Swap exercise')),
              const PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
          ),
        ),
        // The unit lives in the column header so the values themselves do not
        // have to carry it (docs/22-UNITS.md §display-rules).
        _ColumnHeaders(
          fields: fields,
          prefs: prefs,
          perSide: perSide,
          showRpe: rpeSettings.enabled,
        ),
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
              perSide: perSide,
              exerciseId: exercise.exerciseId,
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

  /// Replaces this exercise with a different one, e.g. the squat rack is
  /// taken (`F-LOG-010` §2). Completed sets stay attributed to the exercise
  /// that was actually done; only the swapped-in exercise starts empty
  /// (`WorkoutRepository.swapExercise`).
  Future<void> _swap(BuildContext context, WidgetRef ref) async {
    final chosen = await showExercisePicker(context, ref);
    if (chosen == null || chosen.isEmpty) return;
    await ref
        .read(workoutRepositoryProvider)
        .swapExercise(exercise.workoutExerciseId, chosen.first);
  }

  /// Removing an exercise with logged sets asks first; one with nothing
  /// logged does not, since there is nothing yet to lose (`F-LOG-010` §3).
  /// Either way, undo is one tap on the snackbar that follows
  /// (`F-LOG-022` §3).
  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    if (exercise.completedSetCount > 0) {
      final confirmed = await showConfirmSheet(
        context,
        title: 'Remove ${exercise.name}?',
        message:
            '${exercise.completedSetCount} completed '
            '${exercise.completedSetCount == 1 ? 'set' : 'sets'} will be '
            'removed from this session too.',
        confirmLabel: 'Remove',
      );
      if (!confirmed) return;
    }
    if (!context.mounted) return;

    final repo = ref.read(workoutRepositoryProvider);
    final tombstonedAt = await repo.removeExerciseFromWorkout(
      exercise.workoutExerciseId,
    );
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${exercise.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => unawaited(
              repo.restoreExercise(exercise.workoutExerciseId, tombstonedAt),
            ),
          ),
        ),
      );
  }

  /// Opens the exercise's persistent sticky note without leaving the session
  /// (`F-CAT-007` §3). Writes only through `ExerciseRepository`, so it can
  /// never touch a logged set or the rest timer (`F-CAT-007` acceptance).
  Future<void> _editNote(BuildContext context, WidgetRef ref) {
    return showExerciseNoteSheet(
      context,
      exerciseId: exercise.exerciseId,
      currentNote: exercise.exerciseNotes,
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
  String? _targetSummary(
    SessionExerciseTarget? target,
    bool perSide,
    WidgetRef ref,
  ) {
    if (target == null || target.isEmpty) return null;
    final formatter = ref.watch(quantityFormatterProvider);
    final repRange = formatRepRange(target.repsMin, target.repsMax);
    final displayRange = repRange.isEmpty ? '?' : repRange;
    final parts = <String>[
      if (target.sets != null) '${target.sets}×$displayRange',
      // `target.weightGrams` is total, same as `sets.weight_grams`
      // (`F-LOG-017` §1) — shown alongside the set rows below it, so it must
      // match their entry mode or the two numbers on screen would disagree
      // about what "the target" means (`F-ROU-010` §5).
      if (target.weightGrams != null)
        '${formatter.setWeight(perSide ? Mass.grams(target.weightGrams!) * 0.5 : Mass.grams(target.weightGrams!), showUnit: true)}${perSide ? '/side' : ''}',
      if (target.rpe != null) '@RPE ${target.rpe}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// The exercise's sticky note, collapsed to one line until tapped
/// (`F-CAT-007` §2).
class _StickyNoteText extends StatefulWidget {
  const _StickyNoteText({required this.note});

  final String note;

  @override
  State<_StickyNoteText> createState() => _StickyNoteTextState();
}

class _StickyNoteTextState extends State<_StickyNoteText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.note,
              maxLines: _expanded ? null : 1,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders({
    required this.fields,
    required this.prefs,
    this.perSide = false,
    this.showRpe = false,
  });

  final List<SetField> fields;
  final UnitPreferences prefs;
  final bool perSide;
  final bool showRpe;

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
          SizedBox(
            width:
                AppSpacing.setNumberColumn +
                AppSpacing.setNoteColumn +
                (showRpe ? AppSpacing.setRpeColumn : 0),
          ),
          Expanded(flex: 3, child: cell('Last time')),
          for (final field in fields)
            Expanded(
              flex: 2,
              child: cell(
                fieldHeader(
                  field,
                  prefs,
                  perSide: field == SetField.weight && perSide,
                ),
              ),
            ),
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
