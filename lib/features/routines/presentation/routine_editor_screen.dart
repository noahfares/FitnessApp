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
import 'routine_day_editor_screen.dart' show DayExerciseList, StartDayButton;
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
    final routines = ref.watch(routinesProvider);
    final days = ref.watch(routineDaysProvider(routineId));

    return routines.view(errorTitle: 'Routine could not be read', (rows) {
      Routine? routine;
      for (final r in rows) {
        if (r.id == routineId) routine = r;
      }
      if (routine == null) {
        return const Scaffold(
          body: Center(child: Text('This routine no longer exists.')),
        );
      }
      final loadedRoutine = routine;

      return days.view(errorTitle: 'Days could not be read', (dayRows) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [_RoutineMenu(routine: routine)],
      ),
      body: days.isEmpty
          ? const EmptyState(
              icon: Icons.calendar_view_week_outlined,
              title: 'No days yet',
              message:
                  '"Push", "Pull", "Legs" — a day is what you start '
                  'a workout from.',
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
            label: const Text('Add a day'),
          ),
        ),
      ),
    );
  }

  Future<void> _addDay(BuildContext context, WidgetRef ref) async {
    final name = await promptRoutineName(context, title: 'New day');
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
        actions: [_RoutineMenu(routine: routine)],
      ),
      body: exercises.view(
        errorTitle: 'Exercises could not be read',
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
}

class _DayTile extends ConsumerWidget {
  const _DayTile({required this.routineId, required this.day, super.key});

  final String routineId;
  final RoutineDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(day.name),
        trailing: PopupMenuButton<_DayAction>(
          onSelected: (action) => unawaited(_handle(context, ref, action)),
          itemBuilder: (context) => const [
            PopupMenuItem(value: _DayAction.rename, child: Text('Rename')),
            PopupMenuItem(value: _DayAction.delete, child: Text('Delete')),
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
      case _DayAction.rename:
        final name = await promptRoutineName(
          context,
          title: 'Rename day',
          initial: day.name,
        );
        if (name != null && name.trim().isNotEmpty) {
          await repo.renameDay(day.id, name);
        }
      case _DayAction.delete:
        final confirmed = await showConfirmSheet(
          context,
          title: 'Delete ${day.name}?',
          message: 'Its exercises and targets will be removed.',
        );
        if (confirmed) await repo.deleteDay(day.id);
    }
  }
}

enum _DayAction { rename, delete }

class _RoutineMenu extends ConsumerWidget {
  const _RoutineMenu({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_RoutineMenuAction>(
      onSelected: (action) => unawaited(_handle(context, ref, action)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: _RoutineMenuAction.rename, child: Text('Rename')),
        PopupMenuItem(
          value: _RoutineMenuAction.duplicate,
          child: Text('Duplicate'),
        ),
        PopupMenuItem(
          value: _RoutineMenuAction.archive,
          child: Text('Archive'),
        ),
        PopupMenuItem(value: _RoutineMenuAction.delete, child: Text('Delete')),
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
          title: 'Rename routine',
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
          title: 'Delete ${routine.name}?',
          message:
              'Its days and targets will be removed. Workouts you have '
              'already logged from it are never affected.',
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
