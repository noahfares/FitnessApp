import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/routine_providers.dart';
import 'routine_day_editor_screen.dart'
    show
        DayExerciseList,
        StartDayButton,
        formatScheduledWeekdays,
        showWeekdaySchedulerSheet,
        weekdayAbbreviations;
import 'routine_list_screen.dart' show promptRoutineName;

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
    final l10n = AppLocalizations.of(context)!;
    final routines = ref.watch(routinesProvider);
    final days = ref.watch(routineDaysProvider(routineId));

    return routines.view(errorTitle: l10n.routineEditorReadError, (rows) {
      Routine? routine;
      for (final r in rows) {
        if (r.id == routineId) routine = r;
      }
      if (routine == null) {
        return Scaffold(body: Center(child: Text(l10n.routineEditorNotFound)));
      }
      final loadedRoutine = routine;

      return days.view(errorTitle: l10n.routineEditorDaysReadError, (dayRows) {
        // Collapse straight into the single day rather than a list of
        // one (`F-ROU-002` §4).
        if (dayRows.length == 1) {
          return _SingleDayRoutineScaffold(
            routine: loadedRoutine,
            day: dayRows.single,
          );
        }
        return _MultiDayRoutineScaffold(routine: loadedRoutine, days: dayRows);
      });
    });
  }
}

class _MultiDayRoutineScaffold extends ConsumerWidget {
  const _MultiDayRoutineScaffold({required this.routine, required this.days});

  final Routine routine;
  final List<RoutineDay> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [_RoutineMenu(routine: routine)],
      ),
      body: days.isEmpty
          ? EmptyState(
              icon: Icons.calendar_view_week_outlined,
              title: l10n.routinesNoDaysYet,
              message: l10n.routineEditorNoDaysMessage,
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
            label: Text(l10n.routineEditorAddDay),
          ),
        ),
      ),
    );
  }

  Future<void> _addDay(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await promptRoutineName(
      context,
      title: l10n.routineEditorNewDayTitle,
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
    final l10n = AppLocalizations.of(context)!;
    final exercises = ref.watch(routineDayExercisesProvider(day.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: l10n.routineEditorScheduleAction,
            onPressed: () => unawaited(_schedule(context, ref)),
          ),
          _RoutineMenu(routine: routine),
        ],
      ),
      body: exercises.view(
        errorTitle: l10n.routineEditorExercisesReadError,
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
    final l10n = AppLocalizations.of(context)!;
    final scheduleLabel = formatScheduledWeekdays(
      day.scheduledWeekdays,
      weekdayAbbreviations(l10n),
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
              child: Text(l10n.routineEditorScheduleAction),
            ),
            PopupMenuItem(
              value: _DayAction.rename,
              child: Text(l10n.routineEditorMenuRename),
            ),
            PopupMenuItem(
              value: _DayAction.delete,
              child: Text(l10n.routinesDeleteAction),
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
    final l10n = AppLocalizations.of(context)!;
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
          title: l10n.routineEditorRenameDayTitle,
          initial: day.name,
        );
        if (name != null && name.trim().isNotEmpty) {
          await repo.renameDay(day.id, name);
        }
      case _DayAction.delete:
        final confirmed = await showConfirmSheet(
          context,
          title: l10n.routinesDeleteConfirmTitle(day.name),
          message: l10n.routineEditorDeleteDayConfirmMessage,
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
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<_RoutineMenuAction>(
      onSelected: (action) => unawaited(_handle(context, ref, action)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _RoutineMenuAction.rename,
          child: Text(l10n.routineEditorMenuRename),
        ),
        PopupMenuItem(
          value: _RoutineMenuAction.duplicate,
          child: Text(l10n.routinesDuplicateAction),
        ),
        PopupMenuItem(
          value: _RoutineMenuAction.archive,
          child: Text(l10n.routinesArchiveAction),
        ),
        PopupMenuItem(
          value: _RoutineMenuAction.delete,
          child: Text(l10n.routinesDeleteAction),
        ),
      ],
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _RoutineMenuAction action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(routineRepositoryProvider);
    switch (action) {
      case _RoutineMenuAction.rename:
        final name = await promptRoutineName(
          context,
          title: l10n.routineEditorRenameRoutineTitle,
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
          title: l10n.routinesDeleteConfirmTitle(routine.name),
          message: l10n.routinesDeleteConfirmMessage,
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
