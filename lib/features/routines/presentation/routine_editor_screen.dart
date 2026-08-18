import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/routine_providers.dart';
import 'routine_day_editor_screen.dart'
    show
        DayExerciseList,
        StartDayButton,
        formatScheduledWeekdays,
        showWeekdaySchedulerSheet;
import 'routine_list_screen.dart' show promptRoutineName;
import '../../../core/l10n/l10n.dart';

/// A routine's days (`F-ROU-002`) — add, rename, delete, and jump into each
/// one's exercises and targets (`F-ROU-003`).
///
/// A single-day routine collapses straight into its one day rather than
/// forcing an extra tap through a list of one (`F-ROU-002` §4).
class RoutineEditorScreen extends ConsumerWidget {
  const RoutineEditorScreen({required this.routineId, super.key});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final days = ref.watch(routineDaysProvider(routineId));

    return routines.view(
      errorTitle: context.l10n.routinesRoutineCouldNotBeRead,
      (rows) {
        Routine? routine;
        for (final r in rows) {
          if (r.id == routineId) routine = r;
        }
        if (routine == null) {
          return Scaffold(
            body: Center(
              child: Text(context.l10n.routinesThisRoutineNoLongerExists),
            ),
          );
        }
        final loadedRoutine = routine;

        return days.view(errorTitle: context.l10n.routinesDaysCouldNotBeRead, (
          dayRows,
        ) {
          // Collapse straight into the single day rather than a list of
          // one (`F-ROU-002` §4).
          if (dayRows.length == 1) {
            return _SingleDayRoutineScaffold(
              routine: loadedRoutine,
              day: dayRows.single,
            );
          }
          return _MultiDayRoutineScaffold(
            routine: loadedRoutine,
            days: dayRows,
          );
        });
      },
    );
  }
}

class _MultiDayRoutineScaffold extends ConsumerWidget {
  const _MultiDayRoutineScaffold({required this.routine, required this.days});

  final Routine routine;
  final List<RoutineDay> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [_RoutineMenu(routine: routine)],
      ),
      body: days.isEmpty
          ? EmptyState(
              icon: Icons.calendar_view_week_outlined,
              title: context.l10n.routinesNoDaysYet,
              message: context.l10n.routinesDayNameHint,
            )
          // Drag to reorder — order is explicit `position`, never implied
          // by the list itself (`F-ROU-004`).
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: days.length,
              itemBuilder: (context, i) => _DayTile(
                key: ValueKey(days[i].id),
                routineId: routine.id,
                day: days[i],
              ),
              onReorderItem: (oldIndex, newIndex) =>
                  unawaited(_reorder(ref, oldIndex, newIndex)),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: OutlinedButton.icon(
            onPressed: () => unawaited(_addDay(context, ref)),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.routinesAddADay),
          ),
        ),
      ),
    );
  }

  Future<void> _addDay(BuildContext context, WidgetRef ref) async {
    final name = await promptRoutineName(
      context,
      title: context.l10n.routinesNewDay,
    );
    if (name == null || name.trim().isEmpty) return;
    final day = await ref
        .read(routineRepositoryProvider)
        .addDay(routine.id, name: name);
    if (!context.mounted) return;
    unawaited(context.push(AppRoutes.routineDay(routine.id, day.id)));
  }

  Future<void> _reorder(WidgetRef ref, int oldIndex, int newIndex) {
    // onReorderItem, unlike the deprecated onReorder, already adjusts
    // newIndex for the removed item — no manual off-by-one correction here.
    final ids = [for (final day in days) day.id];
    ids.insert(newIndex, ids.removeAt(oldIndex));
    return ref.read(routineRepositoryProvider).reorderDays(ids);
  }
}

/// A single-day routine renders its one day inline — no separate list to tap
/// through (`F-ROU-002` §4).
class _SingleDayRoutineScaffold extends ConsumerWidget {
  const _SingleDayRoutineScaffold({required this.routine, required this.day});

