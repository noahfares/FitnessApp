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

/// The routine list (`F-ROU-001`) — every program, and where they're created,
/// duplicated, archived and deleted from.
class RoutineListScreen extends ConsumerWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New routine',
            onPressed: () => unawaited(_createRoutine(context, ref)),
          ),
        ],
      ),
      body: routines.view(
        errorTitle: 'Routines could not be read',
        (rows) => rows.isEmpty
            ? EmptyState(
                icon: Icons.checklist_outlined,
                title: 'No routines yet',
                message:
                    'A routine holds days; a day is what you start a '
                    'workout from.',
                actionLabel: 'New routine',
                onAction: () => unawaited(_createRoutine(context, ref)),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.screen),
                itemCount: rows.length,
                itemBuilder: (context, i) =>
                    _RoutineTile(routine: rows[i]),
              ),
      ),
    );
  }

  Future<void> _createRoutine(BuildContext context, WidgetRef ref) async {
    final name = await promptRoutineName(context, title: 'New routine');
    if (name == null || name.trim().isEmpty) return;
    final routine = await ref
        .read(routineRepositoryProvider)
        .create(name: name);
    if (!context.mounted) return;
    context.push(AppRoutes.routine(routine.id));
  }
}

class _RoutineTile extends ConsumerWidget {
  const _RoutineTile({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(routineDaysProvider(routine.id));
    return Card(
      child: ListTile(
        title: Text(routine.name),
        subtitle: days.when(
          data: (rows) => Text(
            rows.isEmpty
                ? 'No days yet'
                : rows.map((d) => d.name).join(' · '),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        trailing: PopupMenuButton<_RoutineAction>(
          onSelected: (action) =>
              unawaited(_handle(context, ref, action)),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _RoutineAction.duplicate,
              child: Text('Duplicate'),
            ),
            PopupMenuItem(
              value: _RoutineAction.archive,
              child: Text('Archive'),
            ),
            PopupMenuItem(
              value: _RoutineAction.delete,
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () => context.push(AppRoutes.routine(routine.id)),
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _RoutineAction action,
  ) async {
    final repo = ref.read(routineRepositoryProvider);
    switch (action) {
      case _RoutineAction.duplicate:
        await repo.duplicate(routine.id);
      case _RoutineAction.archive:
        await repo.setArchived(routine.id, isArchived: true);
      case _RoutineAction.delete:
        final confirmed = await showConfirmSheet(
          context,
          title: 'Delete ${routine.name}?',
          message:
              'Its days and targets will be removed. Workouts you have '
              'already logged from it are never affected (`ADR-0004`).',
        );
        if (confirmed) await repo.delete(routine.id);
    }
  }
}

enum _RoutineAction { duplicate, archive, delete }

/// Shared by every rename/create prompt across routines, days and this list —
/// one dialog, so they read and behave identically.
Future<String?> promptRoutineName(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
