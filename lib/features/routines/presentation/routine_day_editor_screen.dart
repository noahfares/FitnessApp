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
import '../../../data/db/tables/enums.dart';
import '../../../data/repositories/routine_repository.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../domain/logging/rpe.dart';
import '../../../domain/progression/linear_progression.dart';
import '../../../domain/progression/progression_rule.dart';
import '../../../domain/routines/rep_range.dart';
import '../../../domain/routines/routine_preview.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../logging/presentation/exercise_picker_sheet.dart';
import '../../settings/application/rest_timer_settings_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../../shell/widgets/weekly_bar_chart.dart';
import '../application/routine_providers.dart';
import 'routine_list_screen.dart' show promptRoutineName;
import '../../../core/l10n/l10n.dart';
import '../../../l10n/app_localizations.dart';

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

    return days.view(errorTitle: context.l10n.routinesDayCouldNotBeRead, (
      rows,
    ) {
      RoutineDay? day;
      for (final d in rows) {
        if (d.id == dayId) day = d;
      }
      if (day == null) {
        return Scaffold(
          body: Center(child: Text(context.l10n.routinesThisDayNoLongerExists)),
        );
      }
      final loadedDay = day;

      return Scaffold(
        appBar: AppBar(
          title: Text(loadedDay.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              tooltip: context.l10n.routinesSchedule,
              onPressed: () => unawaited(_schedule(context, ref, loadedDay)),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.routinesRename,
              onPressed: () => unawaited(_rename(context, ref, loadedDay)),
            ),
          ],
        ),
        body: exercises.view(
          errorTitle: context.l10n.loggingExercisesCouldNotBeRead,
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
    });
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    RoutineDay day,
  ) async {
    final name = await promptRoutineName(
      context,
      title: context.l10n.routinesRenameDay,
      initial: day.name,
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(routineRepositoryProvider).renameDay(day.id, name);
    }
  }

  Future<void> _schedule(
    BuildContext context,
    WidgetRef ref,
    RoutineDay day,
  ) async {
    final selected = await showWeekdaySchedulerSheet(
      context,
      initial: day.scheduledWeekdays,
    );
    if (selected != null) {
      await ref
          .read(routineRepositoryProvider)
          .setScheduledWeekdays(day.id, selected);
    }
  }
}

/// Mon–Sun, ISO weekday order (`DateTime.weekday`: 1 = Monday .. 7 = Sunday).
const List<String> _weekdayAbbreviations = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// `"Mon, Wed, Fri"`, empty when nothing's scheduled (`F-ROU-012`).
String formatScheduledWeekdays(List<int> weekdays, AppLocalizations l10n) {
  if (weekdays.isEmpty) return '';
  final sorted = [...weekdays]..sort();
  return sorted.map((day) => _weekdayAbbreviations[day - 1]).join(', ');
}

/// A day's fixed weekday assignment (`F-ROU-012`) — optional, so an empty
/// selection is a valid save, not a cancelled one. Returns `null` only when
/// the sheet is dismissed without saving.
Future<List<int>?> showWeekdaySchedulerSheet(
  BuildContext context, {
  required List<int> initial,
}) {
  return showModalBottomSheet<List<int>>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) => _WeekdaySchedulerSheet(initial: initial),
  );
}

class _WeekdaySchedulerSheet extends StatefulWidget {
  const _WeekdaySchedulerSheet({required this.initial});

  final List<int> initial;

  @override
  State<_WeekdaySchedulerSheet> createState() => _WeekdaySchedulerSheetState();
}

