import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart' show WeightEntryMode;
import '../../../data/repositories/workout_repository.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/set_numbering.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../logging/application/active_workout_providers.dart';
import '../../logging/application/set_providers.dart';
import '../../logging/presentation/exercise_picker_sheet.dart';
import '../../logging/presentation/set_row.dart' show AddSetButton;
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/history_providers.dart';
import 'history_set_row.dart';

/// Full edit of a past workout — sets, values, types, exercises, and the date
/// (`F-LOG-009` §1).
///
/// Every field writes through immediately, same as the live logger
/// (docs/21-DATA-MODEL.md §persistence-behaviour) — there is no separate
/// "save" step to forget.
class EditPastWorkoutScreen extends ConsumerWidget {
  const EditPastWorkoutScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final workout = ref.watch(workoutByIdProvider(workoutId)).value;
    final exercises = ref.watch(sessionExercisesProvider(workoutId)).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyEditTitle),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.historyEditDoneAction),
          ),
        ],
      ),
      body: workout == null
          ? const LoadingView()
          : _Editor(workout: workout, exercises: exercises),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            unawaited(_addExercisesToWorkout(context, ref, workoutId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.routineDayEditorAddExercisesAction),
      ),
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.workout, required this.exercises});

  final Workout workout;
  final List<SessionExercise>? exercises;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final TextEditingController _name = TextEditingController(
    text: widget.workout.name,
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.workout.notes ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final exercises = widget.exercises;
    final startedAt = DateTime.fromMillisecondsSinceEpoch(
      widget.workout.startedAt,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        TextField(
          controller: _name,
          decoration: InputDecoration(
            labelText: l10n.historyEditNameLabel,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) => unawaited(
            ref
                .read(workoutRepositoryProvider)
                .rename(widget.workout.id, value),
          ),
          onEditingComplete: () => unawaited(
            ref
                .read(workoutRepositoryProvider)
                .rename(widget.workout.id, _name.text),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.historyEditDateLabel),
                subtitle: Text(DateFormat.yMMMd().format(startedAt)),
                onTap: () => unawaited(_pickDate(startedAt)),
              ),
            ),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.historyEditTimeLabel),
                subtitle: Text(DateFormat.jm().format(startedAt)),
                onTap: () => unawaited(_pickTime(startedAt)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _notes,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.historyEditNotesLabel,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) => unawaited(
            ref
                .read(workoutRepositoryProvider)
                .setWorkoutNotes(widget.workout.id, value),
          ),
          onEditingComplete: () => unawaited(
            ref
                .read(workoutRepositoryProvider)
                .setWorkoutNotes(widget.workout.id, _notes.text),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.sessionSummaryExercisesLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (exercises == null)
          const LoadingView()
        else if (exercises.isEmpty)
          EmptyState(
            icon: Icons.fitness_center,
            title: l10n.historyEditEmptyTitle,
            message: l10n.historyEditEmptyMessage,
          )
        else
          for (final exercise in exercises)
            _ExerciseEditor(workoutId: widget.workout.id, exercise: exercise),
        // Room for the FAB.
        const SizedBox(height: 72),
      ],
    );
  }

  Future<void> _pickDate(DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    final combined = DateTime(
      picked.year,
      picked.month,
      picked.day,
      current.hour,
      current.minute,
    );
    await ref
        .read(workoutRepositoryProvider)
        .reschedule(widget.workout.id, combined);
  }

  Future<void> _pickTime(DateTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    final combined = DateTime(
      current.year,
      current.month,
      current.day,
      picked.hour,
      picked.minute,
    );
    await ref
        .read(workoutRepositoryProvider)
        .reschedule(widget.workout.id, combined);
  }
}

class _ExerciseEditor extends ConsumerStatefulWidget {
  const _ExerciseEditor({required this.workoutId, required this.exercise});

  final String workoutId;
  final SessionExercise exercise;

  @override
  ConsumerState<_ExerciseEditor> createState() => _ExerciseEditorState();
}

class _ExerciseEditorState extends ConsumerState<_ExerciseEditor> {
  late final TextEditingController _notes = TextEditingController(
    text: widget.exercise.notes ?? '',
  );

  @override
  void didUpdateWidget(covariant _ExerciseEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.notes != widget.exercise.notes &&
        _notes.text != (widget.exercise.notes ?? '')) {
      _notes.text = widget.exercise.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final exercise = widget.exercise;
    final sets = ref.watch(setsProvider(exercise.workoutExerciseId)).value;
    final fields = setFieldsFor(exercise.trackingType.name);
    final labels = labelSets([
      for (final set in sets ?? const <WorkoutSet>[]) set.setType.name,
    ]);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(exercise.name, style: theme.textTheme.titleMedium),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.historyEditRemoveExerciseTooltip,
                onPressed: () => unawaited(_removeExercise(context)),
              ),
            ],
          ),
          Text(
            '${exercise.primaryMuscle.label} · ${exercise.equipment.label}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _notes,
            decoration: InputDecoration(
              labelText: l10n.historyEditExerciseNoteLabel,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: _saveNote,
            onEditingComplete: () => _saveNote(_notes.text),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (sets != null)
            for (var i = 0; i < sets.length; i++)
              HistorySetRow(
                set: sets[i],
                label: labels[i],
                fields: fields,
                equipment: exercise.equipment.name,
                incrementGrams: exercise.incrementGrams,
                perSide: exercise.weightEntryMode == WeightEntryMode.perSide,
              ),
          AddSetButton(workoutExerciseId: exercise.workoutExerciseId),
          const Divider(height: 1),
        ],
      ),
    );
  }

  void _saveNote(String value) => unawaited(
    ref
        .read(workoutRepositoryProvider)
        .setExerciseNotes(widget.exercise.workoutExerciseId, value),
  );

  Future<void> _removeExercise(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.activeWorkoutRemoveExerciseConfirmTitle(widget.exercise.name),
      message: l10n.historyEditRemoveExerciseConfirmMessage,
      confirmLabel: l10n.activeWorkoutRemove,
    );
    if (!confirmed) return;
    await ref
        .read(workoutRepositoryProvider)
        .removeExerciseFromWorkout(widget.exercise.workoutExerciseId);
  }
}

/// Adds exercises to a past workout, the same picker the active session uses
/// (`F-LOG-002`).
Future<void> _addExercisesToWorkout(
  BuildContext context,
  WidgetRef ref,
  String workoutId,
) async {
  final chosen = await showExercisePicker(context, ref);
  if (chosen == null || chosen.isEmpty) return;
  await ref.read(workoutRepositoryProvider).addExercises(workoutId, chosen);
}