  final Routine routine;
  final RoutineDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(routineDayExercisesProvider(day.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: context.l10n.routinesSchedule,
            onPressed: () => unawaited(_schedule(context, ref)),
          ),
          _RoutineMenu(routine: routine),
        ],
      ),
      body: exercises.view(
        errorTitle: context.l10n.loggingExercisesCouldNotBeRead,
        (rows) => DayExerciseList(routineId: routine.id, day: day, rows: rows),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: StartDayButton(dayId: day.id),
        ),
      ),
    );
  }

  Future<void> _schedule(BuildContext context, WidgetRef ref) async {
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

class _DayTile extends ConsumerWidget {
  const _DayTile({required this.routineId, required this.day, super.key});

  final String routineId;
  final RoutineDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleLabel = formatScheduledWeekdays(
      day.scheduledWeekdays,
      context.l10n,
    );
    return Card(
      child: ListTile(
        title: Text(day.name),
        subtitle: scheduleLabel.isEmpty ? null : Text(scheduleLabel),
        trailing: PopupMenuButton<_DayAction>(
          onSelected: (action) => unawaited(_handle(context, ref, action)),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _DayAction.schedule,
              child: Text(context.l10n.routinesSchedule),
            ),
            PopupMenuItem(
              value: _DayAction.rename,
              child: Text(context.l10n.routinesRename),
            ),
            PopupMenuItem(
              value: _DayAction.delete,
              child: Text(context.l10n.catalogDelete),
            ),
          ],
        ),
        onTap: () => context.push(AppRoutes.routineDay(routineId, day.id)),
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _DayAction action,
  ) async {
    final repo = ref.read(routineRepositoryProvider);
    switch (action) {
      case _DayAction.schedule:
        final selected = await showWeekdaySchedulerSheet(
          context,
          initial: day.scheduledWeekdays,
        );
        if (selected != null) {
          await repo.setScheduledWeekdays(day.id, selected);
        }
      case _DayAction.rename:
        final name = await promptRoutineName(
          context,
          title: context.l10n.routinesRenameDay,
          initial: day.name,
        );
        if (name != null && name.trim().isNotEmpty) {
          await repo.renameDay(day.id, name);
        }
      case _DayAction.delete:
        final confirmed = await showConfirmSheet(
          context,
          title: context.l10n.routinesDeleteDayTitle(day.name),
          message: context.l10n.routinesItsExercisesAndTargetsWill,
        );
        if (confirmed) await repo.deleteDay(day.id);
    }
  }
}

enum _DayAction { schedule, rename, delete }

class _RoutineMenu extends ConsumerWidget {
  const _RoutineMenu({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_RoutineMenuAction>(
      onSelected: (action) => unawaited(_handle(context, ref, action)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _RoutineMenuAction.rename,
          child: Text(context.l10n.routinesRename),
        ),
        PopupMenuItem(
          value: _RoutineMenuAction.duplicate,
          child: Text(context.l10n.routinesDuplicate),
        ),
        PopupMenuItem(
          value: _RoutineMenuAction.archive,
          child: Text(context.l10n.catalogArchive),
        ),
        PopupMenuItem(
          value: _RoutineMenuAction.delete,
          child: Text(context.l10n.catalogDelete),
        ),
      ],
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _RoutineMenuAction action,
  ) async {
    final repo = ref.read(routineRepositoryProvider);
    switch (action) {
      case _RoutineMenuAction.rename:
        final name = await promptRoutineName(
          context,
          title: context.l10n.routinesRenameRoutine,
          initial: routine.name,
        );
        if (name != null && name.trim().isNotEmpty) {
          await repo.rename(routine.id, name);
        }
      case _RoutineMenuAction.duplicate:
        final copy = await repo.duplicate(routine.id);
        if (!context.mounted) return;
        context.pushReplacement(AppRoutes.routine(copy.id));
      case _RoutineMenuAction.archive:
        await repo.setArchived(routine.id, isArchived: true);
        if (!context.mounted) return;
        Navigator.of(context).pop();
      case _RoutineMenuAction.delete:
        final confirmed = await showConfirmSheet(
          context,
          title: context.l10n.routinesDeleteRoutineTitle(routine.name),
          message: context.l10n.routinesDeleteDayExplainer,
        );
        if (confirmed) {
          await repo.delete(routine.id);
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
    }
  }
}

enum _RoutineMenuAction { rename, duplicate, archive, delete }