class _WeekdaySchedulerSheetState extends State<_WeekdaySchedulerSheet> {
  late final Set<int> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.screen,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.routinesSchedule,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.routinesOptionalPickTheWeekdaysYou,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (var day = 1; day <= 7; day++)
                  FilterChip(
                    label: Text(_weekdayAbbreviations[day - 1]),
                    selected: _selected.contains(day),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selected.add(day);
                      } else {
                        _selected.remove(day);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_selected.toList()..sort()),
              child: Text(context.l10n.catalogSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// The exercise list body, shared by the full day screen and the inline
/// single-day routine scaffold.
class DayExerciseList extends ConsumerStatefulWidget {
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
  ConsumerState<DayExerciseList> createState() => _DayExerciseListState();
}

class _DayExerciseListState extends ConsumerState<DayExerciseList> {
  // Multi-select for grouping into a superset (`F-ROU-005` §1). Empty means
  // "not selecting" — there is no separate mode flag to fall out of sync
  // with.
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final rows = widget.rows;
    if (rows.isEmpty) {
      return EmptyState(
        icon: Icons.fitness_center,
        title: context.l10n.historyNoExercisesYet,
        message: context.l10n.routinesAddExercisesThenSetTargets,
        actionLabel: context.l10n.historyAddExercises,
        onAction: () => unawaited(_addExercises(context)),
      );
    }

    final selectedIndices = [
      for (var i = 0; i < rows.length; i++)
        if (_selected.contains(rows[i].routineExerciseId)) i,
    ]..sort();
    final canGroup =
        selectedIndices.length >= 2 &&
        selectedIndices.last - selectedIndices.first ==
            selectedIndices.length - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.screen,
            AppSpacing.screen,
            0,
          ),
          child: _RoutinePreviewCard(rows: rows),
        ),
        if (_selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(context.l10n.routinesSelectedCount(_selected.length)),
                const Spacer(),
                if (!canGroup && selectedIndices.length >= 2)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Text(
                      context.l10n.routinesMustBeAdjacent,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                TextButton.icon(
                  onPressed: canGroup
                      ? () => unawaited(_group(selectedIndices))
                      : null,
                  icon: const Icon(Icons.link),
                  label: Text(context.l10n.routinesGroup),
                ),
                TextButton(
                  onPressed: () => setState(_selected.clear),
                  child: Text(context.l10n.catalogCancel),
                ),
              ],
            ),
          ),
        // Drag to reorder — order is explicit `position`, never implied by
        // the list itself (`F-ROU-004`).
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final row = rows[i];
              final groupId = row.groupId;
              final isFirstInGroup =
                  groupId != null && (i == 0 || rows[i - 1].groupId != groupId);
              final isLastInGroup =
                  groupId != null &&
                  (i == rows.length - 1 || rows[i + 1].groupId != groupId);
              return _ExerciseTargetTile(
                key: ValueKey(row.routineExerciseId),
                row: row,
                isFirstInGroup: isFirstInGroup,
                isLastInGroup: isLastInGroup,
                selected: _selected.contains(row.routineExerciseId),
                selecting: _selected.isNotEmpty,
                onSelectToggle: () => setState(() {
                  if (!_selected.remove(row.routineExerciseId)) {
                    _selected.add(row.routineExerciseId);
                  }
                }),
                onLongPress: () =>
                    setState(() => _selected.add(row.routineExerciseId)),
                onUngroup: groupId == null
                    ? null
                    : () => unawaited(_ungroup(groupId)),
                withinGroupRestSeconds: row.withinGroupRestSeconds,
                onWithinGroupRest: groupId == null || !isFirstInGroup
                    ? null
                    : () => unawaited(
                        _editWithinGroupRest(
                          context,
                          groupId,
                          row.withinGroupRestSeconds,
                        ),
                      ),
              );
            },
            onReorderItem: (oldIndex, newIndex) =>
                unawaited(_reorder(oldIndex, newIndex)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: OutlinedButton.icon(
            onPressed: () => unawaited(_addExercises(context)),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.historyAddExercises),
          ),
        ),
      ],
    );
  }

  Future<void> _addExercises(BuildContext context) async {
    final chosen = await showExercisePicker(context, ref);
    if (chosen == null || chosen.isEmpty) return;
    await ref
        .read(routineRepositoryProvider)
        .addExercises(widget.day.id, chosen);
  }

  Future<void> _reorder(int oldIndex, int newIndex) {
    // onReorderItem, unlike the deprecated onReorder, already adjusts
    // newIndex for the removed item — no manual off-by-one correction here.
    final ids = [for (final row in widget.rows) row.routineExerciseId];
    ids.insert(newIndex, ids.removeAt(oldIndex));
    return ref.read(routineRepositoryProvider).reorderExercises(ids);
  }

  Future<void> _group(List<int> selectedIndices) async {
    final ids = [
      for (final i in selectedIndices) widget.rows[i].routineExerciseId,
    ];
    setState(_selected.clear);
    await ref.read(routineRepositoryProvider).groupExercises(ids);
  }

  Future<void> _ungroup(String groupId) =>
      ref.read(routineRepositoryProvider).ungroupExercises(groupId);

  /// One picker per group, from the block's own header (`F-ROU-005` §3).
  Future<void> _editWithinGroupRest(
    BuildContext context,
    String groupId,
    int? current,
  ) async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.routinesWithinGroupRest,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.routinesWithinGroupRestExplainer,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            RadioGroup<int>(
              groupValue: current ?? 0,
              onChanged: (value) => Navigator.of(context).pop(value ?? 0),
              child: Column(
                children: [
                  RadioListTile<int>(
                    value: 0,
                    title: Text(context.l10n.routinesNoRestBetween),
                  ),
                  for (final seconds in const [10, 15, 30, 45, 60])
                    RadioListTile<int>(
                      value: seconds,
                      title: Text(formatRestDuration(seconds)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    await ref
        .read(routineRepositoryProvider)
        .setWithinGroupRest(groupId, chosen == 0 ? null : chosen);
  }
}

class _ExerciseTargetTile extends ConsumerWidget {
  const _ExerciseTargetTile({
    required this.row,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.selected,
    required this.selecting,
    required this.onSelectToggle,
    required this.onLongPress,
    required this.onUngroup,
    required this.onWithinGroupRest,
    required this.withinGroupRestSeconds,
    super.key,
  });

  final RoutineExerciseDetail row;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool selected;
  final bool selecting;
  final VoidCallback onSelectToggle;
  final VoidCallback onLongPress;
  final VoidCallback? onUngroup;

  /// Opens the picker for rest *between* members (`F-ROU-005` §3). Null on a
  /// row that is not the first of its group — one control per group, on the
  /// block's own header, is the whole point of that header existing.
  final VoidCallback? onWithinGroupRest;
  final int? withinGroupRestSeconds;

  bool get _isGrouped => row.groupId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(quantityFormatterProvider);
    final repRange = formatRepRange(row.targetRepsMin, row.targetRepsMax);
    final theme = Theme.of(context);

    final displayRange = repRange.isEmpty ? '?' : repRange;
    final summary = <String>[
      if (row.targetSets != null) '${row.targetSets}×$displayRange',
      if (row.targetWeightGrams != null)
        formatter.setWeight(Mass.grams(row.targetWeightGrams!), showUnit: true),
      if (row.targetRpe != null) '@RPE ${row.targetRpe}',
      if (row.restSeconds != null) formatRestDuration(row.restSeconds!),
    ];

    final tile = Card(
      margin: _isGrouped
          ? EdgeInsets.only(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              top: isFirstInGroup ? AppSpacing.sm : 0,
              bottom: isLastInGroup ? AppSpacing.sm : 0,
            )
          : null,
      child: ListTile(
        leading: selecting
            ? Checkbox(value: selected, onChanged: (_) => onSelectToggle())
            : null,
        title: Text(row.exerciseName),
        subtitle: Text(
          summary.isEmpty
              ? context.l10n.routinesNoTargetsSet
              : summary.join(' · '),
        ),
        trailing: selecting
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: context.l10n.historyRemove,
                onPressed: () => unawaited(
                  ref
                      .read(routineRepositoryProvider)
                      .removeExercise(row.routineExerciseId),
                ),
              ),
        onTap: selecting
            ? onSelectToggle
            : () => unawaited(_editTargets(context, ref)),
        onLongPress: selecting ? null : onLongPress,
      ),
    );

    // Grouping is visually explicit, not just a data flag (`F-ROU-005` §2):
    // a coloured border wraps the whole contiguous block of members, and
    // only the first member carries the "Superset" label and ungroup action.
    if (!_isGrouped) return tile;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 3),
          top: isFirstInGroup
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
          bottom: isLastInGroup
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirstInGroup ? const Radius.circular(8) : Radius.zero,
          bottom: isLastInGroup ? const Radius.circular(8) : Radius.zero,
        ),
      ),
      child: Column(
        children: [
          if (isFirstInGroup)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm + AppSpacing.sm,
                top: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.loggingSuperset,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (onWithinGroupRest != null)
                    TextButton(
                      onPressed: onWithinGroupRest,
                      child: Text(
                        withinGroupRestSeconds == null
                            ? context.l10n.routinesNoRestBetween
                            : formatRestDuration(withinGroupRestSeconds!),
                      ),
                    ),
                  if (onUngroup != null)
                    TextButton(
                      onPressed: onUngroup,
                      child: Text(context.l10n.routinesUngroup),
                    ),
                ],
              ),
            ),
          tile,
        ],
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
  ConsumerState<_TargetEditorSheet> createState() => _TargetEditorSheetState();
}

class _TargetEditorSheetState extends ConsumerState<_TargetEditorSheet> {
  /// Where the resolved rest comes from, in words (`F-ROU-006`).
  String _restSourceHint(BuildContext context, WidgetRef ref) {
    final globalSeconds = ref.watch(restTimerSettingsProvider).defaultSeconds;
    final resolved = resolveRestSeconds(
      equipment: widget.row.equipment,
      primaryMuscle: widget.row.primaryMuscle,
      routineSeconds: _restSeconds,
      exerciseSeconds: widget.row.exerciseDefaultRestSeconds,
      globalSeconds: globalSeconds,
    );
    final source = resolveRestSource(
      routineSeconds: _restSeconds,
      exerciseSeconds: widget.row.exerciseDefaultRestSeconds,
      globalSeconds: globalSeconds,
    );
    final duration = formatRestDuration(resolved);
    return switch (source) {
      RestSource.routine => context.l10n.routinesRestFromRoutine(duration),
      RestSource.exercise => context.l10n.routinesRestFromExercise(duration),
      RestSource.global => context.l10n.routinesRestFromGlobal(duration),
      RestSource.builtIn => context.l10n.routinesRestFromBuiltIn(duration),
    };
  }

  late final TextEditingController _sets;
  late final TextEditingController _repsMin;
  late final TextEditingController _repsMax;
  late final TextEditingController _weight;
  late final TextEditingController _increment;
  late final TextEditingController _percent;
  int? _restSeconds;
  late ProgressionRuleType _ruleType;
  double? _targetRpe;

  @override
  void initState() {
    super.initState();
    final row = widget.row;
    _sets = TextEditingController(text: row.targetSets?.toString() ?? '');
    _repsMin = TextEditingController(text: row.targetRepsMin?.toString() ?? '');
    _repsMax = TextEditingController(text: row.targetRepsMax?.toString() ?? '');
    final prefs = ref.read(unitPreferencesProvider);
    final formatter = ref.read(quantityFormatterProvider);
    _weight = TextEditingController(
      text: row.targetWeightGrams == null
          ? ''
          : formatter.massValueOnly(
              Mass.grams(row.targetWeightGrams!),
              prefs.load,
            ),
    );
    _restSeconds = row.restSeconds;
    _targetRpe = row.targetRpe;

    final rule = row.progressionRule;
    _ruleType = rule.type;
    final incrementGrams = switch (rule) {
      LinearProgressionRule(config: final config) => config.incrementGrams,
      DoubleProgressionRule(config: final config) => config.incrementGrams,
      RpeAutoregulationRule(config: final config) => config.incrementGrams,
      _ => defaultIncrementGrams(row.primaryMuscle),
    };
    _increment = TextEditingController(
      text: formatter.massValueOnly(Mass.grams(incrementGrams), prefs.load),
    );
    final percent = switch (rule) {
      PercentageProgressionRule(config: final config) => config.percent * 100,
      _ => 85.0,
    };
    _percent = TextEditingController(text: percent.round().toString());
  }

  @override
  void dispose() {
    _sets.dispose();
    _repsMin.dispose();
    _repsMax.dispose();
    _weight.dispose();
    _increment.dispose();
    _percent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(unitPreferencesProvider);
    final formatter = ref.watch(quantityFormatterProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screen,
          right: AppSpacing.screen,
          top: AppSpacing.lg,
          bottom: AppSpacing.screen + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
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
                      decoration: InputDecoration(
                        labelText: context.l10n.loggingSets,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _repsMin,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.routinesRepsMin,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _repsMax,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.routinesRepsMax,
                        border: const OutlineInputBorder(),
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
                  labelText: context.l10n.routinesTargetWeightWithUnit(
                    prefs.load.symbol,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<int>(
                initialValue: _restSeconds ?? 0,
                decoration: InputDecoration(
                  labelText: context.l10n.routinesRest,
                  border: const OutlineInputBorder(),
                  // Which level "Default" actually resolves to, not just the
                  // word "default" (`F-ROU-006`): a field showing 90 s with no
                  // indication of where 90 came from is indistinguishable from
                  // one somebody set deliberately, and the difference decides
                  // whether editing the exercise will change anything.
                  helperText: _restSourceHint(context, ref),
                ),
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text(context.l10n.catalogDefault),
                  ),
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
              Text(
                context.l10n.routinesProgression,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Plain language, not a configuration form (`F-PRG-007`) — the
              // concepts are simple ("keep it the same" vs. "add weight when I
              // hit my sets") even though the vocabulary underneath isn't.
              SegmentedButton<ProgressionRuleType>(
                segments: [
                  ButtonSegment(
                    value: ProgressionRuleType.manualCarryForward,
                    label: Text(context.l10n.routinesILlDecide),
                  ),
                  ButtonSegment(
                    value: ProgressionRuleType.linear,
                    label: Text(context.l10n.routinesAddWeightOnSuccess),
                  ),
                  ButtonSegment(
                    value: ProgressionRuleType.doubleProgression,
                    label: Text(context.l10n.routinesAddRepsThenWeight),
                  ),
                  ButtonSegment(
                    value: ProgressionRuleType.rpeAutoregulation,
                    label: Text(context.l10n.routinesMatchEffortRpe),
                  ),
                  ButtonSegment(
                    value: ProgressionRuleType.percentageOfTrainingMax,
                    label: Text(context.l10n.routinesOfTm),
                  ),
                ],
                selected: {_ruleType},
                onSelectionChanged: (selection) =>
                    setState(() => _ruleType = selection.first),
              ),
              if (_ruleType == ProgressionRuleType.linear) ...[
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _increment,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.routinesAddOnSuccessWithUnit(
                      prefs.load.symbol,
                    ),
                    border: const OutlineInputBorder(),
                    helperText: context.l10n.routinesLinearRuleExplainer,
                  ),
                ),
              ],
              if (_ruleType == ProgressionRuleType.doubleProgression) ...[
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _increment,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.routinesAddOnSuccessWithUnit(
                      prefs.load.symbol,
                    ),
                    border: const OutlineInputBorder(),
                    helperText: context.l10n.routinesDoubleProgressionExplainer,
                  ),
                ),
              ],
              if (_ruleType == ProgressionRuleType.rpeAutoregulation) ...[
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<double>(
                  initialValue: _targetRpe,
                  decoration: InputDecoration(
                    labelText: context.l10n.routinesTargetRpe,
                    border: const OutlineInputBorder(),
                    helperText: context.l10n.routinesTargetRpeHint,
                  ),
                  items: [
                    for (final step in rpeSteps)
                      DropdownMenuItem(
                        value: step,
                        child: Text(formatRpeValue(step)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _targetRpe = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _increment,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.routinesBaseStepWithUnit(
                      prefs.load.symbol,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              if (_ruleType == ProgressionRuleType.percentageOfTrainingMax) ...[
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _percent,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.l10n.routinesPercentOfTrainingMax,
                    border: const OutlineInputBorder(),
                    suffixText: '%',
                    helperText: widget.row.trainingMaxGrams == null
                        ? context.l10n.routinesNoTrainingMaxSet
                        : context.l10n.routinesTrainingMaxIs(
                            formatter.massValueOnly(
                              Mass.grams(widget.row.trainingMaxGrams!),
                              prefs.load,
                            ),
                            prefs.load.symbol,
                          ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => unawaited(_save(context)),
                child: Text(context.l10n.routinesSaveTargets),
              ),
            ],
          ),
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

    final repo = ref.read(routineRepositoryProvider);
    await repo.setTargets(
      widget.row.routineExerciseId,
      targetSets: Value(sets),
      targetRepsMin: Value(repsMin),
      targetRepsMax: Value(repsMax),
      targetWeightGrams: Value(weight?.grams),
      targetRpe: Value(_targetRpe),
      restSeconds: Value(_restSeconds),
    );

    final rule = switch (_ruleType) {
      ProgressionRuleType.manualCarryForward => null,
      ProgressionRuleType.linear => LinearProgressionRule(
        config: LinearProgressionConfig(
          incrementGrams:
              parser.parseMass(_increment.text, prefs.load)?.grams ??
              defaultIncrementGrams(widget.row.primaryMuscle),
        ),
      ),
      ProgressionRuleType.doubleProgression => DoubleProgressionRule(
        config: DoubleProgressionConfig(
          incrementGrams:
              parser.parseMass(_increment.text, prefs.load)?.grams ??
              defaultIncrementGrams(widget.row.primaryMuscle),
        ),
      ),
      ProgressionRuleType.rpeAutoregulation => RpeAutoregulationRule(
        config: RpeAutoregulationConfig(
          incrementGrams:
              parser.parseMass(_increment.text, prefs.load)?.grams ??
              defaultIncrementGrams(widget.row.primaryMuscle),
        ),
      ),
      ProgressionRuleType.percentageOfTrainingMax => PercentageProgressionRule(
        config: PercentageProgressionConfig(
          percent: (int.tryParse(_percent.text.trim()) ?? 85) / 100,
        ),
      ),
    };
    await repo.setProgressionRule(widget.row.routineExerciseId, rule);

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

/// Estimated duration, planned volume, and sets per muscle for this day,
/// before it's ever run (`F-ROU-011`) — turns the day editor from a list
/// builder into a programming tool.
class _RoutinePreviewCard extends ConsumerWidget {
  const _RoutinePreviewCard({required this.rows});

  final List<RoutineExerciseDetail> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(quantityFormatterProvider);
    final globalRestSeconds = ref
        .watch(restTimerSettingsProvider)
        .defaultSeconds;

    final previewExercises = [
      for (var i = 0; i < rows.length; i++)
        RoutinePreviewExercise(
          exerciseName: rows[i].exerciseName,
          trackingType: rows[i].trackingType,
          equipment: rows[i].equipment,
          primaryMuscle: rows[i].primaryMuscle,
          secondaryMuscles: rows[i].secondaryMuscles,
          targetSets: rows[i].targetSets,
          targetRepsMin: rows[i].targetRepsMin,
          targetRepsMax: rows[i].targetRepsMax,
          targetWeightGrams: rows[i].targetWeightGrams,
          routineRestSeconds: rows[i].restSeconds,
          exerciseDefaultRestSeconds: rows[i].exerciseDefaultRestSeconds,
          isGrouped: rows[i].groupId != null,
          isLastInGroup:
              rows[i].groupId == null ||
              i == rows.length - 1 ||
              rows[i + 1].groupId != rows[i].groupId,
        ),
    ];

    final durationSeconds = estimateSessionDurationSeconds(
      previewExercises,
      globalRestSeconds: globalRestSeconds,
    );
    final volumeGrams = plannedVolumeGrams(previewExercises);
    final setsByMuscle = plannedSetsPerMuscle(previewExercises);

    // `asNameMap` rather than `byName`: `secondaryMuscles` is a plain
    // `StringListConverter` column, not `textEnum`, so nothing at the DB
    // level guarantees every stored name is still a recognised `Muscle` —
    // same reasoning as `categoryOf()`'s deliberate null-for-unknown.
    final muscleNames = Muscle.values.asNameMap();
    final barPoints = [
      for (final entry in setsByMuscle.entries)
        if (muscleNames[entry.key] case final muscle?)
          WeeklyBarPoint(value: entry.value, label: muscle.label(context.l10n)),
    ]..sort((a, b) => b.value.compareTo(a.value));

    final durationLabel = durationSeconds == 0
        ? '—'
        : '~${(durationSeconds / 60).round()} min';
    final volumeLabel = volumeGrams == 0
        ? '—'
        : formatter.volume(Mass.grams(volumeGrams));

    return Card(
      // The numbers that matter — duration and volume — sit in the subtitle
      // so they're visible without expanding anything. Only the chart, which
      // needs real height (`WeeklyBarChart`'s fixed 200 px), stays behind the
      // `ExpansionTile` and collapsed by default — a day list can be short,
      // and this card must never starve the `Expanded` exercise list beneath
      // it of layout height (it did, once, before this became collapsible).
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          context.l10n.settingsPreview,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text('$durationLabel · $volumeLabel'),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          if (barPoints.isNotEmpty)
            WeeklyBarChart(
              metricLabel: context.l10n.routinesPlannedSetsPerMuscle,
              points: barPoints,
              subtitle: context.l10n.routinesSetsPerMuscle,
              valueLabel: (v) => v.toStringAsFixed(1),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(context.l10n.routinesSetTargetsToSeeSets),
            ),
        ],
      ),
    );
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
      label: Text(context.l10n.routinesStartWorkout),
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
}
